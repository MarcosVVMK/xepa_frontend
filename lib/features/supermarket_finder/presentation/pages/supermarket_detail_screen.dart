import 'package:flutter/material.dart';
import 'package:xepa_frontend/core/DI/dependency_injection.dart';
import 'package:xepa_frontend/features/product/data/models/product_price_model.dart';
import 'package:xepa_frontend/features/supermarket_finder/data/datasources/supermarket_service.dart';
import 'package:xepa_frontend/features/supermarket_finder/data/models/supermarket_model.dart';
import 'package:xepa_frontend/features/product/presentation/pages/product_detail_screen.dart';

class SupermarketDetailScreen extends StatefulWidget {
  final SupermarketModel supermarket;

  const SupermarketDetailScreen({super.key, required this.supermarket});

  @override
  State<SupermarketDetailScreen> createState() => _SupermarketDetailScreenState();
}

class _SupermarketDetailScreenState extends State<SupermarketDetailScreen> {
  final SupermarketService _supermarketService = getIt<SupermarketService>();
  List<ProductPrice> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (widget.supermarket.id == null) return;
    setState(() => _isLoading = true);
    try {
      final products = await _supermarketService.getSupermarketProducts(widget.supermarket.id!);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.supermarket.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.store_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informações',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on_rounded, _formatAddress(widget.supermarket.address)),
                  if (widget.supermarket.phone != null)
                    _buildInfoRow(Icons.phone_rounded, widget.supermarket.phone!),
                  _buildInfoRow(Icons.access_time_rounded, 
                      '${widget.supermarket.openingHours ?? "08:00"} - ${widget.supermarket.closingHours ?? "22:00"}'),
                  const SizedBox(height: 24),
                  Text(
                    'Produtos (${_products.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_products.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum produto encontrado',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _products[index];
                    return _buildProductCard(item);
                  },
                  childCount: _products.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddress(dynamic address) {
    if (address == null) return 'Endereço não disponível';
    final street = address.street ?? 'Rua não informada';
    final number = address.number ?? 'S/N';
    final neighborhood = address.neighborhood ?? '';
    final city = address.city ?? '';
    
    String formatted = '$street, $number';
    if (neighborhood.isNotEmpty) formatted += ' - $neighborhood';
    if (city.isNotEmpty) formatted += ', $city';
    
    return formatted;
  }

  Widget _buildProductCard(ProductPrice item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: item.product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.product.brand ?? 'Marca não informada',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${item.price.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
