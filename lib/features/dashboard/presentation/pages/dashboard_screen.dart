import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:xepa_frontend/core/DI/dependency_injection.dart';
import 'package:xepa_frontend/core/auth/token_storage.dart';
import 'package:xepa_frontend/features/auth/data/models/user_model.dart';

import 'package:xepa_frontend/features/shopping_list/presentation/pages/lists_screen.dart';
import 'package:xepa_frontend/features/nfc_scanner/presentation/pages/qr_scanner_screen.dart';
import 'package:xepa_frontend/features/supermarket_finder/presentation/pages/explore_screen.dart';
import 'package:xepa_frontend/features/profile/presentation/pages/profile_screen.dart';
import 'package:xepa_frontend/features/product/data/datasources/product_service.dart';
import 'package:xepa_frontend/features/product/data/models/product_model.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';
import 'package:xepa_frontend/features/supermarket_finder/data/datasources/supermarket_service.dart';
import 'package:xepa_frontend/features/supermarket_finder/data/models/supermarket_model.dart';
import 'package:xepa_frontend/shared/utils/price_freshness_utils.dart';
import 'package:xepa_frontend/shared/widgets/price_freshness_badge.dart';

import 'package:xepa_frontend/features/product/presentation/pages/product_detail_screen.dart';
import 'package:xepa_frontend/features/supermarket_finder/presentation/pages/supermarket_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserModel? _user;
  bool _isLoading = true;
  int _currentNavIndex = 0;
  List<ProductPrice> _cheapestProducts = [];
  bool _isLoadingProducts = true;
  List<ProductPrice> _closestProducts = [];
  bool _isLoadingClosestProducts = true;
  List<SupermarketModel> _closestSupermarkets = [];
  bool _isLoadingSupermarkets = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCheapestProducts();
    _loadClosestProducts();
    _loadClosestSupermarkets();
  }

  Future<void> _loadClosestSupermarkets() async {
    try {
      final supermarketService = getIt<SupermarketService>();
      final supermarkets = await supermarketService.getClosestSupermarkets();
      if (mounted) {
        setState(() {
          _closestSupermarkets = supermarkets;
          _isLoadingSupermarkets = false;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isLoadingSupermarkets = false;
        });
      }
    }
  }

  Future<void> _loadClosestProducts() async {
    try {
      final productService = getIt<ProductService>();
      final products = await productService.getClosestProducts();
      if (mounted) {
        setState(() {
          _closestProducts = products;
          _isLoadingClosestProducts = false;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isLoadingClosestProducts = false;
        });
      }
    }
  }

  Future<void> _loadCheapestProducts() async {
    try {
      final productService = getIt<ProductService>();
      final products = await productService.getCheapestProducts();
      if (mounted) {
        setState(() {
          _cheapestProducts = products;
          _isLoadingProducts = false;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    }
  }

  Future<void> _loadUser() async {
    try {
      final tokenStorage = getIt<TokenStorage>();
      final userJson = await tokenStorage.getUser();
      if (userJson != null && mounted) {
        setState(() {
          _user = UserModel.fromJson(jsonDecode(userJson));
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2196F3)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomeTab(),
          ListsScreen(isActive: _currentNavIndex == 1),
          const QrScannerScreen(),
          const ExploreScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _loadUser(),
            _loadCheapestProducts(),
            _loadClosestProducts(),
            _loadClosestSupermarkets(),
          ]);
        },
        color: const Color(0xFF2196F3),
        child: Column(
          children: [
            if (_isLoadingProducts || _isLoadingClosestProducts || _isLoadingSupermarkets)
              const LinearProgressIndicator(
                color: Color(0xFF2196F3),
                backgroundColor: Colors.transparent,
                minHeight: 2,
              ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSupermarketStories(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Ofertas Mais Baratas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _isLoadingProducts && _cheapestProducts.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)))
                  : _cheapestProducts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(Icons.sell_outlined, size: 60, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text('Nenhuma oferta encontrada', style: TextStyle(color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _cheapestProducts.length,
                            itemBuilder: (context, index) {
                              final item = _cheapestProducts[index];
                              return _buildProductCard(item.product, item.supermarket, item.price, item.priceUpdatedAt);
                            },
                          ),
                        ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Ofertas Mais Próximas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _isLoadingClosestProducts
                  ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: CircularProgressIndicator(color: Color(0xFF2196F3))))
                  : _closestProducts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(Icons.location_on_outlined, size: 60, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text('Nenhuma oferta próxima', style: TextStyle(color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _closestProducts.length,
                            itemBuilder: (context, index) {
                              final item = _closestProducts[index];
                              return _buildProductCard(item.product, item.supermarket, item.price, item.priceUpdatedAt);
                            },
                          ),
                        ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ],
  ),
),
);
}

  Widget _buildSupermarketStories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Mercados na Região',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: _isLoadingSupermarkets
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)))
              : _closestSupermarkets.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum mercado próximo',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _closestSupermarkets.length,
                      itemBuilder: (context, index) {
                        final market = _closestSupermarkets[index];
                        return _buildStoryItem(market);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStoryItem(SupermarketModel market) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SupermarketDetailScreen(supermarket: market),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2196F3), width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue[50],
                child: const Icon(Icons.storefront_rounded, color: Color(0xFF2196F3)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              market.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, SupermarketModel supermarket, double price, DateTime? priceUpdatedAt) {
    final freshnessColor = getPriceFreshnessColor(priceUpdatedAt);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: freshnessColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: freshnessColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const Spacer(),
            Text(
              supermarket.name,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
                PriceFreshnessBadge(updatedAt: priceUpdatedAt, compact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding:  const EdgeInsets.fromLTRB(20, 14, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF2196F3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${_user?.firstName ?? 'Usuário'}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18 ,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _greeting,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            color: Colors.white,
            iconSize: 26,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey[400],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Listas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: 'QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Explorar',
          ),
        ],
      ),
    );
  }
}
