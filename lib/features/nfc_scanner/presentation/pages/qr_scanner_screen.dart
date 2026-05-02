import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:xepa_frontend/core/DI/dependency_injection.dart';
import '../../data/datasources/nfc_parser_service.dart';
import 'nfc_invoice_detail_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MobileScannerController _scannerController = MobileScannerController();
  final _nfcCodeController = TextEditingController();
  final NfcParserService _nfcParserService = getIt<NfcParserService>();

  final List<NfcTag> _registeredTags = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerController.dispose();
    _nfcCodeController.dispose();
    super.dispose();
  }

  bool _isProcessing = false;

  void _handleScannedCode(String code) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    _scannerController.stop();

    if (code.contains('sefaz') || code.contains('nfce') || code.contains('fazenda')) {
      _processNfcUrl(code);
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('QR Code Detectado'),
          content: Text('O código lido não parece ser uma NFC-e válida.\n\nCódigo: $code'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _isProcessing = false);
                _scannerController.start();
              },
              child: const Text('Voltar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processNfcUrl(code);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF42A5F5), foregroundColor: Colors.white),
              child: const Text('Tentar assim mesmo'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _processNfcUrl(String url) async {
    setState(() => _isProcessing = true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF42A5F5)),
                const SizedBox(height: 16),
                const Text(
                  'Consultando nota fiscal...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Extraindo dados via SEFAZ',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final invoice = await _nfcParserService.parseUrl(url);
      if (mounted) {
        Navigator.pop(context);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NfcInvoiceDetailScreen(invoice: invoice)),
        );
        if (mounted) {
          setState(() => _isProcessing = false);
          _scannerController.start();
        }
      }
    } catch (e, stack) {
      dev.log('Erro ao processar QR Code NFC-e', error: e, stackTrace: stack);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
        setState(() => _isProcessing = false);
        _scannerController.start();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.qr_code_scanner_rounded,
                          color: Colors.white, size: 26),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QR / NFC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Escaneie ou gerencie suas tags',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Tabs
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Escanear'),
                      Tab(text: 'Digitar Código'),
                      Tab(text: 'Minhas Tags'),
                    ],
                  ),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildScanTab(),
                  _buildManualTab(),
                  _buildMyTagsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanTab() {
    return Column(
      children: [
        // Camera viewfinder
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  // Real camera scanner
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: (capture) {
                      final barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          _handleScannedCode(barcode.rawValue!);
                          return;
                        }
                      }
                    },
                  ),
                  // Overlay com cantos
                  CustomPaint(
                    painter: _ScannerOverlayPainter(),
                    child: const SizedBox.expand(),
                  ),
                  // Instruction at bottom
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Aponte para o QR Code da NFC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Info text
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Text(
            'Escaneie o QR Code na etiqueta NFC para registrar ou consultar itens',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: Colors.grey[400], height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Digitar Código NFC',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Insira o código encontrado na etiqueta NFC manualmente',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nfcCodeController,
            decoration: InputDecoration(
              hintText: 'Cole a URL da SEFAZ GO',
              labelText: 'URL da NFC-e',
              prefixIcon:
                  const Icon(Icons.link_rounded, color: Color(0xFF42A5F5)),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF42A5F5), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                final code = _nfcCodeController.text.trim();
                if (code.isNotEmpty) {
                  _handleScannedCode(code);
                }
              },
              icon: const Icon(Icons.search_rounded),
              label: const Text(
                'Consultar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42A5F5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                if (_nfcCodeController.text.trim().isNotEmpty) {
                  setState(() {
                    _registeredTags.add(NfcTag(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      code: _nfcCodeController.text.trim(),
                      label: 'NFC',
                      registeredAt: DateTime.now(),
                      itemCount: 0,
                    ));
                    _nfcCodeController.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tag NFC cadastrada com sucesso!'),
                      backgroundColor: Color(0xFF66BB6A),
                    ),
                  );
                  _tabController.animateTo(2);
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Cadastrar Nova Tag',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
                side: const BorderSide(color: Color(0xFF2196F3), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTagsTab() {
    return _registeredTags.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.nfc_rounded, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma tag cadastrada',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Escaneie ou digite um código NFC',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _registeredTags.length,
            itemBuilder: (context, index) =>
                _buildTagCard(_registeredTags[index], index),
          );
  }

  Widget _buildTagCard(NfcTag tag, int index) {
    return InkWell(
      onTap: () {
        _processNfcUrl(tag.code);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.nfc_rounded,
                color: Color(0xFF2196F3), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tag.code,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${tag.itemCount} itens • Cadastrada em ${tag.registeredAt.day}/${tag.registeredAt.month}/${tag.registeredAt.year}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey[400]),
            onSelected: (value) {
              if (value == 'delete') {
                setState(() => _registeredTags.removeAt(index));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tag removida'),
                    backgroundColor: Color(0xFFEF5350),
                  ),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Ver detalhes'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded,
                        size: 20, color: Color(0xFFEF5350)),
                    SizedBox(width: 8),
                    Text('Remover',
                        style: TextStyle(color: Color(0xFFEF5350))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2196F3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    const radius = 16.0;

    // Top-left corner
    final topLeft = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(cornerLength, 0);
    canvas.drawPath(topLeft, paint);

    // Top-right corner
    final topRight = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(topRight, paint);

    // Bottom-left corner
    final bottomLeft = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - radius)
      ..quadraticBezierTo(0, size.height, radius, size.height)
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(bottomLeft, paint);

    // Bottom-right corner
    final bottomRight = Path()
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(
          size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(bottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NfcTag {
  final String id;
  final String code;
  final String label;
  final DateTime registeredAt;
  final int itemCount;

  NfcTag({
    required this.id,
    required this.code,
    required this.label,
    required this.registeredAt,
    required this.itemCount,
  });
}
