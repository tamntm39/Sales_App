import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:chichanka_perfume/models/user-model.dart';
import 'package:chichanka_perfume/screens/user-panel/all-products-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/main-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chichanka_perfume/services/customer/get_customer_service.dart';
import 'package:chichanka_perfume/services/customer/update_customer_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;
  UserModel? _userModel;
  int _selectedIndex = 2;

  File? _avatarImage;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? customerId = prefs.getInt('customerId');
      if (customerId != null) {
        final result = await GetCustomerService().getCustomer(customerId);
        if (result['success']) {
          final data = result['data'];
          final imgUrl = data['image']; // lấy đúng trường 'image' từ BE
          final fullImgUrl = (imgUrl != null && imgUrl.startsWith('/'))
              ? 'http://10.0.2.2:7072$imgUrl'
              : imgUrl ?? '';
          setState(() {
            _userModel = UserModel.fromMap({...data, 'userImg': fullImgUrl});
          });
        } else {
          Get.snackbar(
              "Lỗi", result['message'] ?? "Không thể tải thông tin người dùng");
        }
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải thông tin người dùng");
    }
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    Get.snackbar(
      "Thông báo",
      value ? "Đã bật thông báo" : "Đã tắt thông báo",
      backgroundColor: AppConstant.appMainColor,
      colorText: Colors.white,
    );
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    Get.changeTheme(value ? ThemeData.dark() : ThemeData.light());
    Get.snackbar(
      "Giao diện",
      value ? "Đã chuyển sang chế độ tối" : "Đã chuyển sang chế độ sáng",
      backgroundColor: AppConstant.appMainColor,
      colorText: Colors.white,
    );
  }

  // Hàm hiển thị dialog chỉnh sửa thông tin cá nhân
  void _showEditProfileDialog() {
    final TextEditingController usernameController =
        TextEditingController(text: _userModel?.username);
    final TextEditingController phoneController =
        TextEditingController(text: _userModel?.phone);
    final TextEditingController emailController =
        TextEditingController(text: _userModel?.email);
    final TextEditingController addressController =
        TextEditingController(text: _userModel?.userAddress);
    final TextEditingController passwordController =
        TextEditingController(); // Thêm controller cho mật khẩu mới

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Chỉnh sửa thông tin cá nhân"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration:
                      const InputDecoration(labelText: "Tên người dùng"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Số điện thoại"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Địa chỉ"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: "Mật khẩu mới (bỏ trống nếu không đổi)",
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  int? customerId = prefs.getInt('customerId');
                  if (customerId != null) {
                    final result = await UpdateCustomerService().updateCustomer(
                      customerId: customerId.toString(),
                      fullname: usernameController.text,
                      phone: phoneController.text,
                      email: emailController.text,
                      address: addressController.text,
                      password: passwordController.text.isNotEmpty
                          ? passwordController.text
                          : null, // Chỉ truyền nếu có nhập
                    );
                    if (result['success']) {
                      setState(() {
                        _userModel = _userModel?.copyWith(
                          username: usernameController.text,
                          phone: phoneController.text,
                          email: emailController.text,
                          userAddress: addressController.text,
                        );
                      });
                      Get.snackbar("Thành công", "Thông tin đã được cập nhật");
                      Navigator.pop(context);
                    } else {
                      Get.snackbar("Lỗi",
                          result['message'] ?? "Không thể cập nhật thông tin");
                    }
                  }
                } catch (e) {
                  Get.snackbar("Lỗi", "Không thể cập nhật thông tin");
                }
              },
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
      await _uploadAvatarImage();
    }
  }

  Future<void> _uploadAvatarImage() async {
    if (_avatarImage == null || _userModel == null) return;
    setState(() => _isUploadingAvatar = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      int? customerId = prefs.getInt('customerId');
      if (customerId == null) return;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://10.0.2.2:7072/api/Customer/UploadAvatar/UploadAvatar?customerId=$customerId'),
      );
      request.files
          .add(await http.MultipartFile.fromPath('avatar', _avatarImage!.path));
      var response = await request.send();

      print('Status code: ${response.statusCode}');
      final respStr = await response.stream.bytesToString();
      print('Response body: $respStr');

      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        final fullUrl = 'http://10.0.2.2:7072' + data['imageUrl'];
        setState(() {
          _userModel = _userModel?.copyWith(userImg: fullUrl);
        });
        Get.snackbar("Thành công", "Cập nhật ảnh đại diện thành công!");
      } else {
        Get.snackbar("Lỗi", "Không thể cập nhật ảnh đại diện");
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể cập nhật ảnh đại diện");
    }
    setState(() => _isUploadingAvatar = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cài đặt",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppConstant.navy,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tùy chọn cài đặt",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstant.appMainColor,
                ),
              ),
              const SizedBox(height: 24),

              // Account Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tài khoản",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundImage: _avatarImage != null
                                  ? FileImage(_avatarImage!)
                                  : (_userModel?.userImg != null &&
                                          _userModel!.userImg.isNotEmpty &&
                                          _userModel!.userImg
                                              .startsWith('http'))
                                      ? NetworkImage(_userModel!.userImg)
                                      : const AssetImage(
                                              'assets/images/default_avatar.png')
                                          as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _isUploadingAvatar
                                    ? null
                                    : _pickAvatarImage,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue,
                                  child: _isUploadingAvatar
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : const Icon(Icons.camera_alt,
                                          color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.person,
                            color: AppConstant.appMainColor),
                        title: Text(_userModel?.username ?? "Đang tải..."),
                        subtitle: Text(_userModel?.email ?? ""),
                        trailing: const Icon(Icons.edit),
                        onTap: _showEditProfileDialog,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preferences Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tùy chọn",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        activeColor: AppConstant.appMainColor,
                        title: const Text("Thông báo"),
                        secondary: const Icon(Icons.notifications,
                            color: AppConstant.appMainColor),
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                      ),
                      SwitchListTile(
                        activeColor: AppConstant.appMainColor,
                        title: const Text("Chế độ tối"),
                        secondary: const Icon(Icons.color_lens,
                            color: AppConstant.appMainColor),
                        value: _isDarkMode,
                        onChanged: _toggleTheme,
                      ),
                      ListTile(
                        leading: const Icon(Icons.language,
                            color: AppConstant.appMainColor),
                        title: const Text("Ngôn ngữ"),
                        trailing: DropdownButton<String>(
                          value: "Tiếng Việt",
                          items: const [
                            DropdownMenuItem(
                                value: "Tiếng Việt", child: Text("Tiếng Việt")),
                            DropdownMenuItem(
                                value: "English", child: Text("English")),
                          ],
                          onChanged: (value) {
                            Get.snackbar(
                                "Thông báo", "Thay đổi ngôn ngữ - Sắp ra mắt!");
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(double.infinity, 70),
                painter: BottomNavPainter(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  icon: Icons.shopping_bag,
                  label: 'Sản phẩm',
                  index: 0,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                    Get.to(() => const AllProductsScreen());
                  },
                ),
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Trang chủ',
                  index: 1,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    Get.to(() => const MainScreen());
                  },
                ),
                _buildNavItem(
                  icon: Icons.settings,
                  label: 'Cài đặt',
                  index: 2,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppConstant.navy : Colors.transparent,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 24,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppConstant.navy : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Cập nhật UserModel để hỗ trợ copyWith
extension UserModelExtension on UserModel {
  UserModel copyWith({
    String? username,
    String? email,
    String? phone,
    String? userImg,
    String? userDeviceToken,
    String? country,
    String? userAddress,
    String? street,
    bool? isAdmin,
    bool? isActive,
    dynamic createdOn,
    String? city,
  }) {
    return UserModel(
      uId: uId,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userImg: userImg ?? this.userImg,
      userDeviceToken: userDeviceToken ?? this.userDeviceToken,
      country: country ?? this.country,
      userAddress: userAddress ?? this.userAddress,
      street: street ?? this.street,
      isAdmin: isAdmin ?? this.isAdmin,
      isActive: isActive ?? this.isActive,
      createdOn: createdOn ?? this.createdOn,
      city: city ?? this.city,
    );
  }
}
