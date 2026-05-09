import 'package:xepa_frontend/features/nfc_scanner/data/datasources/nfc_parser_service.dart';
import 'package:xepa_frontend/features/nfc_scanner/domain/entities/nfc_invoice.dart';
import 'package:xepa_frontend/features/nfc_scanner/domain/repositories/i_nfc_repository.dart';

class NfcRepositoryImpl implements INfcRepository {
  final NfcRemoteDataSource _dataSource;

  NfcRepositoryImpl(this._dataSource);

  @override
  Future<void> saveNfce(NfcInvoice invoice) => _dataSource.saveNfce(invoice);

  @override
  Future<NfcInvoice> consultByAccessKey(String accessKey) =>
      _dataSource.consultByAccessKey(accessKey);

  @override
  Future<NfcInvoice> parseUrl(String url) => _dataSource.parseUrl(url);
}
