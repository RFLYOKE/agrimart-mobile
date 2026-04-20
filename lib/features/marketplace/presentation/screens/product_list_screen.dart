import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../features/auth/domain/providers/auth_provider.dart';
import '../../domain/providers/product_provider.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> categories = ['Semua', 'Pertanian', 'Perikanan', 'Peternakan'];
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(productProvider.notifier).fetchProducts();
    }
  }

  void _onSearch(String value) {
    ref.read(productProvider.notifier).setFilter(search: value);
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    ref.read(productProvider.notifier).setFilter(
      category: category == 'Semua' ? '' : category,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);
    final user = ref.watch(authProvider.notifier).currentUser;
    final isB2B = user?.isHotel == true || user?.isEksportir == true;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Cari hasil bumi...',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: _onSearch,
        ),
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.push(RouteNames.cart),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                    onSelected: (_) => _onCategorySelected(cat),
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: state.isLoading && state.products.isEmpty
                ? _buildShimmerGrid()
                : state.error != null && state.products.isEmpty
                    ? Center(child: Text('Error: ${state.error}'))
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: state.products.length + (state.isLoading ? 2 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.products.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          final product = state.products[index];
                          final price = isB2B ? product.priceB2b : product.priceB2c;
                          
                          return GestureDetector(
                            onTap: () => context.push(RouteNames.productDetail.replaceFirst(':id', product.id)),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: product.images.isNotEmpty 
                                      ? CachedNetworkImage(
                                          imageUrl: product.images.first,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          placeholder: (context, url) => Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(color: Colors.white),
                                          ),
                                          errorWidget: (context, url, err) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                        )
                                      : Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.image_not_supported))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          CurrencyFormatter.formatRupiah(price),
                                          style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.store, size: 12, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                product.coopName,
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }
}
