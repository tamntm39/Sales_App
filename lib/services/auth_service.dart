import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://10.0.2.2:5168/api/Customer';
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/Login', // Đúng endpoint: /api/Customer/Login
        data: {
          "email": email,
          "password": password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return response.data;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      return {"success": false, "message": e.toString()};
    }
  }
}
