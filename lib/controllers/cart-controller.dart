import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartController extends GetxController {
  final RxInt cartItemCount = 0.obs;
  final RxBool isAddingToCart = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCartItemCount();
  }

  Future<void> fetchCartItemCount() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartList = prefs.getStringList('cart') ?? [];
    cartItemCount.value = cartList.length;
  }

  void triggerAddToCartAnimation() {
    isAddingToCart.value = true;
    Future.delayed(Duration(milliseconds: 500), () {
      isAddingToCart.value = false;
    });
  }
}
