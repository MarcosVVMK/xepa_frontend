import 'package:flutter_test/flutter_test.dart';

class Supermarket {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final bool isOpen;
  final String openingHours;

  const Supermarket({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.isOpen = true,
    this.openingHours = '08:00 - 22:00',
  });

  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}

class SupermarketSorter {
  static List<Supermarket> sortByDistance(List<Supermarket> markets) {
    final sorted = List<Supermarket>.from(markets);
    sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return sorted;
  }

  static List<Supermarket> filterOpen(List<Supermarket> markets) {
    return markets.where((m) => m.isOpen).toList();
  }

  static List<Supermarket> filterByRadius(
      List<Supermarket> markets, double maxKm) {
    return markets.where((m) => m.distanceKm <= maxKm).toList();
  }

  static List<Supermarket> searchByName(
      List<Supermarket> markets, String query) {
    if (query.isEmpty) return markets;
    final lower = query.toLowerCase();
    return markets
        .where((m) => m.name.toLowerCase().contains(lower))
        .toList();
  }
}

void main() {
  final tSupermarkets = [
    const Supermarket(
      id: '1',
      name: 'Bretas - Centro',
      address: 'Rua da Bahia, 1234',
      latitude: -19.9167,
      longitude: -43.9345,
      distanceKm: 1.2,
      isOpen: true,
    ),
    const Supermarket(
      id: '2',
      name: 'EPA - Funcionários',
      address: 'Av. do Contorno, 5678',
      latitude: -19.9300,
      longitude: -43.9400,
      distanceKm: 3.1,
      isOpen: true,
    ),
    const Supermarket(
      id: '3',
      name: 'Verdemar - Lourdes',
      address: 'Rua Pernambuco, 900',
      latitude: -19.9250,
      longitude: -43.9380,
      distanceKm: 0.8,
      isOpen: false,
    ),
    const Supermarket(
      id: '4',
      name: 'Supermercado BH - Savassi',
      address: 'Av. Cristóvão Colombo, 300',
      latitude: -19.9350,
      longitude: -43.9320,
      distanceKm: 5.5,
      isOpen: true,
    ),
  ];

  group('Supermarket', () {
    test('should store all properties correctly', () {
      const market = Supermarket(
        id: '1',
        name: 'Bretas',
        address: 'Rua da Bahia',
        latitude: -19.9167,
        longitude: -43.9345,
        distanceKm: 1.2,
      );
      expect(market.name, 'Bretas');
      expect(market.isOpen, true);
      expect(market.openingHours, '08:00 - 22:00');
    });

    test('formattedDistance should show km for >= 1km', () {
      const market = Supermarket(
        id: '1',
        name: 'Test',
        address: 'Test',
        latitude: 0,
        longitude: 0,
        distanceKm: 2.5,
      );
      expect(market.formattedDistance, '2.5 km');
    });

    test('formattedDistance should show meters for < 1km', () {
      const market = Supermarket(
        id: '1',
        name: 'Test',
        address: 'Test',
        latitude: 0,
        longitude: 0,
        distanceKm: 0.35,
      );
      expect(market.formattedDistance, '350 m');
    });

    test('formattedDistance should handle exactly 1km', () {
      const market = Supermarket(
        id: '1',
        name: 'Test',
        address: 'Test',
        latitude: 0,
        longitude: 0,
        distanceKm: 1.0,
      );
      expect(market.formattedDistance, '1.0 km');
    });
  });

  group('SupermarketSorter', () {
    group('sortByDistance', () {
      test('should sort markets from closest to farthest', () {
        final sorted = SupermarketSorter.sortByDistance(tSupermarkets);

        expect(sorted[0].name, 'Verdemar - Lourdes');
        expect(sorted[1].name, 'Bretas - Centro');
        expect(sorted[2].name, 'EPA - Funcionários');
        expect(sorted[3].name, 'Supermercado BH - Savassi');
      });

      test('should not modify original list', () {
        final original = List<Supermarket>.from(tSupermarkets);
        SupermarketSorter.sortByDistance(tSupermarkets);

        expect(tSupermarkets[0].id, original[0].id);
      });

      test('should handle empty list', () {
        final result = SupermarketSorter.sortByDistance([]);
        expect(result, isEmpty);
      });
    });

    group('filterOpen', () {
      test('should return only open markets', () {
        final open = SupermarketSorter.filterOpen(tSupermarkets);

        expect(open.length, 3);
        expect(open.every((m) => m.isOpen), true);
      });

      test('should exclude closed markets', () {
        final open = SupermarketSorter.filterOpen(tSupermarkets);
        expect(open.any((m) => m.name.contains('Verdemar')), false);
      });
    });

    group('filterByRadius', () {
      test('should return markets within radius', () {
        final nearby = SupermarketSorter.filterByRadius(tSupermarkets, 2.0);

        expect(nearby.length, 2);
        expect(nearby.any((m) => m.name.contains('Verdemar')), true);
        expect(nearby.any((m) => m.name.contains('Bretas')), true);
      });

      test('should return all markets with large radius', () {
        final all = SupermarketSorter.filterByRadius(tSupermarkets, 100.0);
        expect(all.length, 4);
      });

      test('should return empty with very small radius', () {
        final none = SupermarketSorter.filterByRadius(tSupermarkets, 0.1);
        expect(none, isEmpty);
      });
    });

    group('searchByName', () {
      test('should find markets by partial name', () {
        final results =
            SupermarketSorter.searchByName(tSupermarkets, 'bretas');
        expect(results.length, 1);
        expect(results.first.name, 'Bretas - Centro');
      });

      test('should be case-insensitive', () {
        final results =
            SupermarketSorter.searchByName(tSupermarkets, 'EPA');
        expect(results.length, 1);
      });

      test('should return all markets for empty query', () {
        final results = SupermarketSorter.searchByName(tSupermarkets, '');
        expect(results.length, 4);
      });

      test('should return empty for non-matching query', () {
        final results =
            SupermarketSorter.searchByName(tSupermarkets, 'Carrefour');
        expect(results, isEmpty);
      });
    });
  });
}
