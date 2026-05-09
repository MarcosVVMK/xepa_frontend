import 'package:dio/dio.dart';
import 'package:xepa_frontend/core/api/api_client.dart';
import 'package:xepa_frontend/core/errors/dio_error_handler.dart';
import 'package:xepa_frontend/features/nfc_scanner/data/datasources/i_nfc_datasource.dart';
import 'package:xepa_frontend/features/nfc_scanner/data/datasources/nfc_parser.dart';
import '../../domain/entities/nfc_invoice.dart';

class NfcRemoteDataSource implements INfcDataSource {
  final ApiClient _apiClient;

  NfcRemoteDataSource(this._apiClient);

  @override
  Future<void> saveNfce(NfcInvoice invoice) async {
    final payload = {
      'supermarketName': invoice.supermarketName,
      'cnpj': invoice.cnpj,
      'accessKey': invoice.accessKey,
      'totalValue': invoice.totalValue,
      'purchaseDate': invoice.date.toIso8601String(),
      'address': invoice.address?.toJson(),
      'items': invoice.items
          .map((item) => {
                'name': item.name,
                'quantity': item.quantity,
                'unit': item.unit,
                'unitPrice': item.unitPrice,
                'totalPrice': item.totalPrice,
              })
          .toList(),
    };

    try {
      await _apiClient.dio.post('nfce/save', data: payload);
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(
        e,
        fallback: 'Erro ao salvar dados da nota',
      ));
    }
  }

  @override
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
      return NfcParser.mapResponseToInvoice(data, cleaned);
    } on DioException catch (e) {
      throw Exception(DioErrorHandler.extractMessage(
        e,
        fallback: 'Erro de conexão com o servidor',
      ));
    }
  }

  Future<NfcInvoice> parseUrl(String url) async {
    final accessKey = NfcParser.extractKeyFromUrl(url);
    if (accessKey == null) {
      throw Exception('Não foi possível extrair a chave de acesso da URL');
    }
    return consultByAccessKey(accessKey);
  }
}
