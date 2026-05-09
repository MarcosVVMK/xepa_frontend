import 'dart:developer' as dev;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xepa_frontend/core/DI/dependency_injection.dart';
import 'package:xepa_frontend/features/shopping_list/domain/usecases/shopping_list_usecases.dart';
import 'package:xepa_frontend/features/shopping_list/domain/entities/shopping_list.dart';

import 'package:xepa_frontend/features/product/domain/usecases/product_usecases.dart';
import 'package:xepa_frontend/features/product/domain/entities/product.dart';
import 'package:xepa_frontend/features/product/presentation/pages/product_detail_screen.dart';

class ListDetailScreen extends StatefulWidget {
  final String listName;
  final int listId;
  const ListDetailScreen({
    super.key,
    required this.listName,
    required this.listId,
  });

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  ShoppingList? _list;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    setState(() => _isLoading = true);
    try {
      final useCase = getIt<GetShoppingListByIdUseCase>();
      final list = await useCase(widget.listId);
      if (mounted) {
        setState(() {
          _list = list;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      dev.log('Erro ao carregar lista de compras', error: e, stackTrace: stackTrace);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _total => _list?.total ?? 0;

  int get _totalItems => _list?.itemCount ?? 0;

  Future<void> _removeItem(int index) async {
    final item = _list?.items?[index];
    if (item == null) return;
    
    try {
      final useCase = getIt<RemoveItemFromListUseCase>();
      await useCase(widget.listId, item.id!);
      await _loadList();
    } catch (e, stackTrace) {
      dev.log('Erro ao remover item da lista', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _showEditNameDialog() async {
    final controller = TextEditingController(text: _list?.name ?? widget.listName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar nome da lista'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nome da lista'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final useCase = getIt<UpdateShoppingListUseCase>();
                await useCase(widget.listId, {
                  'name': newName,
                });
                if (!mounted) return;
                Navigator.pop(ctx);
                _loadList();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteListDialog() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar lista?'),
        content: const Text(
          'Tem certeza que deseja apagar esta lista? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final useCase = getIt<DeleteShoppingListUseCase>();
              await useCase(widget.listId);
              if (!mounted) return;
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Apagar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddProductSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddProductSheet(listId: widget.listId),
    ).then((_) => _loadList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadList,
          color: const Color(0xFF2196F3),
          child: Column(
            children: [
              if (_isLoading)
                const LinearProgressIndicator(
                  color: Color(0xFF2196F3),
                  backgroundColor: Colors.transparent,
                  minHeight: 2,
                ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.fromLTRB(8, 8, 16, 14),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2196F3),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Icon(
                              Icons.shopping_cart_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: _showEditNameDialog,
                                        child: Text(
                                          _list?.name ?? widget.listName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$_totalItems itens',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.delete_forever_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _showDeleteListDialog,
                                    ),
                                  ],
                                ),
                                Text(
                                  'R\$ ${_total.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Items
                      (_list?.items?.isEmpty ?? true)
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: _buildEmptyState(),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _list!.items!.length,
                              itemBuilder: (context, index) =>
                                  _buildItemCard(_list!.items![index], index),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Add product button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _showAddProductSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Adicionar produto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Lista vazia',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione produtos à sua lista',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(ShoppingListItem item, int index) {
    final name = item.productName ?? 'Produto';
    final qty = item.quantity;
    final price = item.price ?? 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: Product(
                id: item.productId,
                name: name,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            // Name & price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF5350),
                    ),
                  ),
                ],
              ),
            ),
            // Quantity controls
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Delete
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _removeItem(index),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFEF5350),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProductSheet extends StatefulWidget {
  final int listId;
  const _AddProductSheet({required this.listId});

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Product> _searchResults = [];
  bool _isLoading = false;
  bool _isAdding = false;

  int _page = 0;
  final int _size = 20;
  bool _hasMore = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial search or load all
    _searchProducts('', reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _searchProducts(_searchController.text);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchProducts(query, reset: true);
    });
  }

  Future<void> _searchProducts(String query, {bool reset = false}) async {
    if (reset) {
      setState(() {
        _page = 0;
        _searchResults = [];
        _hasMore = true;
      });
    }

    if (!_hasMore || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      final useCase = getIt<SearchProductsUseCase>();
      final results = await useCase(
        query,
        page: _page,
        size: _size,
      );

      if (mounted) {
        setState(() {
          _searchResults.addAll(results);
          _isLoading = false;
          _page++;
          if (results.length < _size) {
            _hasMore = false;
          }
        });
      }
    } catch (e, stackTrace) {
      dev.log('Erro ao buscar produtos', error: e, stackTrace: stackTrace);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 16,
        right: 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar produto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _searchResults.isEmpty && !_isLoading
                  ? const Center(child: Text('Nenhum produto encontrado'))
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _searchResults.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _searchResults.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(color: Color(0xFF2196F3)),
                            ),
                          );
                        }
                        final p = _searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.shopping_bag_outlined),
                          title: Text(p.name),
                          subtitle: Text(
                            '${p.brand ?? ''} • ${p.unitMeasure ?? ''}',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(product: p),
                              ),
                            );
                          },
                          trailing: _isAdding
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF2196F3),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _showQuantityDialog(p),
                                ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuantityDialog(Product product) async {
    final controller = TextEditingController(text: '1');
    final unit = product.unitMeasure ?? 'UNIDADE';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Adicionar ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unidade: $unit'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final qty =
                  double.tryParse(controller.text.replaceAll(',', '.')) ?? 1.0;
              Navigator.pop(ctx);
              _addProduct(product.id!, qty);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct(int productId, double quantity) async {
    setState(() => _isAdding = true);
    try {
      final useCase = getIt<AddItemToListUseCase>();
      await useCase(widget.listId, productId, quantity, '');
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      dev.log('Erro ao adicionar produto à lista', error: e, stackTrace: stackTrace);
      if (mounted) setState(() => _isAdding = false);
    }
  }
}
