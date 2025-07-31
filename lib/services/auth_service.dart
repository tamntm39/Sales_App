import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://10.0.2.2:7072/api/Customer';
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {

    print('⚠️ Email gửi: "${email.trim()}"');
    print('⚠️ Email viết thường: "${email.trim().toLowerCase()}"');
    print('⚠️ Password: "$password"');

      final response = await _dio.post(
        '$baseUrl/Login', // Đúng endpoint: /api/Customer/Login
        data: {
          "Email": email,
          "Password": password,
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
