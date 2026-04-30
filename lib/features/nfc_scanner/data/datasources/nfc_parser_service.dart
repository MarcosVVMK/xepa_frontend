import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import '../../domain/entities/nfc_invoice.dart';
import '../../domain/entities/nfc_invoice_item.dart';

class NfcParserService {
  final ApiClient _apiClient;
  static const _tag = 'NfcParserService';

  NfcParserService(this._apiClient);

  Future<void> salvarNfce(NfcInvoice invoice) async {
    dev.log('[$_tag] Salvando NFC-e para o estabelecimento ${invoice.supermarketName}', name: _tag);
    
    final payload = {
      'supermarketName': invoice.supermarketName,
      'cnpj': invoice.cnpj,
      'accessKey': invoice.accessKey,
      'totalValue': invoice.totalValue,
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
      dev.log('[$_tag] NFC-e salva com sucesso: status=${response.statusCode}', name: _tag);
    } on DioException catch (e) {
      dev.log('[$_tag] DioException ao salvar: ${e.message}', name: _tag);
      if (e.response != null && e.response!.data is Map) {
        throw Exception(e.response!.data['error'] ?? 'Erro ao salvar dados da nota');
      }
      throw Exception('Erro de conexão ao salvar nota');
    }
  }

  Future<NfcInvoice> consultarPorChaveAcesso(String chaveAcesso) async {
    final cleaned = chaveAcesso.replaceAll(RegExp(r'[^0-9]'), '');
    dev.log('[$_tag] Chave de acesso recebida: ${chaveAcesso.substring(0, 10)}...', name: _tag);
    dev.log('[$_tag] Chave limpa (${cleaned.length} dígitos): ${cleaned.substring(0, 10)}...', name: _tag);

    if (cleaned.length != 44) {
      dev.log('[$_tag] ERRO: Chave inválida - ${cleaned.length} dígitos (esperados 44)', name: _tag);
      throw Exception('Chave de acesso deve conter 44 dígitos');
    }

    final baseUrl = _apiClient.dio.options.baseUrl;
    final fullUrl = '$baseUrl/nfce/consulta';
    dev.log('[$_tag] POST $fullUrl', name: _tag);

    try {
      final response = await _apiClient.dio.post(
        '/nfce/consulta',
        data: {'chave_acesso': cleaned},
      );

      dev.log('[$_tag] Resposta: status=${response.statusCode}', name: _tag);
      dev.log('[$_tag] Response data type: ${response.data.runtimeType}', name: _tag);
      dev.log('[$_tag] Response data: ${response.data}', name: _tag);

      final data = response.data;
      return _mapResponseToInvoice(data, cleaned);
    } on DioException catch (e) {
      dev.log('[$_tag] DioException: type=${e.type}', name: _tag);
      dev.log('[$_tag] DioException: message=${e.message}', name: _tag);
      dev.log('[$_tag] DioException: requestUrl=${e.requestOptions.uri}', name: _tag);
      dev.log('[$_tag] DioException: responseStatus=${e.response?.statusCode}', name: _tag);
      dev.log('[$_tag] DioException: responseData=${e.response?.data}', name: _tag);

      if (e.response != null && e.response!.data is Map) {
        final errorMsg = e.response!.data['error'] ?? 'Erro desconhecido';
        throw Exception(errorMsg);
      }
      throw Exception('Erro de conexão com o servidor: ${e.type} - ${e.message}');
    } catch (e) {
      dev.log('[$_tag] Erro genérico: $e', name: _tag);
      rethrow;
    }
  }

  Future<NfcInvoice> parseUrl(String url) async {
    dev.log('[$_tag] parseUrl chamado com: $url', name: _tag);
    final chaveAcesso = _extractChaveFromUrl(url);
    dev.log('[$_tag] Chave extraída: $chaveAcesso', name: _tag);

    if (chaveAcesso != null) {
      return consultarPorChaveAcesso(chaveAcesso);
    }
    throw Exception('Não foi possível extrair a chave de acesso da URL');
  }

  String? _extractChaveFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      dev.log('[$_tag] URI parsed - host: ${uri.host}, params: ${uri.queryParameters}', name: _tag);

      final pParam = uri.queryParameters['p'];
      if (pParam != null && pParam.isNotEmpty) {
        final parts = pParam.split('|');
        dev.log('[$_tag] Param p encontrado, parts[0]: ${parts[0]}', name: _tag);
        final key = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
        if (key.length == 44) return key;
        dev.log('[$_tag] Chave do param p tem ${key.length} dígitos, esperados 44', name: _tag);
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
      dev.log('[$_tag] Erro ao extrair chave: $e', name: _tag);
    }
    return null;
  }

  NfcInvoice _mapResponseToInvoice(Map<String, dynamic> data, String chaveAcesso) {
    dev.log('[$_tag] Mapeando resposta para NfcInvoice', name: _tag);

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

    dev.log('[$_tag] Emitente: $nomeEstabelecimento (CNPJ: $cnpj)', name: _tag);
    dev.log('[$_tag] Produtos encontrados: ${produtos.length}', name: _tag);

    final dataEmissaoStr = infoNota['data_emissao'] as String?;
    DateTime dataEmissao;
    try {
      dataEmissao = dataEmissaoStr != null
          ? (dataEmissaoStr.contains('/') 
              ? DateTime.parse(dataEmissaoStr.split('/').reversed.join('-')) // Convert DD/MM/YYYY to YYYY-MM-DD
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
      dev.log('[$_tag] Valor total era zero. Calculado pela soma dos itens: R\$ $totalValue', name: _tag);
    }

    dev.log('[$_tag] Total final: R\$ $totalValue, Itens: ${items.length}', name: _tag);

    return NfcInvoice(
      supermarketName: nomeEstabelecimento,
      cnpj: cnpj,
      date: dataEmissao,
      accessKey: chaveAcesso,
      items: items,
      totalValue: totalValue,
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final str = value.toString().replaceAll(',', '.');
    return double.tryParse(str) ?? 0.0;
  }
}
