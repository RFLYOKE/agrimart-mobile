import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../data/repositories/product_repository.dart';
import '../models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});

class ProductPaginationState {
  final List<ProductModel> products;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? category;
  final String? searchQuery;
  final String? error;

  ProductPaginationState({
    this.products = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.category,
    this.searchQuery,
    this.error,
  });

  ProductPaginationState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? category,
    String? searchQuery,
    String? error,
  }) {
    return ProductPaginationState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error, // Allow null error to reset
    );
  }
}

class ProductNotifier extends StateNotifier<ProductPaginationState> {
  final ProductRepository _repository;

  ProductNotifier(this._repository) : super(ProductPaginationState()) {
    fetchProducts();
  }

  Future<void> fetchProducts({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    if (refresh) {
      state = state.copyWith(isLoading: true, page: 1, error: null, hasMore: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final newPage = state.page;
      final newProducts = await _repository.getProducts(
        page: newPage,
        category: state.category,
        search: state.searchQuery,
      );

      state = state.copyWith(
        isLoading: false,
        products: refresh ? newProducts : [...state.products, ...newProducts],
        page: newPage + 1,
        hasMore: newProducts.isNotEmpty, // Assuming pagination limit ~ 10-20. If empty, no more.
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setFilter({String? category, String? search}) {
    state = state.copyWith(
      category: category,
      searchQuery: search,
    );
    fetchProducts(refresh: true);
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductPaginationState>((ref) {
  return ProductNotifier(ref.watch(productRepositoryProvider));
});
