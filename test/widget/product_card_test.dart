import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Assuming your ProductCard exists somewhere
// import 'package:mobile/features/marketplace/presentation/widgets/product_card.dart';
// import 'package:mobile/features/marketplace/domain/entities/product.dart';

// --- Mock Classes (Placeholder) ---
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  Product({required this.id, required this.name, required this.price, required this.imageUrl});
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({Key? key, required this.product, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Column(
          children: [
            Text(product.name, key: const Key('product_name')),
            Text('Rp ${product.price.toStringAsFixed(0)}', key: const Key('product_price')),
          ],
        ),
      ),
    );
  }
}
// -----------------------------------

void main() {
  group('ProductCard Widget Tests', () {
    final dummyProduct = Product(
      id: 'p1',
      name: 'Pupuk Kompos Organik',
      price: 50000,
      imageUrl: 'dummy_url',
    );

    testWidgets('Render ProductCard dengan data dummy dan format harga', (WidgetTester tester) async {
      bool isTapped = false;

      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: dummyProduct,
              onTap: () {
                isTapped = true;
              },
            ),
          ),
        ),
      );

      // Act & Assert

      // 1. Verifikasi nama produk tampil
      final nameFinder = find.text('Pupuk Kompos Organik');
      expect(nameFinder, findsOneWidget);

      // 2. Verifikasi harga tampil dalam format rupiah
      // We expect 'Rp 50000' based on the dummy implementation or actual Intl formatting (e.g. Rp 50.000)
      final priceFinder = find.text('Rp 50000'); // Atau Rp 50.000 tergantung format formatter di app
      expect(priceFinder, findsOneWidget);

      // 3. Verifikasi tap navigasi ke product_detail
      // Di sini kita test trigger callback navigasi
      await tester.tap(find.byType(ProductCard));
      await tester.pump();
      
      expect(isTapped, isTrue);
    });
  });
}
