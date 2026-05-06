import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import '../../domain/entities/nfc_invoice.dart';
import '../../domain/entities/nfc_invoice_item.dart';

class NfcParserService {
  final ApiClient _apiClient;

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
      await _apiClient.dio.post(
        'nfce/save',
        data: payload,
      );
    } on DioException catch (e, stackTrace) {
      dev.log('Erro ao salvar NFC-e', error: e, stackTrace: stackTrace);
      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data as Map;
        throw Exception(data['error'] ?? 'Erro ao salvar dados da nota');
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
        'nfce/consult',
        data: {'chave_acesso': cleaned},
      );

      final data = response.data as Map<String, dynamic>;
      
      return _mapResponseToInvoice(data, cleaned);
    } on DioException catch (e, stack) {
      dev.log('DioException ao consultar NFC-e', error: e, stackTrace: stack);
      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data as Map;
        final errorMsg = data['error'] ?? 'Erro desconhecido';
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
      final accessKey = _extractKeyFromUrl(url);

      if (accessKey != null) {
        return await consultByAccessKey(accessKey);
      }
      throw Exception('Não foi possível extrair a chave de acesso da URL');
    } catch (e, stack) {
      dev.log('Erro ao processar URL NFC-e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  String? _extractKeyFromUrl(String url) {
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
    final issuer = data['emitente'] as Map<String, dynamic>? ?? {};
    final products = data['produtos'] as List<dynamic>? ?? [];
    final totals = data['totais'] as Map<String, dynamic>? ?? {};
    final values = data['valores'] as Map<String, dynamic>? ?? {};
    final invoiceInfo = data['informacoes_nota'] as Map<String, dynamic>? ?? {};
    final invoiceData = data['nfe'] as Map<String, dynamic>? ?? {};

    final establishmentName = issuer['nome'] as String?
        ?? issuer['nome_fantasia'] as String?
        ?? issuer['nome_razao_social'] as String?
        ?? issuer['razao_social'] as String?
        ?? 'Estabelecimento';

    final cnpj = issuer['cnpj'] as String? ?? '';
    final addressStr = issuer['endereco'] as String?;
    
    NfcInvoiceAddress? address;
    if (issuer.containsKey('endereco')) {
      String? street;
      String? number;
      String? complement;

      if (addressStr != null) {
        if (addressStr.contains(',')) {
          final parts = addressStr.split(',');
          street = parts[0].trim();
          number = parts[1].trim();
          if (parts.length > 2) {
            complement = parts.sublist(2).join(', ').trim();
          }
        } else {
          street = addressStr.trim();
          number = 'SN';
        }
      }

      String? city = issuer['municipio'] as String?;

      if (city != null && city.contains('-')) {
        city = city.split('-').last.trim();
      }

      address = NfcInvoiceAddress(
        street: street,
        number: number,
        complement: complement,
        neighborhood: issuer['bairro'] as String?,
        city: city,
        uf: issuer['uf'] as String?,
        zipCode: issuer['cep'] as String?,
      );
    } else {
      address = _parseAddress(addressStr);
    }

    final emissionDateStr = invoiceInfo['data_emissao'] as String? ?? invoiceData['data_emissao'] as String?;
    DateTime emissionDate;
    try {
      if (emissionDateStr != null) {
        final datePart = emissionDateStr.split(' ')[0];
        emissionDate = datePart.contains('/') 
            ? DateTime.parse(datePart.split('/').reversed.join('-'))
            : DateTime.parse(datePart);
      } else {
        emissionDate = DateTime.now();
      }
    } catch (_) {
      emissionDate = DateTime.now();
    }

    final items = products.map((p) {
      final productData = p as Map<String, dynamic>;
      final qty = _parseDouble(productData['qtd'] ?? productData['quantidade'] ?? productData['normalizado_quantidade']);
      final tPrice = _parseDouble(productData['valor'] ?? productData['normalizado_valor'] ?? productData['valor_total'] ?? productData['valor_total_produto'] ?? productData['normalizado_valor_total_produto'] ?? productData['valor_produto']);
      final uPrice = productData['valor_unitario'] != null || productData['normalizado_valor_unitario'] != null
          ? _parseDouble(productData['valor_unitario'] ?? productData['normalizado_valor_unitario'])
          : (qty > 0 ? tPrice / qty : tPrice);

      String? barcode;
      if (productData['ean_comercial'] != null && productData['ean_comercial'] != 'SEM GTIN') {
        barcode = productData['ean_comercial'] as String?;
      } else if (productData['ean_tributavel'] != null && productData['ean_tributavel'] != 'SEM GTIN') {
        barcode = productData['ean_tributavel'] as String?;
      }

      return NfcInvoiceItem(
        name: productData['descricao'] as String? ?? productData['nome'] as String? ?? 'Produto',
        quantity: qty,
        unit: productData['unidade'] as String? ?? productData['unidade_comercial'] as String? ?? 'UN',
        unitPrice: uPrice,
        totalPrice: tPrice,
        barcode: barcode,
      );
    }).toList();

    var totalValue = _parseDouble(
      values['total'] ??
      invoiceData['valor_total'] ??
      invoiceData['normalizado_valor_total'] ??
      data['valor_total'] ?? 
      data['valor_a_pagar'] ?? 
      data['normalizado_valor_a_pagar'] ??
      data['normalizado_valor_total'] ??
      (data['valor'] != null && data['valor'] is Map ? data['valor']['total'] : null) ??
      totals['valor_nfe'] ??
      totals['valor_total'] ?? 
      totals['valor_a_pagar']
    );

    if (totalValue == 0.0 && items.isNotEmpty) {
      totalValue = items.fold(0.0, (sum, item) => sum + item.totalPrice);
    }

    return NfcInvoice(
      supermarketName: establishmentName,
      cnpj: cnpj,
      date: emissionDate,
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
