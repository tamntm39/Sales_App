import 'package:chichanka_perfume/services/customer/forget_password_service.dart';
import 'package:chichanka_perfume/screens/auth-ui/sign-in-screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpResetPasswordScreen extends StatefulWidget {
  final String email; // chỉ cần email thôi, không cần otp từ bên ngoài

  const OtpResetPasswordScreen({super.key, required this.email});

  @override
  _OtpResetPasswordScreenState createState() => _OtpResetPasswordScreenState();
}

class _OtpResetPasswordScreenState extends State<OtpResetPasswordScreen> {
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  void resetPassword() async {
    final otp = otpController.text.trim();
    final newPassword = passwordController.text.trim();

    if (otp.isEmpty || newPassword.length <= 5) {
      Get.snackbar('Lỗi', 'Vui lòng nhập đầy đủ và hợp lệ',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => isLoading = true);

    // Gọi hàm đúng kiểu tham số
    final response = await ApiService.resetPassword(otp, newPassword);

    setState(() => isLoading = false);

    if (response['success'] == true) {
      Get.snackbar('Thành công', response['message'] ?? 'Đổi mật khẩu thành công',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      // Chuyển về trang đăng nhập
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAll(() => const SignInScreen());
    } else {
      Get.snackbar('Thất bại', response['message'] ?? 'Có lỗi xảy ra',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhập mã OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'Mã OTP'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: resetPassword,
                child: const Text('Đặt lại mật khẩu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}