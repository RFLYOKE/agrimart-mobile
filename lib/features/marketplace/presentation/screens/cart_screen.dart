import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../features/auth/domain/providers/auth_provider.dart';
import '../../domain/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final user = ref.watch(authProvider.notifier).currentUser;
    final isB2B = user?.isHotel == true || user?.isEksportir == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Keranjang Anda kosong'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final product = item.product;
                final price = isB2B ? product.priceB2b : product.priceB2c;

                return Dismissible(
                  key: Key(product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: AppColors.errorRed,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(cartProvider.notifier).removeItem(product.id);
                  },
                  child: Row(
                    children: [
                      product.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.images.first,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(width: 80, height: 80, color: Colors.grey[300]),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(CurrencyFormatter.formatRupiah(price), style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                    icon: const Icon(Icons.remove, size: 20),
                                    onPressed: () => ref.read(cartProvider.notifier).updateQty(product.id, item.quantity - 1),
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                    icon: const Icon(Icons.add, size: 20),
                                    onPressed: () => ref.read(cartProvider.notifier).updateQty(product.id, item.quantity + 1),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
      bottomSheet: cartItems.isEmpty ? null : Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pembayaran', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    CurrencyFormatter.formatRupiah(ref.watch(cartProvider.notifier).totalPrice),
                    style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () => context.push(RouteNames.checkout),
                child: const Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
