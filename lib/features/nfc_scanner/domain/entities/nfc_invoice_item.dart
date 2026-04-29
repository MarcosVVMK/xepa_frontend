class NfcInvoiceItem {
  final String name;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;

  NfcInvoiceItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
  });
}
