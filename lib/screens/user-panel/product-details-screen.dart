import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chichanka_perfume/controllers/cart-controller.dart';
import 'package:chichanka_perfume/models/cart-model.dart';
import 'package:chichanka_perfume/models/product-model.dart';
import 'package:chichanka_perfume/screens/user-panel/cart-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel productModel;
  const ProductDetailsScreen({super.key, required this.productModel});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isFavorite = false;
  final CartController cartController = Get.put(CartController());

  String formatPrice(String price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(double.parse(price));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green.shade700,
        title: const Text(
          "Chi tiết cây cảnh",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() => Stack(
                children: [
                  GestureDetector(
                    onTap: () => Get.to(() => CartScreen()),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedScale(
                        scale: cartController.isAddingToCart.value ? 1.2 : 1.0,
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (cartController.cartItemCount.value > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            '${cartController.cartItemCount.value}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height / 60),
              // Hình ảnh sản phẩm
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: CarouselSlider(
                  items: widget.productModel.productImages
                      .map(
                        (imageUrls) => ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: CachedNetworkImage(
                            imageUrl:
                                '$BASE_URL/${widget.productModel.productImages.first}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.local_florist,
                                size: 60,
                                color: Colors.green.shade300,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  options: CarouselOptions(
                    scrollDirection: Axis.horizontal,
                    autoPlay: true,
                    aspectRatio: 1.0,
                    viewportFraction: 1,
                  ),
                ),
              ),

              // Thông tin sản phẩm
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.green.shade50,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                widget.productModel.productName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                            // Nếu muốn giữ nút yêu thích local thì code thêm ở đây
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Giá
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.attach_money,
                                  color: Colors.green.shade700, size: 20),
                              Text(
                                "Giá: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              Text(
                                "${formatPrice(widget.productModel.isSale ? widget.productModel.salePrice : widget.productModel.fullPrice)} VNĐ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Danh mục
                        Row(
                          children: [
                            Icon(Icons.category,
                                color: Colors.green.shade600, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Loại cây: ${widget.productModel.categoryName}",
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Mô tả
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mô tả chi tiết:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                widget.productModel.productDescription,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildButton(
                                text: "Tư vấn Zalo",
                                icon: Icons.chat,
                                color: Colors.blue.shade600,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildButton(
                                text: "Thêm vào giỏ",
                                icon: Icons.add_shopping_cart,
                                color: Colors.green.shade600,
                                onPressed: () async {
                                  await addToCartLocal();
                                  cartController.triggerAddToCartAnimation();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Box dịch vụ
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dịch vụ của chúng tôi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.2,
                      children: [
                        _buildServiceBox(
                          icon: Icons.local_shipping,
                          title: "Giao hàng tận nơi",
                          subtitle: "Miễn phí trong nội thành",
                          color: Colors.blue,
                        ),
                        _buildServiceBox(
                          icon: Icons.spa,
                          title: "Chăm sóc cây",
                          subtitle: "Hướng dẫn chi tiết",
                          color: Colors.green,
                        ),
                        _buildServiceBox(
                          icon: Icons.support_agent,
                          title: "Tư vấn 24/7",
                          subtitle: "Hỗ trợ kỹ thuật",
                          color: Colors.orange,
                        ),
                        _buildServiceBox(
                          icon: Icons.autorenew,
                          title: "Đổi trả dễ dàng",
                          subtitle: "Trong vòng 7 ngày",
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Cây cảnh phong thủy info
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Colors.green.shade100, Colors.green.shade50],
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.eco,
                                color: Colors.green.shade700, size: 24),
                            SizedBox(width: 8),
                            Text(
                              "Lợi ích của cây cảnh",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildBenefitItem("🌿 Thanh lọc không khí, tạo oxy"),
                        _buildBenefitItem("🍀 Mang lại may mắn, tài lộc"),
                        _buildBenefitItem("🌱 Giảm stress, thư giãn tinh thần"),
                        _buildBenefitItem("🏠 Trang trí nhà cửa thêm xanh mát"),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addToCartLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartList = prefs.getStringList('cart') ?? [];

    int index = cartList.indexWhere((item) {
      final map = jsonDecode(item);
      return map['productId'] == widget.productModel.productId;
    });

    if (index != -1) {
      final map = jsonDecode(cartList[index]);
      map['productQuantity'] += 1;
      map['productTotalPrice'] =
          double.parse(map['fullPrice']) * map['productQuantity'];
      cartList[index] = jsonEncode(map);
      Get.snackbar("Thành công", "Đã cập nhật số lượng cây trong giỏ hàng");
    } else {
      CartModel cartModel = CartModel(
        productId: widget.productModel.productId,
        categoryId: widget.productModel.categoryId,
        productName: widget.productModel.productName,
        categoryName: widget.productModel.categoryName,
        salePrice: widget.productModel.salePrice,
        fullPrice: widget.productModel.fullPrice,
        productImages: widget.productModel.productImages,
        deliveryTime: widget.productModel.deliveryTime,
        isSale: widget.productModel.isSale,
        productDescription: widget.productModel.productDescription,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        productQuantity: 1,
        productTotalPrice: double.parse(widget.productModel.isSale
            ? widget.productModel.salePrice
            : widget.productModel.fullPrice),
      );
      cartList.add(jsonEncode(cartModel.toMap()));
      Get.snackbar("Thành công", "Đã thêm cây vào giỏ hàng");
    }

    await prefs.setStringList('cart', cartList);
    cartController.fetchCartItemCount();
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 3,
      ),
    );
  }

  Widget _buildServiceBox({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), Colors.white],
          ),
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
          height: 1.3,
        ),
      ),
    );
  }
}
