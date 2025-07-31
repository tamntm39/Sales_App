import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user-model.dart';
import '../services/google_auth_service.dart';
import '../services/customer/get_customer_service.dart';

class GoogleSignInController extends GetxController {
  var userModel = Rxn<UserModel>();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    //clientId: '122754317810-s8g8tikvthd720j11eefl500s3j5lllo.apps.googleusercontent.com', // Đặt đúng clientId Web
  );

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Get.snackbar('Thông báo', 'Bạn đã hủy đăng nhập Google.');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        Get.snackbar('Lỗi', 'Không lấy được idToken.');
        return;
      }

      final response = await GoogleAuthService().googleSignIn(googleAuth.idToken!);

      if (response['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('customerId', response['data']['customerId']);

        await loadUserData();

        Get.snackbar('Thành công', 'Đăng nhập Google thành công.');

        // Ví dụ: chuyển sang Home
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Lỗi', response['message'] ?? 'Đăng nhập Google thất bại.');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đăng nhập Google thất bại: $e');
    }
  }

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? customerId = prefs.getInt('customerId');

      if (customerId != null) {
        final result = await GetCustomerService().getCustomer(customerId);

        if (result['success']) {
          final data = result['data'];
          final imgUrl = data['image'];
          final fullImgUrl = (imgUrl != null && imgUrl.startsWith('/'))
              ? 'http://10.0.2.2:7072$imgUrl'
              : imgUrl ?? '';

          userModel.value = UserModel.fromMap({...data, 'userImg': fullImgUrl});
        } else {
          Get.snackbar('Lỗi', result['message'] ?? 'Không thể tải thông tin người dùng.');
        }
      } else {
        Get.snackbar('Lỗi', 'Không tìm thấy customerId trong thiết bị.');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải thông tin người dùng: $e');
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('customerId');

      userModel.value = null;

      Get.snackbar('Thành công', 'Đăng xuất Google thành công.');
      Get.offAllNamed('/login'); // Ví dụ chuyển về màn hình login
    } catch (e) {
      Get.snackbar('Lỗi', 'Đăng xuất Google thất bại: $e');
    }
  }
}
