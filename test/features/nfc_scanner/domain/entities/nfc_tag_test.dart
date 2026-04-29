import 'package:flutter_test/flutter_test.dart';

class NfcTag {
  final String id;
  final String code;
  final String label;
  final DateTime registeredAt;
  final int itemCount;

  const NfcTag({
    required this.id,
    required this.code,
    required this.label,
    required this.registeredAt,
    this.itemCount = 0,
  });

  bool get isValid => code.isNotEmpty && code.startsWith('NFC-');

  String get formattedDate =>
      '${registeredAt.day.toString().padLeft(2, '0')}/${registeredAt.month.toString().padLeft(2, '0')}/${registeredAt.year}';
}

class NfcCodeValidator {
  static bool isValidCode(String code) {
    if (code.isEmpty) return false;
    // Must match NFC-YYYY-XXXX pattern
    final regex = RegExp(r'^NFC-\d{4}-\d{4}$');
    return regex.hasMatch(code);
  }

  static bool isValidQrData(String data) {
    return data.isNotEmpty && data.length >= 4;
  }

  static String? extractCodeFromQr(String qrData) {
    // QR data might contain a URL or raw code
    if (NfcCodeValidator.isValidCode(qrData)) return qrData;

    // Try to extract from URL
    final regex = RegExp(r'NFC-\d{4}-\d{4}');
    final match = regex.firstMatch(qrData);
    return match?.group(0);
  }
}

  void group('NfcTag', () {
    test('should store all properties correctly', () {
      final tag = NfcTag(
        id: '1',
        code: 'NFC-2026-0001',
        label: 'Geladeira',
        registeredAt: DateTime(2026, 4, 15),
        itemCount: 5,
      );

      expect(tag.id, '1');
      expect(tag.code, 'NFC-2026-0001');
      expect(tag.label, 'Geladeira');
      expect(tag.itemCount, 5);
    });

    test('should have default itemCount of 0', () {
      final tag = NfcTag(
        id: '2',
        code: 'NFC-2026-0002',
        label: 'Despensa',
        registeredAt: DateTime(2026, 4, 20),
      );
      expect(tag.itemCount, 0);
    });

    test('isValid should return true for valid NFC code', () {
      final tag = NfcTag(
        id: '1',
        code: 'NFC-2026-0001',
        label: 'Test',
        registeredAt: DateTime.now(),
      );
      expect(tag.isValid, true);
    });

    test('isValid should return false for invalid code', () {
      final tag = NfcTag(
        id: '1',
        code: 'INVALID',
        label: 'Test',
        registeredAt: DateTime.now(),
      );
      expect(tag.isValid, false);
    });

    test('isValid should return false for empty code', () {
      final tag = NfcTag(
        id: '1',
        code: '',
        label: 'Test',
        registeredAt: DateTime.now(),
      );
      expect(tag.isValid, false);
    });

    test('formattedDate should format correctly', () {
      final tag = NfcTag(
        id: '1',
        code: 'NFC-2026-0001',
        label: 'Test',
        registeredAt: DateTime(2026, 4, 5),
      );
      expect(tag.formattedDate, '05/04/2026');
    });

    test('formattedDate should pad single digits', () {
      final tag = NfcTag(
        id: '1',
        code: 'NFC-2026-0001',
        label: 'Test',
        registeredAt: DateTime(2026, 1, 3),
      );
      expect(tag.formattedDate, '03/01/2026');
    });
  group('NfcCodeValidator', () {
    group('isValidCode', () {
      test('should return true for valid NFC code format', () {
        expect(NfcCodeValidator.isValidCode('NFC-2026-0001'), true);
        expect(NfcCodeValidator.isValidCode('NFC-1234-5678'), true);
        expect(NfcCodeValidator.isValidCode('NFC-9999-0000'), true);
      });

      test('should return false for invalid formats', () {
        expect(NfcCodeValidator.isValidCode(''), false);
        expect(NfcCodeValidator.isValidCode('NFC'), false);
        expect(NfcCodeValidator.isValidCode('NFC-123-456'), false);
        expect(NfcCodeValidator.isValidCode('INVALID-2026-0001'), false);
        expect(NfcCodeValidator.isValidCode('NFC-ABCD-0001'), false);
        expect(NfcCodeValidator.isValidCode('nfc-2026-0001'), false);
      });
    });

    group('isValidQrData', () {
      test('should return true for valid QR data', () {
        expect(NfcCodeValidator.isValidQrData('NFC-2026-0001'), true);
        expect(NfcCodeValidator.isValidQrData('some-data'), true);
      });

      test('should return false for empty or too short data', () {
        expect(NfcCodeValidator.isValidQrData(''), false);
        expect(NfcCodeValidator.isValidQrData('abc'), false);
      });
    });

    group('extractCodeFromQr', () {
      test('should extract code from raw NFC code', () {
        expect(
          NfcCodeValidator.extractCodeFromQr('NFC-2026-0001'),
          'NFC-2026-0001',
        );
      });

      test('should extract code from URL containing NFC code', () {
        expect(
          NfcCodeValidator.extractCodeFromQr(
              'https://xepa.com/tag/NFC-2026-0042'),
          'NFC-2026-0042',
        );
      });

      test('should return null for data without NFC code', () {
        expect(
          NfcCodeValidator.extractCodeFromQr('random-qr-data'),
          isNull,
        );
      });

      test('should return null for empty data', () {
        expect(NfcCodeValidator.extractCodeFromQr(''), isNull);
      });
    });
  });
}
