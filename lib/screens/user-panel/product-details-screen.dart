import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chichanka_perfume/controllers/cart-controller.dart';
import 'package:chichanka_perfume/models/cart-model.dart';
import 'package:chichanka_perfume/models/product-model.dart';
import 'package:chichanka_perfume/models/product_api_model.dart';
import 'package:chichanka_perfume/screens/user-panel/cart-screen.dart';
import 'package:chichanka_perfume/services/product_service.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';
import 'package:chichanka_perfume/services/favorite_service.dart';
import 'package:chichanka_perfume/services/order_service.dart';
import 'package:chichanka_perfume/models/order_api_model.dart';
import 'package:chichanka_perfume/models/review_api_model.dart';
import 'package:chichanka_perfume/services/review_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel productModel;
  final ProductApiModel? productApiModel;
  final List<ProductApiModel>? allProducts;

  const ProductDetailsScreen({
    super.key,
    required this.productModel,
    this.productApiModel,
    this.allProducts,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

// Chuyển đổi từ SaleOffProduct (hoặc Map) sang ProductModel
ProductModel convertToProductModel(dynamic apiProduct) {
  return ProductModel(
    productId: apiProduct['productId'].toString(),
    categoryId: '', // hoặc lấy từ API nếu có
    productName: apiProduct['name'] ?? '',
    categoryName: '', // hoặc lấy từ API nếu có
    salePrice: (apiProduct['finalPrice'] ?? 0).toString(),
    fullPrice: (apiProduct['priceOutput'] ?? 0).toString(),
    productImages: [apiProduct['img'] ?? ''],
    deliveryTime: '',
    isSale: true,
    productDescription: '',
    createdAt: '',
    updatedAt: '',
  );
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  List<ProductApiModel> relatedProducts = [];
  bool isFavorite = false;
  bool isAnimatingFavorite = false;
  int? customerId;
  final CartController cartController = Get.put(CartController());
  List<ReviewApiModel> productReviews = [];
  final TextEditingController _feedbackController = TextEditingController();
  double rating = 5.0;
  bool canReview = false;
  bool isCheckingReview = true;
  String getFullImageUrl(String url) {
    if (url.startsWith("http")) return url;
    return "$BASE_URL/$url";
  }

  List<String> getAllProductImages() {
    if (widget.productApiModel != null) {
      print("🔍 img: ${widget.productApiModel!.img}");
      print("🔍 img2: ${widget.productApiModel!.img2}");
      print("🔍 img3: ${widget.productApiModel!.img3}");
      List<String> images = [];
      if (widget.productApiModel!.img.isNotEmpty)
        images.add(widget.productApiModel!.img);
      if (widget.productApiModel!.img2 != null &&
          widget.productApiModel!.img2!.isNotEmpty) {
        images.add(widget.productApiModel!.img2!);
      }
      if (widget.productApiModel!.img3 != null &&
          widget.productApiModel!.img3!.isNotEmpty) {
        images.add(widget.productApiModel!.img3!);
      }
      print("🖼️ Ảnh từ ProductApiModel: $images");
      return images;
    } else {
      return widget.productModel.productImages;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProductReviews();
    loadCustomerIdAndCheckFavorite();
    checkIfCanReview();
    fetchRelated();
    print("🖼️ Danh sách ảnh: ${widget.productModel.productImages}");
  }

  // Kiểm tra xem người dùng có thể đánh giá sản phẩm này không
  Future<void> checkIfCanReview() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt('customerId');
    if (customerId == null) return;

    final orders = await OrderService().getOrdersByCustomerId(customerId);
    setState(() {
      canReview = orders.any((order) =>
          order.productId == int.tryParse(widget.productModel.productId));
      isCheckingReview = false;
    });
  }

  // Lấy danh sách đánh giá sản phẩm
  Future<void> fetchProductReviews() async {
    final productId = int.tryParse(widget.productModel.productId) ?? 0;
    print('productId gọi API: $productId');
    final reviews = await ReviewService.getReviewsByProductId(productId);
    setState(() {
      productReviews = reviews;
    });
  }

  // Gửi đánh giá sản phẩm
  Future<void> submitReview() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt('customerId');
    if (customerId == null) return;

    final review = ReviewApiModel(
      reviewId: 0,
      customerId: customerId,
      productId: int.tryParse(widget.productModel.productId) ?? 0,
      comment: _feedbackController.text,
      fullName: '', // Bạn có thể lấy tên đầy đủ từ thông tin người dùng nếu cần
    );

    final success = await ReviewService.createReview(review);

    if (success) {
      _feedbackController.clear();
      await fetchProductReviews();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gửi đánh giá thành công")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gửi đánh giá thất bại")),
      );
    }
  }

  Future<void> loadCustomerIdAndCheckFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    customerId = prefs.getInt('customerId');
    if (customerId != null) {
      isFavorite = await FavoriteService()
          .isFavorite(customerId!, int.parse(widget.productModel.productId));
      setState(() {});
    }
  }

  Future<void> fetchRelated() async {
    if (widget.allProducts == null || widget.allProducts!.isEmpty) {
      print("⚠️ Không có danh sách sản phẩm để lọc.");
      return;
    }

    final currentCategory =
        widget.productModel.categoryName.trim().toLowerCase();
    final currentProductId = int.tryParse(widget.productModel.productId);

    if (currentProductId == null) {
      print("❌ Không thể phân tích productId hiện tại.");
      return;
    }

    final filtered = widget.allProducts!
        .where((p) =>
            p.categoryName.trim().toLowerCase() == currentCategory &&
            p.productId != currentProductId)
        .take(5)
        .toList();

    print("📦 Sản phẩm liên quan lấy được (LOCAL): ${filtered.length}");
    for (var item in filtered) {
      print("🪴 ${item.productName} - ${item.img}");
    }

    setState(() {
      relatedProducts = filtered;
      print("✅ Đã cập nhật relatedProducts: ${relatedProducts.length}");
    });
  }

  Future<void> toggleFavorite() async {
    if (customerId == null) {
      Get.snackbar("Lỗi", "Vui lòng đăng nhập để sử dụng tính năng này");
      return;
    }
    setState(() {
      isAnimatingFavorite = true;
    });
    bool result;
    if (isFavorite) {
      result = await FavoriteService().removeFavorite(
          customerId!, int.parse(widget.productModel.productId));
      if (result) {
        setState(() {
          isFavorite = false;
        });
        Get.snackbar("Đã xóa", "Đã xóa khỏi danh sách yêu thích");
      }
    } else {
      result = await FavoriteService()
          .addFavorite(customerId!, int.parse(widget.productModel.productId));
      if (result) {
        setState(() {
          isFavorite = true;
        });
        Get.snackbar("Thành công", "Đã thêm vào danh sách yêu thích");
      }
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => isAnimatingFavorite = false);
    });
  }

  String formatPrice(String price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(double.parse(price));
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
        productImages: widget.productModel.productImages, // ✅ ĐÚNG
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

  @override
  Widget build(BuildContext context) {
    print('productReviews.length: ${productReviews.length}');
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
                  items: getAllProductImages()
                      .map(
                        (imageUrl) => ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: CachedNetworkImage(
                            imageUrl: '$BASE_URL/$imageUrl',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.green),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(Icons.local_florist,
                                  size: 60, color: Colors.green.shade300),
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
                            GestureDetector(
                              onTap: toggleFavorite,
                              child: AnimatedScale(
                                scale: isAnimatingFavorite ? 1.3 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isFavorite
                                        ? Colors.red.shade50
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isFavorite ? Colors.red : Colors.grey,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
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
              // Đánh giá sản phẩm
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Đánh giá sản phẩm",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Danh sách đánh giá hiện đại
                    if (productReviews.isEmpty)
                      const Text("Chưa có đánh giá nào."),
                    if (productReviews.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: productReviews.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final review = productReviews[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Icon(Icons.person,
                                    color: Colors.green.shade700),
                              ),
                              title: Text(
                                review.comment,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                "Tài Khoản: ${review.fullName}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 16),

                    // Form đánh giá nếu được phép
                    if (!isCheckingReview && canReview) ...[
                      Text("Viết đánh giá của bạn:",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _feedbackController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Cảm nghĩ của bạn...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Gửi đánh giá"),
                      )
                    ] else if (!isCheckingReview) ...[
                      const Text(
                          "Bạn cần mua sản phẩm này mới có thể đánh giá."),
                    ],
                  ],
                ),
              ),

              // Sản phẩm cùng loại
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sản phẩm cùng loại",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        itemBuilder: (context, index) {
                          final product = relatedProducts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      ProductDetailsScreen(
                                    key: UniqueKey(),
                                    productModel: ProductModel(
                                      productId: product.productId.toString(),
                                      productName: product.productName,
                                      categoryId: product.categoryId.toString(),
                                      categoryName: product.categoryName,
                                      fullPrice: product.priceOutput.toString(),
                                      salePrice: product.priceOutput.toString(),
                                      isSale: false,
                                      productDescription: product.description,
                                      productImages: [product.img ?? ''],
                                      deliveryTime: "2-3 ngày",
                                      createdAt: null,
                                      updatedAt: null,
                                    ),
                                    productApiModel: product,
                                    allProducts: widget.allProducts,
                                  ),
                                  transitionDuration:
                                      Duration(milliseconds: 300),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 12),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            '$BASE_URL/${product.img ?? ''}',
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          color: Colors.green.shade50,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                        errorWidget: (_, __, ___) =>
                                            Icon(Icons.broken_image),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.productName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${formatPrice(product.priceOutput.toString())} VNĐ",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
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
