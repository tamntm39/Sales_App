import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

abstract class IAuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
}

class AuthRepository implements IAuthRepository {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final baseUrl = '$BASE_URL/api';
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customer/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng nhập thất bại'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}

class AuthService {
  static final IAuthRepository _repo = AuthRepository();

  Future<Map<String, dynamic>> login(String email, String password) {
    return _repo.login(email, password);
  }
}
