import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chichanka_perfume/models/product_api_model.dart';
import '../config.dart';

// Repository interface for product data
abstract class IProductRepository {
  Future<List<ProductApiModel>> fetchProducts();


  @override
Future<List<ProductApiModel>> fetchRelatedProducts(
  String categoryName,
  int currentProductId, {
  int limit = 5,
}) async {
  final encodedCategory = Uri.encodeComponent(categoryName.trim());
  final url = '$BASE_URL/api/Product/RecommandCategory'
      '?categoryName=$encodedCategory'
      '&currentProductId=$currentProductId'
      '&limit=$limit';

  final response = await http.get(Uri.parse(url));
  print("📤 Request URL: $url");

  if (response.statusCode == 200) {
    final jsonBody = json.decode(response.body);
    print("📥 Related products JSON: $jsonBody");

    if (jsonBody['success'] == true && jsonBody['data'] != null) {
      return (jsonBody['data'] as List)
          .map((item) => ProductApiModel.fromApi(item))
          .toList();
    } else {
      throw Exception(jsonBody['message'] ?? 'Không có sản phẩm liên quan');
    }
  } else {
    throw Exception('Lỗi server: ${response.statusCode}');
  }
}
}
// Repository implementation using REST API
class ProductRepository implements IProductRepository {
  @override
  Future<List<ProductApiModel>> fetchProducts() async {
    final url = '$BASE_URL/api/Product/ListProduct';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      print("📥 JSON nhận từ backend: $jsonBody");

      if (jsonBody['success'] == true && jsonBody['data'] != null) {
        return (jsonBody['data'] as List)
            .map((item) => ProductApiModel.fromApi(item))
            .toList();
      } else {
        throw Exception(jsonBody['message'] ?? 'Lỗi không xác định');
      }
    } else {
      throw Exception('Lỗi server: ${response.statusCode}');
    }
  }

  @override
Future<List<ProductApiModel>> fetchRelatedProducts(
  String categoryName,
  int currentProductId, {
  int limit = 5,
}) async {
  final encodedCategory = Uri.encodeComponent(categoryName.trim());
final url = '$BASE_URL/api/Product/RecommandCategory'
    '?categoryName=$encodedCategory'
    '&currentProductId=$currentProductId'
    '&limit=$limit';
  print("📤 Gọi API: $url");

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final jsonBody = json.decode(response.body);
    print("📥 JSON trả về: $jsonBody");

    if (jsonBody['success'] == true && jsonBody['data'] != null) {
      return (jsonBody['data'] as List)
          .map((item) => ProductApiModel.fromApi(item))
          .toList();
    } else {
      throw Exception(jsonBody['message'] ?? 'Không có sản phẩm liên quan');
    }
  } else {
    throw Exception('Lỗi server: ${response.statusCode}');
  }
}
}
// Service class delegating to repository
class ProductService {
  static final IProductRepository _repo = ProductRepository();

  static Future<List<ProductApiModel>> fetchProducts() {
    return _repo.fetchProducts();
  }

  static Future<List<ProductApiModel>> fetchRelatedProducts(
      String categoryName,
      int currentProductId,
      {int limit = 5}) {
    return _repo.fetchRelatedProducts(categoryName, currentProductId, limit: limit);
  }
}
