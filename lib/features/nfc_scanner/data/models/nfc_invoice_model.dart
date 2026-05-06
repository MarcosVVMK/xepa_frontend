import 'package:xepa_frontend/features/nfc_scanner/domain/entities/nfc_invoice.dart';
import 'package:xepa_frontend/features/nfc_scanner/domain/entities/nfc_invoice_item.dart';

class NfcInvoiceModel extends NfcInvoice {
  NfcInvoiceModel({
    required super.supermarketName,
    required super.cnpj,
    required super.date,
    required super.totalValue,
    required super.accessKey,
    required super.items,
    super.address,
    super.isSimulation,
  });

  Map<String, dynamic> toJson() {
    return {
      'supermarketName': supermarketName,
      'cnpj': cnpj,
      'date': date.toIso8601String(),
      'totalValue': totalValue,
      'accessKey': accessKey,
      'address': address?.toJson(),
      'items': items.map((i) => (i as NfcInvoiceItemModel).toJson()).toList(),
    };
  }
}

class NfcInvoiceItemModel extends NfcInvoiceItem {
  NfcInvoiceItemModel({
    required super.name,
    required super.quantity,
    required super.unit,
    required super.unitPrice,
    required super.totalPrice,
    super.barcode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'barcode': barcode,
    };
  }
}
