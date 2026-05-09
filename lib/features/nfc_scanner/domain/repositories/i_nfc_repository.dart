import 'package:xepa_frontend/features/nfc_scanner/domain/entities/nfc_invoice.dart';

abstract class INfcRepository {
  Future<void> saveNfce(NfcInvoice invoice);
  Future<NfcInvoice> consultByAccessKey(String accessKey);
  Future<NfcInvoice> parseUrl(String url);
}
