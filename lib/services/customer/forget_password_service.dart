import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:chichanka_perfume/config.dart';
class ApiService {
  static const String _forgotPasswordUrl = '$BASE_URL/api/Customer/ForgotPassword';
  static const String _resetPasswordUrl = '$BASE_URL/api/Customer/ResetPassword';

  /// Gửi email để nhận OTP
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final uri = Uri.parse('$_forgotPasswordUrl/ForgotPassword?email=$email');

      final response = await https.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return _handleError(response);
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi: $e',
      };
    }
  }

  /// Đặt lại mật khẩu
  static Future<Map<String, dynamic>> resetPassword(String otp, String newPassword) async {
    try {
      final uri = Uri.parse('$_resetPasswordUrl/ResetPassword').replace(queryParameters: {
        'otp': otp,
        'newPassword': newPassword,
      });

      final response = await https.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('ResetPassword Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return _handleError(response);
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Đã xảy ra lỗi: $e',
      };
    }
  }

  /// Xử lý lỗi chung
  static Map<String, dynamic> _handleError(https.Response response) {
    String message = 'Lỗi không xác định';
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        message = decoded['message'] ?? message;
      } catch (_) {}
    } else if (response.statusCode == 404) {
      message = 'Không tìm thấy tài nguyên hoặc email không tồn tại.';
    }
    return {
      'success': false,
      'message': message,
    };
  }
}