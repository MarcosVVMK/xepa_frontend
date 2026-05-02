import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import '../../domain/entities/nfc_invoice.dart';
import '../../domain/entities/nfc_invoice_item.dart';

class NfcParserService {
  final ApiClient _apiClient;
  static const _tag = 'NfcParserService';

  NfcParserService(this._apiClient);

  Future<void> saveNfce(NfcInvoice invoice) async {
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
        'barcode': item.barcode,
      }).toList(),
    };

    try {
      final response = await _apiClient.dio.post(
        '/nfce/save',
        data: payload,
      );
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        throw Exception(e.response!.data['error'] ?? 'Erro ao salvar dados da nota');
      }
      throw Exception('Erro de conexão ao salvar nota');
    }
  }

  Future<NfcInvoice> consultByAccessKey(String accessKey) async {
    final cleaned = accessKey.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length != 44) {
      throw Exception('Chave de acesso deve conter 44 dígitos');
    }

    try {
      final response = await _apiClient.dio.post(
        '/nfce/consult',
        data: {'chave_acesso': cleaned},
      );

      final data = response.data;
      return _mapResponseToInvoice(data, cleaned);
    } on DioException catch (e, stack) {
      dev.log('DioException ao consultar NFC-e', error: e, stackTrace: stack);
      if (e.response != null && e.response!.data is Map) {
        final errorMsg = e.response!.data['error'] ?? 'Erro desconhecido';
        throw Exception(errorMsg);
      }
      throw Exception('Erro de conexão com o servidor: ${e.type} - ${e.message}');
    } catch (e, stack) {
      dev.log('Erro genérico ao consultar NFC-e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<NfcInvoice> parseUrl(String url) async {
    try {
      final accessKey = _extractChaveFromUrl(url);

      if (accessKey != null) {
        return await consultByAccessKey(accessKey);
      }
      throw Exception('Não foi possível extrair a chave de acesso da URL');
    } catch (e, stack) {
      dev.log('Erro ao processar URL NFC-e', error: e, stackTrace: stack);
      rethrow;
    }
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

      final keyParam = uri.queryParameters['chNFe'] ?? uri.queryParameters['chave'];
      if (keyParam != null) {
        final key = keyParam.replaceAll(RegExp(r'[^0-9]'), '');
        if (key.length == 44) return key;
      }

      final digits = url.replaceAll(RegExp(r'[^0-9]'), '');
      final match = RegExp(r'\d{44}').firstMatch(digits);
      if (match != null) return match.group(0);

    } catch (e) {
      dev.log('Erro ao extrair chave de acesso', error: e);
    }
    return null;
  }

  NfcInvoice _mapResponseToInvoice(Map<String, dynamic> data, String accessKey) {
   try {
    final emitente = data['emitente'] as Map<String, dynamic>? ?? {};
    final produtos = data['produtos'] as List<dynamic>? ?? [];
    final totais = data['totais'] as Map<String, dynamic>? ?? {};
    final valores = data['valores'] as Map<String, dynamic>? ?? {};
    final infoNota = data['informacoes_nota'] as Map<String, dynamic>? ?? {};
    final nfe = data['nfe'] as Map<String, dynamic>? ?? {};

    final nomeEstabelecimento = emitente['nome_fantasia'] as String?
        ?? emitente['nome'] as String?
        ?? emitente['nome_razao_social'] as String?
        ?? emitente['razao_social'] as String?
        ?? 'Estabelecimento';

    final cnpj = emitente['cnpj'] as String? ?? '';
    final enderecoStr = emitente['endereco'] as String?;
    
    NfcInvoiceAddress? address;
    if (emitente.containsKey('bairro') && emitente.containsKey('municipio')) {
      String? street = enderecoStr;
      String? number;
      String? complement;
      
      if (enderecoStr != null) {
        final parts = enderecoStr.split(',').map((s) => s.trim()).toList();
        if (parts.isNotEmpty) street = parts[0];
        if (parts.length > 1) number = parts[1];
        if (parts.length > 2) complement = parts[2] == '.' ? null : parts[2];
      }
      
      String? city = emitente['municipio'] as String?;
      if (city != null && city.contains('-')) {
        city = city.split('-').last.trim();
      }

      address = NfcInvoiceAddress(
        street: street,
        number: number,
        complement: complement,
        neighborhood: emitente['bairro'] as String?,
        city: city,
        uf: emitente['uf'] as String?,
        zipCode: emitente['cep'] as String?,
      );
    } else {
      address = _parseAddress(enderecoStr);
    }

    final dataEmissaoStr = infoNota['data_emissao'] as String? ?? nfe['data_emissao'] as String?;
    DateTime dataEmissao;
    try {
      if (dataEmissaoStr != null) {
        // Formatos: "16/03/2026" ou "16/03/2026 11:47:38-03:00"
        final datePart = dataEmissaoStr.split(' ')[0];
        dataEmissao = datePart.contains('/') 
            ? DateTime.parse(datePart.split('/').reversed.join('-'))
            : DateTime.parse(datePart);
      } else {
        dataEmissao = DateTime.now();
      }
    } catch (_) {
      dataEmissao = DateTime.now();
    }

    final items = produtos.map((p) {
      final prod = p as Map<String, dynamic>;
      final qty = _parseDouble(prod['qtd'] ?? prod['quantidade'] ?? prod['normalizado_quantidade']);
      final tPrice = _parseDouble(prod['valor'] ?? prod['normalizado_valor'] ?? prod['valor_total'] ?? prod['valor_total_produto'] ?? prod['normalizado_valor_total_produto'] ?? prod['valor_produto']);
      final uPrice = prod['valor_unitario'] != null || prod['normalizado_valor_unitario'] != null
          ? _parseDouble(prod['valor_unitario'] ?? prod['normalizado_valor_unitario'])
          : (qty > 0 ? tPrice / qty : tPrice);

      String? barcode;
      if (prod['ean_comercial'] != null && prod['ean_comercial'] != 'SEM GTIN') {
        barcode = prod['ean_comercial'] as String?;
      } else if (prod['ean_tributavel'] != null && prod['ean_tributavel'] != 'SEM GTIN') {
        barcode = prod['ean_tributavel'] as String?;
      }

      return NfcInvoiceItem(
        name: prod['descricao'] as String? ?? prod['nome'] as String? ?? 'Produto',
        quantity: qty,
        unit: prod['unidade'] as String? ?? prod['unidade_comercial'] as String? ?? 'UN',
        unitPrice: uPrice,
        totalPrice: tPrice,
        barcode: barcode,
      );
    }).toList();

    var totalValue = _parseDouble(
      valores['total'] ??
      nfe['valor_total'] ??
      nfe['normalizado_valor_total'] ??
      data['valor_total'] ?? 
      data['valor_a_pagar'] ?? 
      data['normalizado_valor_a_pagar'] ??
      data['normalizado_valor_total'] ??
      (data['valor'] != null && data['valor'] is Map ? data['valor']['total'] : null) ??
      totais['valor_nfe'] ??
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
      accessKey: accessKey,
      items: items,
      totalValue: totalValue,
      address: address,
    );
   } catch (e, stack) {
     dev.log('Erro fatal no mapeamento do JSON', error: e, stackTrace: stack);
     rethrow;
   }
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
