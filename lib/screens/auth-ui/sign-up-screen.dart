import 'package:chichanka_perfume/screens/auth-ui/sign-in-screen.dart';
import 'package:chichanka_perfume/services/auth_register_service.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthRegisterService _registerService = AuthRegisterService();
  TextEditingController username = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  TextEditingController userPhone = TextEditingController();
  TextEditingController userCity = TextEditingController();
  TextEditingController userPassword = TextEditingController();
  RxBool isPasswordVisible = true.obs;

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppConstant.navy,
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Đăng Ký",
              style: TextStyle(
                color: AppConstant.appTextColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(height: Get.height / 20),
                  Text(
                    "Chào mừng đến với Garden",
                    style: TextStyle(
                      color: AppConstant.navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: Get.height / 20),
                  _buildTextField(
                    controller: userEmail,
                    hintText: "Email",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller: username,
                    hintText: "Tên người dùng",
                    icon: Icons.person,
                    keyboardType: TextInputType.name,
                  ),
                  _buildTextField(
                    controller: userPhone,
                    hintText: "Số điện thoại",
                    icon: Icons.phone,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: userCity,
                    hintText: "Thành phố",
                    icon: Icons.location_pin,
                    keyboardType: TextInputType.streetAddress,
                  ),
                  _buildPasswordField(),
                  SizedBox(height: Get.height / 20),
                  _buildSignUpButton(),
                  SizedBox(height: Get.height / 20),
                  _buildSignInRow(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        cursorColor: AppConstant.navy,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: AppConstant.navy),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppConstant.navy),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Obx(
        () => TextFormField(
          controller: userPassword,
          obscureText: isPasswordVisible.value,
          cursorColor: AppConstant.navy,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            hintText: "Mật khẩu",
            prefixIcon: Icon(Icons.password, color: AppConstant.navy),
            suffixIcon: GestureDetector(
              onTap: () => isPasswordVisible.toggle(),
              child: Icon(
                isPasswordVisible.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppConstant.navy,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding:
                EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: AppConstant.navy),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(25.0),
      child: Container(
        width: Get.width / 2,
        height: Get.height / 16,
        decoration: BoxDecoration(
          color: AppConstant.navy,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: TextButton(
          onPressed: () async {
            String name = username.text.trim();
            String email = userEmail.text.trim();
            String phone = userPhone.text.trim();
            String city = userCity.text.trim();
            String password = userPassword.text.trim();

            if (name.isEmpty ||
                email.isEmpty ||
                phone.isEmpty ||
                city.isEmpty ||
                password.isEmpty) {
              Get.snackbar(
                "Lỗi",
                "Vui lòng nhập đầy đủ thông tin",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppConstant.navy,
                colorText: AppConstant.appTextColor,
              );
            } else {
              final result = await _registerService.registerCustomer(
                fullName: name,
                phone: phone,
                address: city,
                email: email,
                username: name, // hoặc sử dụng tên đăng nhập khác nếu có
                password: password,
              );
              print(result);
              if (result['success'] == true) {
                Get.snackbar(
                  "Đăng ký thành công",
                  "Vui lòng kiểm tra email để xác nhận tài khoản",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppConstant.navy,
                  colorText: AppConstant.appTextColor,
                );
                Get.off(() => SignInScreen());
              } else {
                Get.snackbar(
                  "Lỗi",
                  result['message'] ?? "Đăng ký thất bại",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppConstant.navy,
                  colorText: AppConstant.appTextColor,
                );
              }
            }
          },
          child: Text(
            "ĐĂNG KÝ",
            style: TextStyle(
              color: AppConstant.appTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Đã có tài khoản? ",
          style: TextStyle(color: AppConstant.navy),
        ),
        GestureDetector(
          onTap: () => Get.off(() => SignInScreen()),
          child: Text(
            "Đăng nhập",
            style: TextStyle(
              color: AppConstant.navy,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
