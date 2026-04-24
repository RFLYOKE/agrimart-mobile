import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../features/auth/domain/providers/auth_provider.dart';
import '../../domain/providers/product_provider.dart';
import '../../domain/providers/cart_provider.dart';
import '../../data/models/product_model.dart';
// import '../../data/repositories/product_repository.dart';

// Use a FutureProvider to fetch a single product if it's not in the list
final productDetailProvider = FutureProvider.family<ProductModel, String>((ref, id) async {
  final repo = ref.read(productRepositoryProvider);
  return repo.getProductById(id);
});

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _currentImageIndex = 0;

  void _addToCart(ProductModel product) {
    ref.read(cartProvider.notifier).addItem(product, _quantity);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ditambahkan ke keranjang')),
    );
  }

  void _buyNow(ProductModel product) {
    ref.read(cartProvider.notifier).clearCart();
    ref.read(cartProvider.notifier).addItem(product, _quantity);
    context.push(RouteNames.checkout);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider.notifier).currentUser;
    final isB2B = user?.isHotel == true || user?.isEksportir == true;
    
    // Check if we already have it in the list to avoid duplicate fetching
    final listState = ref.watch(productProvider);
    ProductModel? product;
    
    try {
      product = listState.products.firstWhere((p) => p.id == widget.productId);
    } catch (_) {
      // not found in list, will fetch
    }

    if (product != null) {
      return _buildDetailContent(context, product, isB2B);
    } else {
      final asyncProduct = ref.watch(productDetailProvider(widget.productId));
      return asyncProduct.when(
        data: (p) => _buildDetailContent(context, p, isB2B),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      );
    }
  }

  Widget _buildDetailContent(BuildContext context, ProductModel product, bool isB2B) {
    final price = isB2B ? product.priceB2b : product.priceB2c;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.push(RouteNames.cart),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            if (product.images.isNotEmpty)
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: product.images.length,
                      onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                      itemBuilder: (ctx, idx) => CachedNetworkImage(
                        imageUrl: product.images[idx],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(product.images.length, (idx) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == idx ? AppColors.primaryGreen : Colors.white70,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(height: 300, color: Colors.grey[300], child: const Center(child: Icon(Icons.image_not_supported, size: 50))),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.formatRupiah(price),
                    style: const TextStyle(fontSize: 24, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Koperasi Info
                  Card(
                    elevation: 0,
                    color: AppColors.backgroundLight,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.store, color: AppColors.primaryGreen),
                              const SizedBox(width: 8),
                              Text(product.coopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Tingkat Kesegaran (Fresh Rate):'),
                              const Spacer(),
                              Text('${product.coopFreshRate}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: product.coopFreshRate / 100,
                            backgroundColor: Colors.grey[300],
                            color: product.coopFreshRate >= 80 ? AppColors.successGreen : AppColors.warningOrange,
                          ),
                          const SizedBox(height: 12),
                          // Badges
                          Wrap(
                            spacing: 8,
                            children: product.coopCertifications.map((cert) => Chip(
                              label: Text(cert, style: const TextStyle(fontSize: 12, color: Colors.white)),
                              backgroundColor: AppColors.secondaryGreen,
                              padding: EdgeInsets.zero,
                            )).toList(),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(product.description, style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 100), // spacing for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Picker
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                    ),
                    Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_quantity < product.stock) setState(() => _quantity++);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryGreen)),
                  onPressed: () => _addToCart(product),
                  child: const Text('Keranjang', style: TextStyle(color: AppColors.primaryGreen)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                  onPressed: () => _buyNow(product),
                  child: const Text('Beli', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
