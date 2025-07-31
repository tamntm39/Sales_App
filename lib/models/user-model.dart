class UserModel {
  final String uId;
  final String username;
  final String email;
  final String phone;
  final String userAddress;
  final bool isActive;

  // Các trường không có trong BE để giá trị mặc định hoặc bỏ luôn nếu không dùng
  final String userImg;
  final String userDeviceToken;
  final String country;
  final String street;
  final bool isAdmin;
  final dynamic createdOn;
  final String city;

  UserModel({
    required this.uId,
    required this.username,
    required this.email,
    required this.phone,
    required this.userAddress,
    required this.isActive,
    this.userImg = '',
    this.userDeviceToken = '',
    this.country = '',
    this.street = '',
    this.isAdmin = false,
    this.createdOn,
    this.city = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      uId: json['customerId']?.toString() ?? '',
      username: json['fullname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userAddress: json['address'] ?? '',
      isActive: json['isActive'] ?? false,
      // Các trường dưới đây sẽ luôn có giá trị mặc định nếu BE không trả về
      userImg: json['userImg'] ?? '',
      userDeviceToken: json['userDeviceToken'] ?? '',
      country: json['country'] ?? '',
      street: json['street'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      createdOn: json['createdOn'],
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': uId,
      'fullname': username,
      'email': email,
      'phone': phone,
      'address': userAddress,
      'isActive': isActive,
      'userImg': userImg,
      'userDeviceToken': userDeviceToken,
      'country': country,
      'street': street,
      'isAdmin': isAdmin,
      'createdOn': createdOn,
      'city': city,
    };
  }
}



