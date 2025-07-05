import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chichanka_perfume/models/cart-model.dart';
import 'package:chichanka_perfume/models/order_api_model.dart';
import 'package:chichanka_perfume/config.dart';

class OrderService {
  Future<bool> createOrder({
    required int customerId,
    String note = "",
    int promotionId = 0,
    String promotionCode = "",
    required List<CartModel> cartList,
  }) async {
    final orderData = {
      "customerId": customerId,
      "note": note,
      "promotionId": promotionId,
      "promotionCode": promotionCode,
      "cartItems": cartList
          .map((item) => {
                "productId": int.tryParse(item.productId) ?? 0,
                "quantity": item.productQuantity,
              })
          .toList(),
    };

    final response = await http.post(
      Uri.parse('$BASE_URL/api/Order/Create'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(orderData),
    );

    return response.statusCode == 200;
  }

  Future<List<OrderApiModel>> getOrdersByCustomerId(int customerId) async {
    final url = Uri.parse(
        '$BASE_URL/api/Order/ListOrderByCustomerId?customerId=$customerId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      print('API response data: ${jsonBody['data']}'); // Log toàn bộ data

      if (jsonBody['success'] == true && jsonBody['data'] != null) {
        final orders = (jsonBody['data'] as List)
            .map((e) => OrderApiModel.fromMap(e))
            .toList();
        for (var order in orders) {
          print('Order: ${order.toString()}'); // Log từng đơn hàng
        }
        return orders;
      }
    } else {
      print('API error: ${response.statusCode} - ${response.body}');
    }
    return [];
  }

  // Hàm kiểm tra mã khuyến mãi
  Future<Map<String, dynamic>?> checkPromotionCode(
      String code, double totalAmount) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/api/Promotion/CheckPromotionCode'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "promotionCode": code,
        "totalAmount": totalAmount,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<bool> cancelOrder(int orderId) async {
    final url = Uri.parse('$BASE_URL/api/Order/CancelOrder?orderId=$orderId');

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return jsonBody['success'] == true && jsonBody['data'] == true;
      } else {
        print('CancelOrder failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('CancelOrder error: $e');
    }

    return false;
  }

  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    final url =
        Uri.parse('$BASE_URL/api/Order/ListDetailOrder?orderId=$orderId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      if (jsonBody['success'] == true &&
          jsonBody['data'] != null &&
          jsonBody['data'] is Map) {
        return jsonBody['data'] as Map<String, dynamic>;
      }
    } else {
      print('API error: ${response.statusCode} - ${response.body}');
    }
    return {};
  }
}
