import 'dart:convert';
import 'package:http/http.dart' as http;

class GetCustomerService {
  final String baseUrl = 'http://10.0.2.2:7072/api';

  Future<Map<String, dynamic>> getCustomer(int customerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Customer/GetCustomerById?customerId=$customerId'),
        headers: {'Content-Type': 'application/json'},
      );
      print('GET CUSTOMER - Status: ${response.statusCode}');
      print('GET CUSTOMER - Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Lấy thông tin thất bại'
        };
      }
    } catch (e) {
      print('GET CUSTOMER - Exception: $e');
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
