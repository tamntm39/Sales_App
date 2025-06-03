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
