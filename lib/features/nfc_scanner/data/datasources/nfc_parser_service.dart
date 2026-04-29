import '../../domain/entities/nfc_invoice.dart';
import '../../domain/entities/nfc_invoice_item.dart';

class NfcParserService {
  static const Map<String, String> _supermarketMap = {
    '06047231000129': 'Supermercado Bretas',
    '75315333000109': 'Carrefour',
    '15427207000114': 'Supermercado BH',
    '01551326000140': 'Supermercado Moreira',
  };

  Future<NfcInvoice> parseUrl(String url) async {
    if (!url.contains('sefaz.go.gov.br')) {
      throw Exception('URL não reconhecida como padrão SEFAZ GO');
    }

    final uri = Uri.parse(url);
    final pParam = uri.queryParameters['p'];
    if (pParam == null || pParam.isEmpty) {
      throw Exception('Parâmetro p não encontrado na URL');
    }

    final parts = pParam.split('|');
    final accessKey = parts[0];
    if (accessKey.length < 44) {
      throw Exception('Chave de acesso inválida');
    }

    final uf = accessKey.substring(0, 2);
    if (uf != '52') {
      throw Exception('Nota Fiscal não pertence ao estado de Goiás (UF 52)');
    }

    final year = 2000 + int.parse(accessKey.substring(2, 4));
    final month = int.parse(accessKey.substring(4, 6));
    final cnpj = accessKey.substring(6, 20);

    final date = DateTime(year, month, 1);
    final supermarketName = _supermarketMap[cnpj] ?? 'Supermercado (GO)';

    return _generateSimulation(supermarketName, cnpj, date, accessKey);
  }

  NfcInvoice _generateSimulation(String supermarketName, String cnpj, DateTime date, String accessKey) {
    return NfcInvoice(
      supermarketName: supermarketName,
      cnpj: cnpj,
      date: date,
      accessKey: accessKey,
      items: [
        NfcInvoiceItem(
          name: 'Arroz Integral 1kg',
          quantity: 2.0,
          unit: 'UN',
          unitPrice: 7.50,
          totalPrice: 15.00,
        ),
        NfcInvoiceItem(
          name: 'Feijão Carioca 1kg',
          quantity: 1.0,
          unit: 'UN',
          unitPrice: 8.90,
          totalPrice: 8.90,
        ),
        NfcInvoiceItem(
          name: 'Óleo de Soja 900ml',
          quantity: 1.0,
          unit: 'UN',
          unitPrice: 6.45,
          totalPrice: 6.45,
        ),
        NfcInvoiceItem(
          name: 'Leite Integral 1L',
          quantity: 4.0,
          unit: 'UN',
          unitPrice: 4.99,
          totalPrice: 19.96,
        ),
        NfcInvoiceItem(
          name: 'Café Torrado 500g',
          quantity: 1.0,
          unit: 'UN',
          unitPrice: 14.50,
          totalPrice: 14.50,
        ),
      ],
      totalValue: 64.81,
    );
  }
}
