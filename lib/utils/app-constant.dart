import 'package:flutter/material.dart';

class AppConstant {
  static String appMainName = 'Lala garden';

  // Màu chủ đạo: Xanh lá
  static const Color appMainColor = Color(0xFF2E7D32); // primaryGreen
  static const Color appScendoryColor =
      Color(0xFF81C784); // accentGreen (xanh nhạt)
  static const Color appTextColor = Colors.white;
  static const Color appStatusBarColor = Color(0xFF1B5E20); // darkGreen

  // Đặt tên "navy" để tương thích mấy file cũ nhưng thật ra là xanh lá luôn
  static const Color navy = appMainColor;

  // Nếu cần thêm nữa:
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color accentGreen = Color(0xFF81C784);

  //stripe
  // static String appStripePublishableKey =
  //     "pk_test_51OG4VgFGgW2FUn1jWkkmPmeEa47AMmvO4kJbtdCVNo0irlSfyKmMLQ8HZBiKP1LH88S6vLwEtJ4HAnWC49YSskaI00DpG0T9hc";
  // static String appStripeSecretKey =
  //     "sk_test_51OG4VgFGgW2FUn1jPFGCm6gAyqejLpZUaZqP1AosngXsKW6QujcsR8rgQCban2CWR4HKlFizB1CRKkUuoncqumzu00WI4tUKtD";
}
