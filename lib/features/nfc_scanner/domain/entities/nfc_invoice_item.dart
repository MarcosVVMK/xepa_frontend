class NfcInvoiceItem {
  final String name;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final String? barcode;

  NfcInvoiceItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.barcode,
  });
}
