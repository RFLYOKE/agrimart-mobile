import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;

  CartItemModel({
    required this.product,
    required this.quantity,
  });

  // Calculate subtotal based on user role would technically happen in the UI or a provider,
  // but we can add a helper method here that takes a bool to decide pricing.
  num subtotal(bool isB2B) {
    final price = isB2B ? product.priceB2b : product.priceB2c;
    return price * quantity;
  }

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
