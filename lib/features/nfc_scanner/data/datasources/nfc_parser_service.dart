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
      'purchaseDate': invoice.date.toIso8601String(),
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

    dev.log('Iniciando salvamento da NFC-e. Supermercado: ${invoice.supermarketName}, CNPJ: ${invoice.cnpj}');
    dev.log('Payload enviado para nfce/save: $payload');

    try {
      final response = await _apiClient.dio.post(
        'nfce/save',
        data: payload,
      );
      dev.log('Resposta do salvamento da NFC-e: ${response.statusCode} - ${response.data}');
    } on DioException catch (e, stackTrace) {
      dev.log('Erro ao salvar NFC-e no backend. Status: ${e.response?.statusCode}', error: e, stackTrace: stackTrace);
      dev.log('Dados do erro: ${e.response?.data}');
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
    final entry = (data['data'] is List && (data['data'] as List).isNotEmpty)
        ? data['data'][0] as Map<String, dynamic>
        : data;

    final issuer   = entry['emitente'] as Map<String, dynamic>? ?? {};
    final products = entry['produtos']  as List<dynamic>? ?? [];
    final totals   = entry['totais']    as Map<String, dynamic>? ?? {};
    final info     = entry['informacoes_nota'] as Map<String, dynamic>? ?? {};
    final nfe      = entry['nfe']       as Map<String, dynamic>? ?? {};

    final supermarketName = (issuer['nome'] as String?)?.isNotEmpty == true
        ? issuer['nome'] as String
        : (issuer['nome_razao_social'] as String?)?.isNotEmpty == true
            ? issuer['nome_razao_social'] as String
            : (issuer['nome_fantasia'] as String?)?.isNotEmpty == true
                ? issuer['nome_fantasia'] as String
                : 'Estabelecimento';

    final cnpj = (issuer['normalizado_cnpj'] as String?)?.isNotEmpty == true
        ? issuer['normalizado_cnpj'] as String
        : issuer['cnpj'] as String? ?? '';
    final addressStr = issuer['endereco'] as String?;
    NfcInvoiceAddress? address;
    if (addressStr != null && addressStr.trim().isNotEmpty) {

      final parts = addressStr.split(',').map((s) => s.trim()).toList();
      String? city = issuer['municipio'] as String?;

      if (city != null && city.contains('-')) {
        city = city.split('-').last.trim();
      }
      address = NfcInvoiceAddress(
        street:       parts.isNotEmpty ? parts[0] : null,
        number:       parts.length > 1 ? parts[1] : null,
        complement:   parts.length > 2 && parts[2] != '.' ? parts[2] : null,
        neighborhood: issuer['bairro']  as String?,
        city:         city,
        uf:           issuer['uf']      as String?,
        zipCode:      issuer['cep']     as String?,
      );
    }

    final emissionDateStr = info['data_emissao'] as String? ?? nfe['data_emissao'] as String?;
    DateTime emissionDate;
    try {
      if (emissionDateStr != null) {
        final cleanedDate = emissionDateStr.split(' ')[0].trim();
        if (cleanedDate.contains('/')) {
           emissionDate = DateTime.parse(cleanedDate.split('/').reversed.join('-'));
        } else {
           emissionDate = DateTime.parse(cleanedDate);
        }
      } else {
        emissionDate = DateTime.now();
      }
    } catch (_) {
      emissionDate = DateTime.now();
    }

    final items = products.map((p) {
      final productData = p as Map<String, dynamic>;

      final qty = _parseDouble(
        productData['normalizado_quantidade'] ?? 
        productData['quantidade'] ?? 
        productData['qtd']
      );
      
      final tPrice = _parseDouble(
        productData['normalizado_valor_total_produto'] ?? 
        productData['normalizado_valor'] ?? 
        productData['valor_total_produto'] ??
        productData['valor']
      );

      final unitPrice = productData['normalizado_valor_unitario'] != null
          ? _parseDouble(productData['normalizado_valor_unitario'])
          : productData['valor_unitario_comercial'] != null
              ? _parseDouble(productData['valor_unitario_comercial'])
              : (qty > 0 ? tPrice / qty : tPrice);
              
      String? barcode;
      final eanComercial = productData['ean_comercial'] as String?;
      final eanTributavel = productData['ean_tributavel'] as String?;
      if (eanComercial != null && eanComercial != 'SEM GTIN') {
        barcode = eanComercial;
      } else if (eanTributavel != null && eanTributavel != 'SEM GTIN') {
        barcode = eanTributavel;
      }

      return NfcInvoiceItem(
        name:       productData['nome'] as String? 
                    ?? productData['descricao'] as String? 
                    ?? 'Produto',
        quantity:   qty,
        unit:       productData['unidade'] as String?
                    ?? productData['unidade_comercial'] as String?
                    ?? 'UN',
        unitPrice:  unitPrice,
        totalPrice: tPrice,
        barcode:    barcode,
      );
    }).toList();

    var totalValue = _parseDouble(
      entry['normalizado_valor_a_pagar'] ??
      totals['normalizado_valor_nfe'] ??
      totals['valor_nfe'] ??
      entry['valor_a_pagar']
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
   } catch (e, stack) {
     dev.log('Erro fatal no mapeamento do JSON', error: e, stackTrace: stack);
     rethrow;
   }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final str = value.toString().replaceAll(',', '.');
    return double.tryParse(str) ?? 0.0;
  }
}
