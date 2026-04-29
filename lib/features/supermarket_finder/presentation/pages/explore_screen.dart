import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supermarkets = [
      _Supermarket(
        name: 'Bretas - Centro',
        distance: '1.2 km',
        address: 'Rua dos Andradas, 1234',
        color: const Color(0xFFE53935),
      ),
      _Supermarket(
        name: 'Supermercado BH - Savassi',
        distance: '2.5 km',
        address: 'Av. Getúlio Vargas, 567',
        color: const Color(0xFF1E88E5),
      ),
      _Supermarket(
        name: 'EPA - Funcionários',
        distance: '3.1 km',
        address: 'Rua Pernambuco, 890',
        color: const Color(0xFF43A047),
      ),
      _Supermarket(
        name: 'Verdemar - Lourdes',
        distance: '4.0 km',
        address: 'Av. do Contorno, 1100',
        color: const Color(0xFFFFA000),
      ),
      _Supermarket(
        name: 'BH Atacadista - Barreiro',
        distance: '6.8 km',
        address: 'Av. Amazonas, 2000',
        color: const Color(0xFF7B1FA2),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: Colors.white, size: 26),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explorar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Mercados próximos',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded),
                    color: Colors.white,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Search / Location Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.my_location_rounded,
                        color: Color(0xFF2196F3), size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Sua localização atual',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Mock Map
            Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Map pins
                  Positioned(
                    left: 60,
                    top: 50,
                    child: _buildMapPin(const Color(0xFFE53935)),
                  ),
                  Positioned(
                    left: 140,
                    top: 80,
                    child: _buildMapPin(const Color(0xFF1E88E5)),
                  ),
                  Positioned(
                    right: 100,
                    top: 120,
                    child: _buildMapPin(const Color(0xFF43A047)),
                  ),
                  Positioned(
                    right: 50,
                    bottom: 40,
                    child: _buildMapPin(const Color(0xFFFFA000)),
                  ),
                  // "Map" label
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_rounded,
                              size: 16, color: Color(0xFF2196F3)),
                          SizedBox(width: 6),
                          Text(
                            'Mapa interativo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Supermarkets title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Mercados próximos',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${supermarkets.length} encontrados',
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            // Supermarkets List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: supermarkets.length,
                itemBuilder: (context, index) =>
                    _buildSupermarketCard(context, supermarkets[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPin(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: color, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildSupermarketCard(BuildContext context, _Supermarket market) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: market.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  market.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                market.distance,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  market.address,
                  style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Selecionar rota',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Supermarket {
  final String name;
  final String distance;
  final String address;
  final Color color;

  const _Supermarket({
    required this.name,
    required this.distance,
    required this.address,
    required this.color,
  });
}
