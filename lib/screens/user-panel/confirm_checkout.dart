import 'dart:convert';
import 'package:chichanka_perfume/controllers/cart-price-controller.dart';
import 'package:chichanka_perfume/models/cart-model.dart';
import 'package:chichanka_perfume/services/order_service.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chichanka_perfume/screens/user-panel/main-screen.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:chichanka_perfume/config.dart';

import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

void showCustomBottomSheet(List<CartModel> cartList) {
  final TextEditingController couponController = TextEditingController();
  String selectedPaymentMethod = 'Thanh toán khi nhận hàng';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'vi_VN');
  double discount = 0.0;

  Get.bottomSheet(
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        // Tính tổng tiền từ cartList
        double total = cartList.fold(
            0, (sum, item) => sum + (item.productTotalPrice ?? 0));
        double finalPrice = total - discount;

        return Container(
          padding: const EdgeInsets.all(20),
          height: Get.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Thông tin giao hàng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstant.appMainColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: nameController,
                  label: 'Họ và tên người mua',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: phoneController,
                  label: 'Số điện thoại',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: addressController,
                  label: 'Địa chỉ giao hàng',
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Phí vận chuyển:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Miễn phí',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstant.appMainColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hình thức thanh toán:',
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButton<String>(
                  value: selectedPaymentMethod,
                  isExpanded: true,
                  items: <String>[
                    'Thanh toán khi nhận hàng',
                    'Thanh toán qua thẻ',
                    'Thanh toán qua ví điện tử',
                    'Thanh toán qua PayPal'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPaymentMethod = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedPaymentMethod == 'Thanh toán qua thẻ')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Thông tin thẻ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.blueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Icon(Icons.credit_card,
                                  color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: 40,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '**** **** **** 1234',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'NGUYEN VAN A',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Text(
                                  '12/26',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                _buildTextField(
                  controller: couponController,
                  label: 'Nhập mã giảm giá',
                  icon: Icons.discount,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstant.appScendoryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    final code = couponController.text.trim();
                    if (code.isEmpty) {
                      Get.snackbar('Lỗi', 'Vui lòng nhập mã giảm giá',
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    final result =
                        await OrderService().checkPromotionCode(code, total);
                    if (result != null && result['success'] == true) {
                      final discountAmount =
                          result['data']['discountAmount'] ?? 0.0;
                      setState(() {
                        discount = discountAmount.toDouble();
                      });
                      Get.snackbar(
                        'Thành công',
                        'Áp dụng mã giảm giá thành công! Giảm ${_currencyFormat.format(discount)}đ',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } else {
                      setState(() {
                        discount = 0.0;
                      });
                      Get.snackbar(
                        'Lỗi',
                        result?['message'] ?? 'Mã giảm giá không hợp lệ',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: const Text(
                    'Áp dụng mã giảm giá',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppConstant.appTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng tiền:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${_currencyFormat.format(finalPrice)} đ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstant.appMainColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstant.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty &&
                        addressController.text.isNotEmpty) {
                      final prefs = await SharedPreferences.getInstance();
                      final customerId = prefs.getInt('customerId') ?? 0;

                      if (selectedPaymentMethod == 'Thanh toán qua PayPal') {
                        double totalAmount = cartList.fold(
                            0, (sum, item) => sum + item.productTotalPrice);

                        try {
                          // Step 1: Create Order API Call
                          final createOrderResponse = await http.post(
                            Uri.parse('$BASE_URL/api/Order/Create'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              "customerId":
                                  customerId, // Replace with the actual customer ID
                              "note":
                                 'Tên: ${nameController.text}, SĐT: ${phoneController.text}, Địa chỉ: ${addressController.text}',
                              "promotionId":
                                  0, // Replace with the actual promotion ID if applicable
                              "promotionCode": couponController.text
                                  .trim(), // Replace with the actual promotion code if applicable
                              "cartItems": cartList.map((item) {
                                return {
                                  "productId": item.productId,
                                  "quantity": item.productQuantity,
                                };
                              }).toList(),
                            }),
                          );

                          if (createOrderResponse.statusCode == 200) {
                            final createOrderData =
                                jsonDecode(createOrderResponse.body);
                            final orderId = createOrderData[
                                'data']; // Extract orderId from response

                            // Step 2: Navigate to PayPal Checkout
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  PaypalCheckoutView(
                                sandboxMode: true,
                                clientId:
                                    "AXAl-vVyydICzwStxvMLyA53LuFjVrRONwiZWU5kLqzjOgQGLuKWJ0ajOlzpmiYLi5ea8QrxZ9PP0TG1",
                                secretKey:
                                    "EJT5yyTPgJrsiWJerUbb4BGD2swipXXATg5ui5WAIJN5h-mn1zwqKfNTp28fg9farK7H1aFzsct59_NM",
                                transactions: [
                                  {
                                    "amount": {
                                      "total": totalAmount.toString(),
                                      "currency": "USD",
                                      "details": {
                                        "subtotal": totalAmount.toString(),
                                        "shipping": '0',
                                        "shipping_discount": 0
                                      }
                                    },
                                    "description":
                                        "The payment transaction description.",
                                    "item_list": {
                                      "items": cartList.map((item) {
                                        return {
                                          "name": item.productName,
                                          "quantity": item
                                              .productQuantity, // Replace with the actual quantity
                                          "price": totalAmount.toString(),
                                          "currency": "USD"
                                        };
                                      }).toList(),
                                    }
                                  }
                                ],
                                note:
                                    "Contact us for any questions on your order.",
                                onSuccess: (Map params) async {
                                  try {
                                    // Step 3: Capture Order API Call
                                    final captureOrderResponse = await http.post(
                                        Uri.parse(
                                            '$BASE_URL/api/Order/CaptureOrder?orderId=$orderId'),
                                        headers: {
                                          'Content-Type': 'application/json'
                                        });

                                    if (captureOrderResponse.statusCode ==
                                        200) {
                                      print(
                                          "Order captured successfully: ${captureOrderResponse.body}");
                                      Get.snackbar(
                                        'Thành công',
                                        'Thanh toán thành công!',
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                     Navigator.pop(context); 
                                    } else {
                                      print(
                                          "Failed to capture order: ${captureOrderResponse.body}");
                                      Get.snackbar(
                                        'Lỗi',
                                        'Không thể xác nhận thanh toán!',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  } catch (error) {
                                    print("Error: $error");
                                    Get.snackbar(
                                      'Lỗi',
                                      'Đã xảy ra lỗi khi xử lý thanh toán!',
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  } finally {
                                    Navigator.pop(context);
                                  }
                                },
                                onError: (error) {
                                  print("Payment Error: $error");
                                  Get.snackbar(
                                    'Lỗi',
                                    'Thanh toán PayPal thất bại! Vui lòng thử lại.',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  Navigator.pop(context);
                                },
                                onCancel: () {
                                  print("Payment Cancelled");
                                  Get.snackbar(
                                    'Hủy bỏ',
                                    'Bạn đã hủy thanh toán qua PayPal.',
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            ));
                          } else {
                            print(
                                "Failed to create order: ${createOrderResponse.body}");
                            Get.snackbar(
                              'Lỗi',
                              'Không thể tạo đơn hàng!',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        } catch (error) {
                          print("Error: $error");
                          Get.snackbar(
                            'Lỗi',
                            'Đã xảy ra lỗi khi tạo đơn hàng!',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      } else {
                        // Handle other payment methods
                        final orderService = OrderService();
                        final success = await orderService.createOrder(
                          customerId: customerId,
                          note:
                              'Tên: ${nameController.text}, SĐT: ${phoneController.text}, Địa chỉ: ${addressController.text}',
                          promotionId: 0,
                          promotionCode: couponController.text.trim(),
                          cartList: cartList,
                        );

                        if (success) {
                          Get.offAll(() => MainScreen());
                          Get.snackbar(
                            'Thành công',
                            'Đặt hàng thành công!',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                          await prefs.remove('cart');
                        } else {
                          Get.snackbar(
                            'Lỗi',
                            'Đặt hàng thất bại! Vui lòng thử lại.',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      }
                    } else {
                      Get.snackbar(
                        'Lỗi',
                        'Vui lòng điền đầy đủ thông tin',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: const Text(
                    'Đặt hàng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType? keyboardType,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppConstant.appMainColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppConstant.appMainColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),
  );
}
