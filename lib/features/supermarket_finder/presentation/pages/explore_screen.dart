import 'package:flutter/material.dart';
import 'package:xepa_frontend/core/DI/dependency_injection.dart';
import 'package:xepa_frontend/features/supermarket_finder/data/datasources/supermarket_service.dart';
import 'package:xepa_frontend/features/auth/data/models/user_model.dart';
import 'package:xepa_frontend/core/auth/token_storage.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  final List<dynamic> _supermarkets = [];
  bool _showMap = false;
  LatLng? _userLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadClosestSupermarkets();
  }

  Future<void> _loadClosestSupermarkets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tokenStorage = getIt<TokenStorage>();
      final userJson = await tokenStorage.getUser();

      if (userJson != null) {
        final user = UserModel.fromJson(jsonDecode(userJson));
        if (user.address?.latitude != null && user.address?.longitude != null) {
          _userLocation = LatLng(user.address!.latitude!, user.address!.longitude!);
        }
      }

      final supermarketService = getIt<SupermarketService>();
      final results = await supermarketService.getClosestSupermarkets();
      
      if (mounted) {
        setState(() {
          _supermarkets.clear();
          _supermarkets.addAll(results);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchSupermarkets(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supermarketService = getIt<SupermarketService>();
      final results = await supermarketService.searchSupermarkets(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openExternalMap(double lat, double lng, String label) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
              decoration:  const BoxDecoration(
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
                    icon: Icon(_showMap ? Icons.list_rounded : Icons.map_rounded),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        _showMap = !_showMap;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _searchSupermarkets,
                  decoration: InputDecoration(
                    hintText: 'Buscar por Supermercado...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2196F3)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _searchSupermarkets('');
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children:  [
                  Text(
                    _searchResults.isEmpty ? 'Mercados próximos' : 'Resultados da busca',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _searchResults.isEmpty ? '${_supermarkets.length} encontrados' : '${_searchResults.length} mercados',
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) => _buildSupermarketCard(context, _searchResults[index]),
                      )
                    : _showMap
                        ? _buildMapView()
                        : _supermarkets.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.store_outlined, size: 80, color: Colors.grey[300]) ,
                                  const SizedBox(height: 16),
                                  Text(
                                    'Nenhum mercado encontrado',
                                    style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Verifique sua localização',
                                    style:TextStyle(fontSize: 14, color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _supermarkets.length,
                              itemBuilder: (context, index) =>
                                  _buildSupermarketCard(context, _supermarkets[index]),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    final center = _userLocation ?? const LatLng(-23.5505, -46.6333); // Default to SP if location not found
    
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.xepa.app',
        ),
        MarkerLayer(
          markers: [
            if (_userLocation != null)
              Marker(
                point: _userLocation!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ..._supermarkets.where((s) => s['address']?['latitude'] != null).map((s) {
              return Marker(
                point: LatLng(s['address']['latitude'], s['address']['longitude']),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    // Opcional: mostrar algo ao tocar no marcador
                  },
                  child: const Icon(
                    Icons.store_rounded,
                    color: Color(0xFF2196F3),
                    size: 30,
                  ),
                ),
              );
            }),
          ],
        ),
      ],
      mapController: _mapController,
    );
  }

  void _showOnMap(double lat, double lng) {
    setState(() {
      _showMap = true;
    });
    
    // Pequeno delay para garantir que o widget do mapa foi construído e o controlador anexado
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _mapController.move(LatLng(lat, lng), 16.0);
      }
    });
  }

  Widget _buildSupermarketCard(BuildContext context, dynamic market) {
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  market['name'] ?? 'Mercado',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                'Aprox. ${market['distance']?.toStringAsFixed(1) ?? '??'} km',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatAddress(market['address']),
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
              onPressed: () {
                final lat = market['address']?['latitude'];
                final lng = market['address']?['longitude'];
                if (lat != null && lng != null) {
                  _showOnMap(lat, lng);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Localização não disponível')),
                  );
                }
              },
              onLongPress: () {
                 final lat = market['address']?['latitude'];
                final lng = market['address']?['longitude'];
                if (lat != null && lng != null) {
                  _openExternalMap(lat, lng, market['name'] ?? 'Mercado');
                }
              },
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
                'Ver no mapa',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddress(Map<String, dynamic>? address) {
    if (address == null) return 'Endereço não disponível';
    
    final street = address['street'] ?? '';
    final number = address['number'] ?? '';
    final neighborhood = address['neighborhood'] ?? '';
    
    if (street.isEmpty) return 'Endereço incompleto';
    
    String formatted = street;
    if (number.isNotEmpty) formatted += ', $number';
    if (neighborhood.isNotEmpty) formatted += ' - $neighborhood';
    
    return formatted;
  }
}
