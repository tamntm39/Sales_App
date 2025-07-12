import 'dart:convert';
import 'package:chichanka_perfume/controllers/cart-price-controller.dart';
import 'package:chichanka_perfume/models/cart-model.dart';
import 'package:chichanka_perfume/screens/user-panel/confirm_checkout.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chichanka_perfume/config.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final ProductPriceController productPriceController =
      Get.put(ProductPriceController());
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'vi_VN');
  List<CartModel> cartList = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartStringList = prefs.getStringList('cart') ?? [];
    setState(() {
      cartList = cartStringList.map((item) {
        final map = jsonDecode(item);
        if (map['productImages'] is List) {
          map['productImages'] =
              List<String>.from(map['productImages'].map((e) => e.toString()));
        } else if (map['productImages'] is String) {
          map['productImages'] = [map['productImages'].toString()];
        }
        return CartModel.fromMap(map);
      }).toList();
    });
    productPriceController.fetchProductPrice();
  }

  Future<void> _removeFromCart(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartStringList = prefs.getStringList('cart') ?? [];
    cartStringList.removeWhere((item) {
      final map = jsonDecode(item);
      return map['productId'] == productId;
    });
    await prefs.setStringList('cart', cartStringList);
    await _loadCart();
    productPriceController.fetchProductPrice();
    Get.snackbar("Thành công", "Đã xóa sản phẩm khỏi giỏ hàng");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.navy,
        elevation: 0,
        title: const Text(
          'Thanh toán',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: cartList.isEmpty
            ? const Center(
                child: Text(
                  'Không có sản phẩm để thanh toán!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: cartList.length,
                itemBuilder: (context, index) {
                  final cartModel = cartList[index];
                  return _buildCheckoutItem(cartModel);
                },
              ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCheckoutItem(CartModel cartModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SwipeActionCell(
        key: ObjectKey(cartModel.productId),
        trailingActions: [
          SwipeAction(
            title: "Xóa",
            color: Colors.red,
            onTap: (CompletionHandler handler) async {
              await _removeFromCart(cartModel.productId);
            },
          ),
        ],
        child: GestureDetector(
          onTap: () => _showProductDetails(context, cartModel),
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(
                              '$BASE_URL/${cartModel.productImages[0]}',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartModel.productName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cartModel.categoryName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (cartModel.isSale) ...[
                                Text(
                                  '${_currencyFormat.format(double.parse(cartModel.salePrice))} đ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Text(
                                '${_currencyFormat.format(cartModel.productTotalPrice)} đ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppConstant.appMainColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'x${cartModel.productQuantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Row(
                      //   children: [
                      //     Icon(Icons.delivery_dining,
                      //         size: 16, color: Colors.grey[600]),
                      //     const SizedBox(width: 4),
                      //     Text(
                      //       'Giao hàng: ${cartModel.deliveryTime}',
                      //       style: TextStyle(
                      //         fontSize: 14,
                      //         color: Colors.grey[600],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   cartModel.productDescription,
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.grey[700],
                      //   ),
                      //   maxLines: 2,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, CartModel cartModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(
                      image: NetworkImage(
                        '$BASE_URL/${cartModel.productImages[0]}',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartModel.productName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cartModel.categoryName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (cartModel.isSale) ...[
                            Text(
                              '${_currencyFormat.format(double.parse(cartModel.salePrice))} đ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '${_currencyFormat.format(cartModel.productTotalPrice)} đ',
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppConstant.appMainColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.delivery_dining,
                              size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Giao hàng: ${cartModel.deliveryTime}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Mô tả sản phẩm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cartModel.productDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Đóng',
                style: TextStyle(color: AppConstant.appMainColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar() {
    double total =
        cartList.fold(0, (sum, item) => sum + (item.productTotalPrice ?? 0));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tổng: ${_currencyFormat.format(total)} đ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstant.appMainColor,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstant.appMainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: cartList.isEmpty
                ? null
                : () => _showConfirmCheckoutBottomSheet(cartList),
            child: const Text(
              'Xác nhận đơn hàng',
              style: TextStyle(
                fontSize: 16,
                color: AppConstant.appTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Đổi tên hàm để tránh đệ quy vô hạn
  void _showConfirmCheckoutBottomSheet(List<CartModel> cartList) {
    showCustomBottomSheet(cartList);
  }
}
