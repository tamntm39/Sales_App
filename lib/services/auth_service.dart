import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart'; // import BASE_URL from Dart config

class AuthService {
  // Đổi baseUrl cho phù hợp môi trường:
  // Android emulator:
  // final String baseUrl = 'http://10.0.2.2:7072/api';
  // Thiết bị thật (điền đúng IP LAN của máy tính):
  // final String baseUrl = 'http://192.168.x.x:7072/api';
  // Postman trên máy tính:
  // final String baseUrl = 'http://localhost:7072/api';

  final String baseUrl = '$BASE_URL/api'; // use shared BASE_URL

  Future<Map<String, dynamic>> login(String email, String password) async {
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
      print('AuthService login error: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
