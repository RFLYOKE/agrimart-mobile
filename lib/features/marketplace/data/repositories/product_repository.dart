import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class ProductRepository {
  final Dio _dio;

  ProductRepository(this._dio);

  Future<List<ProductModel>> getProducts({String? category, String? search, int page = 1}) async {
    try {
      final queryParams = {
        'page': page,
        if (category != null && category.isNotEmpty) 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _dio.get(ApiConstants.products, queryParameters: queryParams);
      
      final List data = response.data['data']['products'] ?? [];
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.products}/$id');
      return ProductModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<OrderModel> createOrder(List<Map<String, dynamic>> items, Map<String, dynamic> address, String paymentMethod) async {
    try {
      final data = {
        'items': items,
        'address': address,
        'payment_method': paymentMethod,
      };
      
      final response = await _dio.post(ApiConstants.orders, data: data);
      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      return ApiException(
        statusCode: e.response?.statusCode,
        message: data is Map && data['message'] != null ? data['message'] : e.message ?? 'Unknown error',
        data: data,
      );
    } else {
      return ApiException(message: 'Connection error: ${e.message}');
    }
  }
}
