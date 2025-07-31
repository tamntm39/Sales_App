import 'package:chichanka_perfume/screens/user-panel/all-orders-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/all-products-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/contact-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/favorite-product-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/main-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/personal-suggest-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/settings-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/auth-ui/welcome-screen.dart';
import '../models/user-model.dart';
import '../services/customer/get_customer_service.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  UserModel? _userModel;
  // Thêm biến để theo dõi trạng thái tải dữ liệu
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUserData = true; // Bắt đầu tải dữ liệu
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      int? customerId = prefs.getInt('customerId');
      if (customerId != null) {
        final result = await GetCustomerService().getCustomer(customerId);
        if (result['success']) {
          final data = result['data'];
          final imgUrl = data['image'];
          final fullImgUrl = (imgUrl != null && imgUrl.startsWith('/'))
              ? 'http://10.0.2.2:7072$imgUrl' // Chắc chắn đây là IP chính xác của backend
              : imgUrl ?? ''; // Nếu đã là URL đầy đủ hoặc null/empty

          setState(() {
            _userModel = UserModel.fromMap({...data, 'userImg': fullImgUrl});
          });
          // Debugging prints (bạn có thể xóa sau khi kiểm tra xong)
          print('DEBUG Drawer: customerId: $customerId');
          print('DEBUG Drawer: imgUrl from backend: $imgUrl');
          print('DEBUG Drawer: fullImgUrl: $fullImgUrl');
          print('DEBUG Drawer: userModel username: ${_userModel?.username}');
        } else {
          // Xử lý trường hợp không thành công khi tải thông tin người dùng
          print('DEBUG Drawer: Lỗi tải thông tin người dùng: ${result['message']}');
          Get.snackbar("Lỗi", result['message'] ?? "Không thể tải thông tin người dùng",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
print('DEBUG Drawer: customerId is null. User might not be logged in or data not saved.');
        // Có thể xử lý nếu customerId là null (ví dụ: chuyển hướng đến màn hình đăng nhập)
      }
    } catch (e) {
      print('DEBUG Drawer: Lỗi load user data: $e');
      Get.snackbar("Lỗi", "Không thể tải thông tin người dùng",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() {
        _isLoadingUserData = false; // Kết thúc tải dữ liệu
      });
    }
  }

  // Hàm đăng xuất riêng biệt
  Future<void> _logout() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      FirebaseAuth auth = FirebaseAuth.instance;

      // Đăng xuất khỏi Firebase (nếu đã đăng nhập qua Firebase)
      await auth.signOut();
      // Đăng xuất khỏi Google (nếu đã đăng nhập qua Google)
      await googleSignIn.signOut();

      // Xóa customerId khỏi SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('customerId');
      await prefs.remove('customerEmail');
      await prefs.remove('customerPassword'); // Nếu bạn lưu password

      // Chuyển hướng về màn hình chào mừng
      Get.offAll(() => WelcomeScreen());
      Get.snackbar("Thông báo", "Đã đăng xuất thành công!",
          backgroundColor: AppConstant.appMainColor, colorText: Colors.white);
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
      Get.snackbar("Lỗi", "Không thể đăng xuất. Vui lòng thử lại.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị trạng thái tải hoặc thông tin người dùng
    final avatarUrl = _userModel?.userImg ?? '';
    final username = _userModel?.username ?? 'Đang tải...';
    final email = _userModel?.email ?? 'Đang tải...';

    return Drawer(
      elevation: 8.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      backgroundColor: AppConstant.navy,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 32,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstant.appMainColor.withOpacity(0.9),
                  AppConstant.navy,
                ],
              ),
            ),
            child: Column(
              children: [
                Center(
                  child: _isLoadingUserData
                      ? const CircularProgressIndicator(color: Colors.white) // Hiển thị loading
                      : CircleAvatar(
radius: 40,
                          // Sử dụng FadeInImage để xử lý tải ảnh tốt hơn
                          backgroundImage: (avatarUrl.isNotEmpty && Uri.tryParse(avatarUrl)?.hasAbsolutePath == true)
                              ? NetworkImage(avatarUrl) as ImageProvider
                              : const AssetImage('assets/images/default_avatar.png'),
                          onBackgroundImageError: (exception, stackTrace) {
                            print('DEBUG Drawer: Lỗi tải ảnh đại diện từ URL: $avatarUrl');
                            // Bạn có thể đặt một logic khác ở đây nếu muốn hiển thị ảnh lỗi cụ thể
                          },
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isLoadingUserData ? 'Đang tải...' : username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isLoadingUserData ? '' : email, // Không hiển thị email khi đang tải
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            indent: 16,
            endIndent: 16,
            thickness: 1,
            color: Colors.grey,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildMenuItem("Trang chủ", Icons.home, () {
                  Get.back(); // Đóng Drawer
                  if (Get.currentRoute != '/MainScreen') { // Kiểm tra để tránh push lại chính nó
                    Get.to(() => const MainScreen());
                  }
                }),
                _buildMenuItem("Sản phẩm", Icons.production_quantity_limits, () {
                  Get.back();
                  if (Get.currentRoute != '/AllProductsScreen') {
                    Get.to(() => const AllProductsScreen());
                  }
                }),
                _buildMenuItem("Sản phẩm yêu thích", Icons.favorite, () {
                  Get.back();
                  if (Get.currentRoute != '/FavouriteProductScreen') {
                    Get.to(() => const FavouriteProductScreen());
                  }
                }),
                _buildMenuItem("Đơn hàng", Icons.shopping_bag, () {
                  Get.back();
                  if (Get.currentRoute != '/AllOrdersScreen') {
                    Get.to(() => const AllOrdersScreen());
                  }
                }),
                _buildMenuItem("Gợi ý sản phẩm", Icons.recommend, () {
                  Get.back();
if (Get.currentRoute != '/PersonalizedSuggestionsScreen') {
                    Get.to(() => const PersonalizedSuggestionsScreen());
                  }
                }),
                _buildMenuItem("Liên hệ", Icons.help, () {
                  Get.back();
                  if (Get.currentRoute != '/ContactScreen') {
                    Get.to(() => const ContactScreen());
                  }
                }),
                _buildMenuItem("Cài đặt", Icons.settings, () {
                  Get.back();
                  if (Get.currentRoute != '/SettingsScreen') {
                    Get.to(() => const SettingsScreen());
                  }
                }),
                const SizedBox(height: 16),
                _buildMenuItem("Đăng xuất", Icons.logout, _logout, isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap,
      {bool isLogout = false}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : AppConstant.appMainColor,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isLogout ? Colors.red : Colors.black,
        ),
        tileColor: Colors.white.withOpacity(0.95),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}



