import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chichanka_perfume/models/product_api_model.dart';
import '../config.dart'; // import BASE_URL

class ProductService {
  static Future<List<ProductApiModel>> fetchProducts() async {
    final url = '$BASE_URL/api/Product/ListProduct'; // use shared BASE_URL
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
