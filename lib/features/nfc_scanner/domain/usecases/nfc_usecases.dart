import 'package:xepa_frontend/features/nfc_scanner/domain/entities/nfc_invoice.dart';
import 'package:xepa_frontend/features/nfc_scanner/domain/repositories/i_nfc_repository.dart';

class SaveNfceUseCase {
  final INfcRepository _repository;
  SaveNfceUseCase(this._repository);
  Future<void> call(NfcInvoice invoice) => _repository.saveNfce(invoice);
}

class ConsultNfceByKeyUseCase {
  final INfcRepository _repository;
  ConsultNfceByKeyUseCase(this._repository);
  Future<NfcInvoice> call(String accessKey) =>
      _repository.consultByAccessKey(accessKey);
}

class ParseNfceUrlUseCase {
  final INfcRepository _repository;
  ParseNfceUrlUseCase(this._repository);
  Future<NfcInvoice> call(String url) => _repository.parseUrl(url);
}
