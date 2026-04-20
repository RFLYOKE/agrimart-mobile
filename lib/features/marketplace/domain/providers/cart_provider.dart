import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/providers/auth_provider.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  final Ref ref;

  CartNotifier(this.ref) : super([]);

  void addItem(ProductModel product, int quantity) {
    if (quantity <= 0) return;
    
    final index = state.indexWhere((item) => item.product.id == product.id);
    
    if (index >= 0) {
      // Update quantity if already exists
      final currentItem = state[index];
      final newQty = currentItem.quantity + quantity;
      
      if (newQty > product.stock) {
        // Handle max stock constraint
        final updatedList = [...state];
        updatedList[index] = currentItem.copyWith(quantity: product.stock);
        state = updatedList;
        return;
      }

      final updatedList = [...state];
      updatedList[index] = currentItem.copyWith(quantity: newQty);
      state = updatedList;
    } else {
      // Add new item
      final qty = quantity > product.stock ? product.stock : quantity;
      state = [...state, CartItemModel(product: product, quantity: qty)];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQty(String productId, int newQty) {
    if (newQty <= 0) {
      removeItem(productId);
      return;
    }

    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final productInfo = state[index].product;
      final safeQty = newQty > productInfo.stock ? productInfo.stock : newQty;
      
      final updatedList = [...state];
      updatedList[index] = state[index].copyWith(quantity: safeQty);
      state = updatedList;
    }
  }

  void clearCart() {
    state = [];
  }

  num get totalPrice {
    final user = ref.read(authProvider.notifier).currentUser;
    final isB2B = user?.isEksportir == true || user?.isHotel == true; // Define logic for B2B

    num total = 0;
    for (var item in state) {
      total += item.subtotal(isB2B);
    }
    return total;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier(ref);
});
