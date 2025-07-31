import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class FavoriteService {
  // Đúng với backend: Favorites (có s)
  final String _baseUrl = '$BASE_URL/api/Favorites';

  // Lấy danh sách sản phẩm yêu thích
  Future<List<dynamic>> getFavorites(int customerId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$customerId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }

  // Kiểm tra 1 sản phẩm có nằm trong yêu thích không
  Future<bool> isFavorite(int customerId, int productId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$customerId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = List<Map<String, dynamic>>.from(data['data']);
      return list.any((item) => item['productId'] == productId);
    }
    return false;
  }

  // Thêm sản phẩm vào yêu thích
 Future<bool> addFavorite(int customerId, int productId) async {
  final response = await http.post(
    Uri.parse(_baseUrl), // <-- Không có /AddFavorite
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'customerId': customerId, 'productId': productId}),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }
  return false;
}

  // Xóa sản phẩm khỏi yêu thích
  Future<bool> removeFavorite(int customerId, int productId) async {
    final response = await http.delete(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'customerId': customerId, 'productId': productId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    }
    return false;
  }
}