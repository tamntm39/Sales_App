import 'package:dio/dio.dart';

class AuthRegisterService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://10.0.2.2:7072'; // API backend

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
          "Phone": phone,
          "Address": address,
          "Email": email,
          "Username": username,
          "Password": password,
          "Image": image,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: false, 
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Xử lý kết quả trả về
      if (response.statusCode == 200 && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data);

        if (data['success'] == true) {
          return {
            "success": true,
            "message": "Đăng ký thành công! Vui lòng kiểm tra email để kích hoạt tài khoản."
          };
        } else {
          return {
            "success": false,
            "message": data['message'] ?? "Đăng ký thất bại."
          };
        }
      } else {
        return {
          "success": false,
          "message": "Lỗi kết nối server: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Lỗi: ${e.toString()}"
      };
    }
  }
}
