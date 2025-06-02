// ignore_for_file: file_names, unused_local_variable, avoid_print

import 'dart:convert';
import 'package:chichanka_perfume/screens/user-panel/main-screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleSignInController extends GetxController {
  // Thay YOUR_WEB_CLIENT_ID bằng client id web OAuth 2.0 trong Google Cloud Console
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '122754317810-s8g8tikvthd720j11eefl500s3j5lllo.apps.googleusercontent.com',
  );

  Future<void> signInWithGoogle() async {
    try {
      // Người dùng đăng nhập với Google
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        print("Người dùng đã hủy đăng nhập.");
        return;
      }

      EasyLoading.show(status: "Please wait...");

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final idToken = googleSignInAuthentication.idToken;
      print('idToken lấy được: $idToken');

      if (idToken == null) {
        EasyLoading.dismiss();
        print("Không có idToken, có thể do chưa cấu hình đúng OAuth client.");
        return;
      }

      // Gửi idToken đến backend để xác thực
      final response = await http.post(
        Uri.parse('http://10.0.2.2:7072/api/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Backend xác thực thành công: $data");
        Get.offAll(() => const MainScreen());
      } else {
        print("Backend xác thực thất bại: ${response.body}");
      }
    } catch (e) {
      EasyLoading.dismiss();
      print("Lỗi khi đăng nhập Google: $e");
    }
  }
}
