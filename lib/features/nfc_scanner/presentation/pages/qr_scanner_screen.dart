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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerController.dispose();
    _nfcCodeController.dispose();
    super.dispose();
  }

  bool _isProcessing = false;

  Future<void> _handleScannedCode(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    await _scannerController.stop();

    if (code.contains('sefaz') || code.contains('nfce') || code.contains('fazenda')) {
      await _processNfcUrl(code);
    } else {
      if (!mounted) return;
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
        ],
      ),
    );
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
