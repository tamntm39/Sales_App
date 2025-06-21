import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleAuthService {
  final String _baseUrl = 'http://10.0.2.2:7072/api';

  Future<Map<String, dynamic>> googleSignIn(String idToken) async {
    try {
      final url = Uri.parse('$_baseUrl/Auth/GoogleSignIn');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      print('GOOGLE SIGN-IN - Status: ${response.statusCode}');
      print('GOOGLE SIGN-IN - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng nhập Google thất bại'
        };
      }
    } catch (e) {
      print('GOOGLE SIGN-IN - Exception: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
