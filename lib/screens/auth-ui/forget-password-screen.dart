import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/forget-password-controller.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({super.key});

  final ForgetPasswordController forgerPasswordController =
  Get.put(ForgetPasswordController());

  final TextEditingController userEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.navy,
        centerTitle: true,
        title: Text(
          "Quên mật khẩu",
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: userEmail,
              cursorColor: AppConstant.navy,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Nhập email của bạn",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstant.navy,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  "Gửi yêu cầu",
                  style: TextStyle(
                    color: AppConstant.appTextColor,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  forgerPasswordController
                      .ForgetPasswordMethod(userEmail.text.trim());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
