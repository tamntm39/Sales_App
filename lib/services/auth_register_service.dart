import 'package:dio/dio.dart';

// ...existing code...
class AuthRegisterService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://10.0.2.2:7072';
  Future<Map<String, dynamic>> registerCustomer({
    required String fullName,
    required String phone,
    required String address,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/Customer/Register',
        data: {
          "fullName": fullName,
          "phone": phone,
          "address": address,
          "email": email,
          "username": username,
          "password": password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );
      return response.data;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
