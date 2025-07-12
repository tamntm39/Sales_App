import 'dart:convert';
import 'package:chichanka_perfume/models/cart-model.dart';
import 'package:chichanka_perfume/services/order_service.dart';
import 'package:chichanka_perfume/services/ghn_service.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chichanka_perfume/screens/user-panel/main-screen.dart';
import 'package:http/http.dart' as http;
import 'package:chichanka_perfume/config.dart';
import 'package:chichanka_perfume/models/address_model.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

void showCustomBottomSheet(List<CartModel> cartList) {
  final TextEditingController couponController = TextEditingController();
  String selectedPaymentMethod = 'Thanh toán khi nhận hàng';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController detailAddressController = TextEditingController();
  final NumberFormat currencyFormat = NumberFormat('#,##0', 'vi_VN');
  double discount = 0.0;

  // Biến trạng thái cho địa chỉ GHN
  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;
  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];

  // Biến trạng thái phí vận chuyển
  int? shippingFee;
  bool isCalculatingShipping = false;

  // Thêm biến trạng thái để kiểm soát hiệu ứng tải QR
  bool isLoadingQr = false;

  Future<void> loadProvinces(StateSetter setState) async {
    provinces = await GhnService.fetchProvinces();
    if (provinces.isNotEmpty) {
      selectedProvince = provinces.first;
      districts = await GhnService.fetchDistricts(selectedProvince!.id);
      if (districts.isNotEmpty) {
        selectedDistrict = districts.first;
        wards = await GhnService.fetchWards(selectedDistrict!.id);
        if (wards.isNotEmpty) {
          selectedWard = wards.first;
        }
      }
    }
    setState(() {});
  }

  Future<void> calculateShipping(StateSetter setState) async {
    if (selectedDistrict != null && selectedWard != null) {
      setState(() {
        isCalculatingShipping = true;
      });
      try {
        // fromDistrictId: ID quận/huyện của shop bạn trên GHN (ví dụ: 1450 là Quận 1, HCM)
        shippingFee = await GhnService.calculateShippingFee(
          fromDistrictId: 1454, // Thay bằng ID thực tế của shop bạn
          toDistrictId: selectedDistrict!.id,
          toWardCode: selectedWard!.code,
          weight: 2000, // gram
          length: 50, // cm
          width: 50, // cm
          height: 100, // cm
        );
      } catch (e) {
        shippingFee = null;
        Get.snackbar('Lỗi', 'Không thể tính phí vận chuyển');
      }
      setState(() {
        isCalculatingShipping = false;
      });
    }
  }

  Get.bottomSheet(
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        // Tải dữ liệu tỉnh/thành khi mở sheet lần đầu
        if (provinces.isEmpty) {
          loadProvinces(setState);
          return const Center(child: CircularProgressIndicator());
        }

        // Tính tổng tiền từ cartList
        double total = cartList.fold(
            0, (sum, item) => sum + (item.productTotalPrice ?? 0));
        double finalPrice = total - discount + (shippingFee ?? 0);

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
                // Địa chỉ GHN
                DropdownButtonFormField<Province>(
                  value: selectedProvince,
                  items: provinces
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.name),
                          ))
                      .toList(),
                  onChanged: (Province? value) async {
                    setState(() {
                      selectedProvince = value;
                      selectedDistrict = null;
                      selectedWard = null;
                      districts = [];
                      wards = [];
                      shippingFee = null;
                    });
                    if (value != null) {
                      districts = await GhnService.fetchDistricts(value.id);
                      setState(() {
                        if (districts.isNotEmpty) {
                          selectedDistrict = districts.first;
                        }
                      });
                      if (districts.isNotEmpty) {
                        wards = await GhnService.fetchWards(districts.first.id);
                        setState(() {
                          if (wards.isNotEmpty) selectedWard = wards.first;
                        });
                        await calculateShipping(setState);
                      }
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tỉnh/Thành phố',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<District>(
                  value: selectedDistrict,
                  items: districts
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d.name),
                          ))
                      .toList(),
                  onChanged: (District? value) async {
                    setState(() {
                      selectedDistrict = value;
                      selectedWard = null;
                      wards = [];
                      shippingFee = null;
                    });
                    if (value != null) {
                      wards = await GhnService.fetchWards(value.id);
                      setState(() {
                        if (wards.isNotEmpty) selectedWard = wards.first;
                      });
                      await calculateShipping(setState);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Quận/Huyện',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Ward>(
                  value: selectedWard,
                  items: wards
                      .map((w) => DropdownMenuItem(
                            value: w,
                            child: Text(w.name),
                          ))
                      .toList(),
                  onChanged: (Ward? value) async {
                    setState(() {
                      selectedWard = value;
                      shippingFee = null;
                    });
                    await calculateShipping(setState);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Phường/Xã',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: detailAddressController,
                  label: 'Số nhà, tên đường (bắt buộc)',
                  icon: Icons.home,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Phí vận chuyển:',
                      style: TextStyle(fontSize: 16),
                    ),
                    isCalculatingShipping
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            shippingFee != null
                                ? '${currencyFormat.format(shippingFee)} đ'
                                : 'Chọn địa chỉ',
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
                    'Thanh toán mã QR',
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
                      if (newValue == 'Thanh toán mã QR') {
                        isLoadingQr = true;
                        Future.delayed(const Duration(seconds: 2), () {
                          if (context.mounted) {
                            setState(() {
                              isLoadingQr = false;
                            });
                          }
                        });
                      } else {
                        isLoadingQr = false;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedPaymentMethod == 'Thanh toán mã QR')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Quét mã QR để thanh toán',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: isLoadingQr
                              ? Center(
                                  key: const ValueKey('loading'),
                                  child: CircularProgressIndicator(
                                    color: AppConstant.appMainColor,
                                  ),
                                )
                              : Center(
                                  key: const ValueKey('qr_code'),
                                  child: Image.asset(
                                    'assets/images/maqr.jpg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
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
                    backgroundColor: AppConstant.appMainColor,
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
                        'Áp dụng mã giảm giá thành công! Giảm ${currencyFormat.format(discount)}đ',
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
                      '${currencyFormat.format(finalPrice)} đ',
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
                        detailAddressController.text.isNotEmpty &&
                        selectedProvince != null &&
                        selectedDistrict != null &&
                        selectedWard != null) {
                      final prefs = await SharedPreferences.getInstance();
                      final customerId = prefs.getInt('customerId') ?? 0;

                      final fullAddress =
                          '${detailAddressController.text}, ${selectedWard!.name}, ${selectedDistrict!.name}, ${selectedProvince!.name}';

                      if (selectedPaymentMethod == 'Thanh toán qua PayPal') {
                        double totalAmount = cartList.fold(
                            0, (sum, item) => sum + item.productTotalPrice);

                        try {
                          // Step 1: Create Order API Call
                          final createOrderResponse = await http.post(
                            Uri.parse('$BASE_URL/api/Order/Create'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              "customerId": customerId,
                              "note":
                                  'Tên: ${nameController.text}, SĐT: ${phoneController.text}, Địa chỉ: $fullAddress',
                              "promotionId": 0,
                              "promotionCode": couponController.text.trim(),
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
                            final orderId = createOrderData['data'];

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
                                          "quantity": item.productQuantity,
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
                                      await prefs.remove('cart');
                                      Future.delayed(Duration(seconds: 1), () {
                                        Get.offAll(() => MainScreen());
                                      });
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
                              'Tên: ${nameController.text}, SĐT: ${phoneController.text}, Địa chỉ: $fullAddress',
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
