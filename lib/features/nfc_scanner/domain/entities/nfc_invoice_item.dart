class NfcInvoiceItem {
  final String? barcode;
  final String name;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;

  NfcInvoiceItem({
    this.barcode,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
  });
}
