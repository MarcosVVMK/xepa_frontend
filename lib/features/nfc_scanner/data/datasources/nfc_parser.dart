import '../../domain/entities/nfc_invoice.dart';
import '../../domain/entities/nfc_invoice_item.dart';

class NfcParser {
  NfcParser._();

  static NfcInvoice mapResponseToInvoice(
    Map<String, dynamic> data,
    String accessKey,
  ) {
    try {
      final entry = (data['data'] is List && (data['data'] as List).isNotEmpty)
          ? data['data'][0] as Map<String, dynamic>
          : data;

      final issuer = entry['emitente'] as Map<String, dynamic>? ?? {};
      final products = entry['produtos'] as List<dynamic>? ?? [];
      final totals = entry['totais'] as Map<String, dynamic>? ?? {};
      final info = entry['informacoes_nota'] as Map<String, dynamic>? ?? {};
      final nfe = entry['nfe'] as Map<String, dynamic>? ?? {};

      final supermarketName =
          _firstNonEmpty([
            issuer['nome'],
            issuer['nome_razao_social'],
            issuer['nome_fantasia'],
          ]) ??
          'Estabelecimento';

      final cnpj =
          _firstNonEmpty([issuer['normalizado_cnpj'], issuer['cnpj']]) ?? '';

      final addressStr = issuer['endereco'] as String?;

      NfcInvoiceAddress? address;

      if (addressStr != null && addressStr.trim().isNotEmpty) {
        final parts = addressStr.split(',').map((s) => s.trim()).toList();
        String? city = issuer['municipio'] as String?;
        if (city != null && city.contains('-')) {
          city = city.split('-').last.trim();
        }
        address = NfcInvoiceAddress(
          street: parts.isNotEmpty ? parts[0] : null,
          number: parts.length > 1 ? parts[1] : null,
          complement: parts.length > 2 && parts[2] != '.' ? parts[2] : null,
          neighborhood: issuer['bairro'] as String?,
          city: city,
          uf: issuer['uf'] as String?,
          zipCode: issuer['cep'] as String?,
        );
      }

      final emissionDateStr =
          (info['data_emissao'] ?? nfe['data_emissao']) as String?;

      DateTime emissionDate;
      try {
        if (emissionDateStr != null) {
          final clean = emissionDateStr.split(' ')[0].trim();
          emissionDate = clean.contains('/')
              ? DateTime.parse(clean.split('/').reversed.join('-'))
              : DateTime.parse(clean);
        } else {
          emissionDate = DateTime.now();
        }
      } catch (_) {
        emissionDate = DateTime.now();
      }

      final items = products.map((p) {
        final d = p as Map<String, dynamic>;
        final qty = _parseDouble(
          d['normalizado_quantidade'] ?? d['quantidade'] ?? d['qtd'],
        );
        final tPrice = _parseDouble(
          d['normalizado_valor_total_produto'] ??
              d['normalizado_valor'] ??
              d['valor_total_produto'] ??
              d['valor'],
        );
        final unitPrice = d['normalizado_valor_unitario'] != null
            ? _parseDouble(d['normalizado_valor_unitario'])
            : d['valor_unitario_comercial'] != null
            ? _parseDouble(d['valor_unitario_comercial'])
            : (qty > 0 ? tPrice / qty : tPrice);

      
        return NfcInvoiceItem(
          name: (d['nome'] ?? d['descricao'] ?? 'Produto') as String,
          quantity: qty,
          unit: (d['unidade'] ?? d['unidade_comercial'] ?? 'UN') as String,
          unitPrice: unitPrice,
          totalPrice: tPrice,
        );
      }).toList();

      var totalValue = _parseDouble(
        entry['normalizado_valor_a_pagar'] ??
            totals['normalizado_valor_nfe'] ??
            totals['valor_nfe'] ??
            entry['valor_a_pagar'],
      );
      if (totalValue == 0.0 && items.isNotEmpty) {
        totalValue = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      }

      return NfcInvoice(
        supermarketName: supermarketName,
        cnpj: cnpj,
        date: emissionDate,
        accessKey: accessKey,
        items: items,
        totalValue: totalValue,
        address: address,
      );
    } catch (e) {
      rethrow;
    }
  }

  static String? extractKeyFromUrl(String url) {
    try {
      final uri = Uri.parse(url);

      final pParam = uri.queryParameters['p'];
      if (pParam != null && pParam.isNotEmpty) {
        final key = pParam.split('|')[0].replaceAll(RegExp(r'[^0-9]'), '');
        if (key.length == 44) return key;
      }

      final keyParam =
          uri.queryParameters['chNFe'] ?? uri.queryParameters['chave'];

      if (keyParam != null) {
        
        final key = keyParam.replaceAll(RegExp(r'[^0-9]'), '');

        if (key.length == 44) {
          return key;
        }
      }

      final digits = url.replaceAll(RegExp(r'[^0-9]'), '');
      final match = RegExp(r'\d{44}').firstMatch(digits);
      if (match != null) return match.group(0);
    } catch (e) {
      throw Exception('Erro ao extrair chave de acesso da URL');
    }
    return null;
  }

  static String? _firstNonEmpty(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c is String && c.isNotEmpty) return c;
    }
    return null;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0.0;
  }
}
