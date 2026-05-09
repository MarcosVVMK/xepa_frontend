import 'package:xepa_frontend/features/nfc_scanner/domain/entities/nfc_invoice.dart';

abstract class INfcDataSource {
  Future<void> saveNfce(NfcInvoice invoice);
  Future<NfcInvoice> consultByAccessKey(String accessKey);
}
