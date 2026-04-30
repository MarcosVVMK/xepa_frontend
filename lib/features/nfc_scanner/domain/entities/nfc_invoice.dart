import 'nfc_invoice_item.dart';

class NfcInvoice {
  final String supermarketName;
  final String cnpj;
  final DateTime date;
  final double totalValue;
  final String accessKey;
  final List<NfcInvoiceItem> items;
  final NfcInvoiceAddress? address;
  final bool isSimulation;

  NfcInvoice({
    required this.supermarketName,
    required this.cnpj,
    required this.date,
    required this.totalValue,
    required this.accessKey,
    required this.items,
    this.address,
    this.isSimulation = false,
  });
}

class NfcInvoiceAddress {
  final String? street;
  final String? number;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? uf;

  NfcInvoiceAddress({
    this.street,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.uf,
  });

  Map<String, dynamic> toJson() => {
    'street': street,
    'number': number,
    'complement': complement,
    'neighborhood': neighborhood,
    'city': city,
    'uf': uf,
  };
}
