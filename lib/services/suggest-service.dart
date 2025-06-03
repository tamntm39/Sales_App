import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chichanka_perfume/models/product_api_model.dart';
import '../config.dart';

abstract class ISuggestionProductRepository {
  Future<List<ProductApiModel>> fetchProductsByCategoryId(int categoryId);
}

class SuggestionProductRepository implements ISuggestionProductRepository {
  @override
  Future<List<ProductApiModel>> fetchProductsByCategoryId(int categoryId) async {
    final url = '$BASE_URL/api/Product/GetProductsByCategory?categoryId=$categoryId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
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
}

class SuggestionProductService {
  static final ISuggestionProductRepository _repo = SuggestionProductRepository();

  static Future<List<ProductApiModel>> fetchProductsByCategoryId(int categoryId) {
    return _repo.fetchProductsByCategoryId(categoryId);
  }
}
