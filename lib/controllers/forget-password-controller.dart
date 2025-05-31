import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/customer/forget_password_service.dart';
import '../screens/auth-ui/otp-reset-password-screen.dart'; // import màn hình OTP

class ForgetPasswordController extends GetxController {
  var isLoading = false.obs;

  Future<void> ForgetPasswordMethod(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar('Lỗi', 'Vui lòng nhập email hợp lệ',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      final response = await ApiService.forgotPassword(email);

      isLoading.value = false;

      if (response['success'] == true) {
        Get.snackbar(
          'Thành công',
          'Mã OTP đã được gửi. Vui lòng kiểm tra email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // ✅ Điều hướng sang màn hình nhập OTP
        Get.to(() => OtpResetPasswordScreen(email: email));
      } else {
        Get.snackbar(
          'Thất bại',
          response['message'] ?? 'Lỗi không xác định',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Lỗi',
        'Có lỗi xảy ra: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
