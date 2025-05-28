import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateCustomerService {
  final String baseUrl = 'http://10.0.2.2:7072/api';

  Future<Map<String, dynamic>> updateCustomer({
    required String customerId,
    required String fullname,
    required String phone,
    required String email,
    required String address,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Customer/UpdateCustomer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerId': int.parse(customerId),
          'fullname': fullname,
          'phone': phone,
          'email': email,
          'address': address,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật thất bại'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}