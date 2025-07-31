// ✅ Updated AuthRegisterService to match correct endpoint and parse Map<String, dynamic> properly
import 'package:dio/dio.dart';

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
    required String image,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/Customer/Register',
        data: {
          "FullName": fullName,
          "phone": phone,
          "address": address,
          "email": email,
          "username": username,
          "password": password,
          "image": image,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Ensure correct parsing of the response
      if (response.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(response.data);
      } else {
        return {
          "success": false,
          "message": "Phản hồi từ server không hợp lệ",
          "raw": response.data.toString()
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
