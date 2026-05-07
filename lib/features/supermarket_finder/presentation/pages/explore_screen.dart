import 'package:flutter/material.dart';
import 'package:xepa_frontend/core/DI/dependency_injection.dart';
import 'package:xepa_frontend/features/supermarket_finder/data/datasources/supermarket_service.dart';
import 'package:xepa_frontend/features/supermarket_finder/presentation/pages/supermarket_detail_screen.dart';
import 'package:xepa_frontend/features/supermarket_finder/data/models/supermarket_model.dart';
import 'package:xepa_frontend/features/auth/data/models/user_model.dart';
import 'package:xepa_frontend/core/auth/token_storage.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:xepa_frontend/features/product/data/datasources/product_service.dart';
import 'package:xepa_frontend/features/product/data/models/product_model.dart';
import 'package:xepa_frontend/features/product/presentation/pages/product_detail_screen.dart';
import 'package:xepa_frontend/features/profile/domain/entities/address.dart';


class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  List<SupermarketModel> _supermarketResults = [];
  List<ProductModel> _productResults = [];
  bool _isLoading = false;
  final List<SupermarketModel> _supermarkets = [];
  bool _showMap = false;
  LatLng? _userLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClosestSupermarkets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _supermarketResults = [];
        _productResults = [];
      });
      return;
    }

    if (_tabController.index == 0) {
      await _searchSupermarkets(query);
    } else {
      await _searchProducts(query);
    }
  }

  Future<void> _searchSupermarkets(String query) async {
    setState(() => _isLoading = true);
    try {
      final supermarketService = getIt<SupermarketService>();
      final results = await supermarketService.searchSupermarkets(query);
      if (mounted) {
        setState(() {
          _supermarketResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchProducts(String query) async {
    setState(() => _isLoading = true);
    try {
      final productService = getIt<ProductService>();
      final results = await productService.searchProducts(query);
      if (mounted) {
        setState(() {
          _productResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2196F3),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Colors.white, size: 26),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Explorar',
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Mercados e Produtos',
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
                        const SizedBox(height: 8),
                        TabBar(
                          controller: _tabController,
                          indicatorColor: Colors.white,
                          indicatorWeight: 3,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          tabs: const [
                            Tab(text: 'Mercados'),
                            Tab(text: 'Produtos'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                        onSubmitted: _handleSearch,
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2196F3)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _handleSearch('');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Markets Tab
                        _supermarketResults.isNotEmpty
                            ? ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                itemCount: _supermarketResults.length,
                                itemBuilder: (context, index) => _buildSupermarketCard(context, _supermarketResults[index]),
                              )
                            : _showMap
                                ? _buildMapView()
                                : ListView(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    children: [
                                      if (_supermarkets.isEmpty && !_isLoading)
                                        SizedBox(
                                          height: MediaQuery.of(context).size.height * 0.5,
                                          child: _buildEmptyState('Nenhum mercado encontrado'),
                                        )
                                      else
                                        ..._supermarkets.map((m) => _buildSupermarketCard(context, m)),
                                    ],
                                  ),
                        // Products Tab
                        _productResults.isNotEmpty
                            ? ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: _productResults.length,
                                itemBuilder: (context, index) => _buildProductListTile(_productResults[index]),
                              )
                            : ListView(
                                children: [
                                  if (!_isLoading)
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.5,
                                      child: _buildEmptyState(_searchController.text.isEmpty 
                                          ? 'Digite algo para buscar produtos'
                                          : 'Nenhum produto encontrado'),
                                    ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    color: Color(0xFF2196F3),
                    backgroundColor: Colors.transparent,
                    minHeight: 3,
                  ),
                ),
              if (_isLoading && _supermarketResults.isEmpty && _supermarkets.isEmpty && _productResults.isEmpty)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2196F3)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListTile(ProductModel product) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
      ),
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${product.brand ?? ''} • ${product.unitMeasure ?? ''}'),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
    );
  }

  Widget _buildMapView() {
    final center = _userLocation ?? const LatLng(-23.5505, -46.6333); // Default to SP if location not found
    
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 14.0,
      ),
      mapController: _mapController,
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
            ..._supermarkets.where((s) => s.address?.latitude != null).map((s) {
              return Marker(
                point: LatLng(s.address!.latitude!, s.address!.longitude!),
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
    );

  }

  void _showOnMap(double lat, double lng) {
    setState(() {
      _showMap = true;
    });
    
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _mapController.move(LatLng(lat, lng), 16.0);
      }
    });
  }

  Widget _buildSupermarketCard(BuildContext context, SupermarketModel market) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SupermarketDetailScreen(supermarket: market),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_rounded, color: Color(0xFF2196F3), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatAddress(market.address),
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (market.distance != null)
                    Text(
                      '${market.distance!.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.map_outlined, color: Color(0xFF2196F3), size: 20),
                    onPressed: () {
                      if (market.address?.latitude != null && market.address?.longitude != null) {
                        _showOnMap(market.address!.latitude!, market.address!.longitude!);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddress(Address? address) {
    if (address == null) return 'Endereço não disponível';
    
    final street = address.street;
    final number = address.number;
    final neighborhood = address.neighborhood;

    
    if (street.isEmpty) return 'Endereço incompleto';
    
    String formatted = street;
    if (number.isNotEmpty) formatted += ', $number';
    if (neighborhood.isNotEmpty) formatted += ' - $neighborhood';
    
    return formatted;
  }

}
