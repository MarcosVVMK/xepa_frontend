import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import '../../domain/entities/nfc_invoice.dart';
import '../../domain/entities/nfc_invoice_item.dart';

class NfcParserService {
  final ApiClient _apiClient;
  static const _tag = 'NfcParserService';

  NfcParserService(this._apiClient);

  Future<void> salvarNfce(NfcInvoice invoice) async {
    final payload = {
      'supermarketName': invoice.supermarketName,
      'cnpj': invoice.cnpj,
      'accessKey': invoice.accessKey,
      'totalValue': invoice.totalValue,
      'address': invoice.address?.toJson(),
      'items': invoice.items.map((item) => {
        'name': item.name,
        'quantity': item.quantity,
        'unit': item.unit,
        'unitPrice': item.unitPrice,
        'totalPrice': item.totalPrice,
      }).toList(),
    };

    try {
      final response = await _apiClient.dio.post(
        '/nfce/salvar',
        data: payload,
      );
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw Exception(e.response!.data['error'] ?? 'Erro ao salvar dados da nota');
      }
      throw Exception('Erro de conexão ao salvar nota');
    }
  }

  Future<NfcInvoice> consultarPorChaveAcesso(String chaveAcesso) async {
    final cleaned = chaveAcesso.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length != 44) {
      throw Exception('Chave de acesso deve conter 44 dígitos');
    }

    try {
      final response = await _apiClient.dio.post(
        '/nfce/consulta',
        data: {'chave_acesso': cleaned},
      );

      final data = response.data;
      return _mapResponseToInvoice(data, cleaned);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final errorMsg = e.response!.data['error'] ?? 'Erro desconhecido';
        throw Exception(errorMsg);
      }
      throw Exception('Erro de conexão com o servidor: ${e.type} - ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<NfcInvoice> parseUrl(String url) async {
    final chaveAcesso = _extractChaveFromUrl(url);

    if (chaveAcesso != null) {
      return consultarPorChaveAcesso(chaveAcesso);
    }
    throw Exception('Não foi possível extrair a chave de acesso da URL');
  }

  String? _extractChaveFromUrl(String url) {
    try {
      final uri = Uri.parse(url);

      final pParam = uri.queryParameters['p'];
      if (pParam != null && pParam.isNotEmpty) {
        final parts = pParam.split('|');
        final key = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
        if (key.length == 44) return key;
      }

      final chaveParam = uri.queryParameters['chNFe'] ?? uri.queryParameters['chave'];
      if (chaveParam != null) {
        final key = chaveParam.replaceAll(RegExp(r'[^0-9]'), '');
        if (key.length == 44) return key;
      }

      final digits = url.replaceAll(RegExp(r'[^0-9]'), '');
      final match = RegExp(r'\d{44}').firstMatch(digits);
      if (match != null) return match.group(0);

    } catch (e) {
      // Ignora e retorna null
    }
    return null;
  }

  NfcInvoice _mapResponseToInvoice(Map<String, dynamic> data, String chaveAcesso) {
    final emitente = data['emitente'] as Map<String, dynamic>? ?? {};
    final produtos = data['produtos'] as List<dynamic>? ?? [];
    final totais = data['totais'] as Map<String, dynamic>? ?? {};
    final valores = data['valores'] as Map<String, dynamic>? ?? {};
    final infoNota = data['informacoes_nota'] as Map<String, dynamic>? ?? {};

    final nomeEstabelecimento = emitente['nome_razao_social'] as String?
        ?? emitente['nome_fantasia'] as String?
        ?? emitente['razao_social'] as String?
        ?? 'Estabelecimento';

    final cnpj = emitente['cnpj'] as String? ?? '';
    final enderecoStr = emitente['endereco'] as String?;
    final address = _parseAddress(enderecoStr);

    final dataEmissaoStr = infoNota['data_emissao'] as String?;
    DateTime dataEmissao;
    try {
      dataEmissao = dataEmissaoStr != null
          ? (dataEmissaoStr.contains('/') 
              ? DateTime.parse(dataEmissaoStr.split('/').reversed.join('-'))
              : DateTime.parse(dataEmissaoStr))
          : DateTime.now();
    } catch (_) {
      dataEmissao = DateTime.now();
    }

    final items = produtos.map((p) {
      final prod = p as Map<String, dynamic>;
      final qty = _parseDouble(prod['quantidade'] ?? prod['normalizado_quantidade']);
      final tPrice = _parseDouble(prod['valor_total'] ?? prod['valor_total_produto'] ?? prod['normalizado_valor_total_produto']);
      final uPrice = prod['valor_unitario'] != null || prod['normalizado_valor_unitario'] != null
          ? _parseDouble(prod['valor_unitario'] ?? prod['normalizado_valor_unitario'])
          : (qty > 0 ? tPrice / qty : tPrice);

      return NfcInvoiceItem(
        name: prod['nome'] as String? ?? 'Produto',
        quantity: qty,
        unit: prod['unidade'] as String? ?? 'UN',
        unitPrice: uPrice,
        totalPrice: tPrice,
      );
    }).toList();

    var totalValue = _parseDouble(
      valores['total'] ??
      data['valor_total'] ?? 
      data['valor_a_pagar'] ?? 
      data['normalizado_valor_a_pagar'] ??
      data['normalizado_valor_total'] ??
      (data['valor'] != null && data['valor'] is Map ? data['valor']['total'] : null) ??
      totais['valor_total'] ?? 
      totais['valor_a_pagar']
    );

    if (totalValue == 0.0 && items.isNotEmpty) {
      totalValue = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    }

    return NfcInvoice(
      supermarketName: nomeEstabelecimento,
      cnpj: cnpj,
      date: dataEmissao,
      accessKey: chaveAcesso,
      items: items,
      totalValue: totalValue,
      address: address,
    );
  }

  NfcInvoiceAddress? _parseAddress(String? addressStr) {
    if (addressStr == null || addressStr.isEmpty) return null;
    final parts = addressStr.split(',').map((s) => s.trim()).toList();
    return NfcInvoiceAddress(
      street: parts.isNotEmpty ? parts[0] : null,
      number: parts.length > 1 ? parts[1] : null,
      complement: parts.length > 2 ? (parts[2] == '.' ? null : parts[2]) : null,
      neighborhood: parts.length > 3 ? parts[3] : null,
      city: parts.length > 4 ? parts[4] : null,
      uf: parts.length > 5 ? parts[5] : null,
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final str = value.toString().replaceAll(',', '.');
    return double.tryParse(str) ?? 0.0;
  }
}
