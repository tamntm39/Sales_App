import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/category_api_model.dart';

abstract class ICategoryRepository {
  Future<List<CategoryApiModel>> fetchCategories();
}

class CategoryRepository implements ICategoryRepository {
  @override
  Future<List<CategoryApiModel>> fetchCategories() async {
    final url = '$BASE_URL/api/Category/GetAll';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      if (jsonBody['success'] == true && jsonBody['data'] != null) {
        return (jsonBody['data'] as List)
            .map((item) => CategoryApiModel.fromJson(item))
            .toList();
      } else {
        throw Exception(jsonBody['message'] ?? 'Lỗi không xác định');
      }
    } else {
      throw Exception('Lỗi server: ${response.statusCode}');
    }
  }
}

class CategoryService {
  static final ICategoryRepository _repo = CategoryRepository();

  static Future<List<CategoryApiModel>> fetchCategories() {
    return _repo.fetchCategories();
  }
}
