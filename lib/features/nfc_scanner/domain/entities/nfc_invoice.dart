import 'nfc_invoice_item.dart';

class NfcInvoice {
  final String supermarketName;
  final String cnpj;
  final DateTime date;
  final double totalValue;
  final String accessKey;
  final List<NfcInvoiceItem> items;
  final bool isSimulation;

  NfcInvoice({
    required this.supermarketName,
    required this.cnpj,
    required this.date,
    required this.totalValue,
    required this.accessKey,
    required this.items,
    this.isSimulation = false,
  });
}
