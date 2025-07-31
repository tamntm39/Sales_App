import 'package:chichanka_perfume/controllers/cart-controller.dart';
import 'package:chichanka_perfume/screens/user-panel/all-brands-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/all-categories-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/all-flash-sale-products.dart';
import 'package:chichanka_perfume/screens/user-panel/all-products-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/cart-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/product-details-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/settings-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:chichanka_perfume/widgets/all-brands-widget.dart';
import 'package:chichanka_perfume/widgets/banner-widget.dart';
import 'package:chichanka_perfume/widgets/category-widget.dart';
import 'package:chichanka_perfume/widgets/custom-drawer-widget.dart';
import 'package:chichanka_perfume/widgets/flash-sale-widget.dart';
import 'package:chichanka_perfume/widgets/heading-widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_card/image_card.dart';
import 'package:intl/intl.dart';
import 'package:chichanka_perfume/models/product_api_model.dart';
import 'package:chichanka_perfume/services/product_service.dart';
import '../../config.dart';
import 'package:chichanka_perfume/screens/user-panel/ai-chat-screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  String searchQuery = '';
  final CartController cartController = Get.put(CartController());
  int _selectedIndex = 1;
  AnimationController? _controller;
  Animation<double>? _animation;
  final List<ProductApiModel> recentlyViewedProducts = [];
  List<ProductApiModel> allProducts = [];
  bool isLoadingProducts = false;
  String productLoadError = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 1).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
    );
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoadingProducts = true;
      productLoadError = '';
    });
    try {
      final products = await ProductService.fetchProducts();
      setState(() {
        allProducts = products;
        isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        productLoadError = e.toString();
        isLoadingProducts = false;
      });
    }
  }

  void addToRecentlyViewed(ProductApiModel product) {
    setState(() {
      recentlyViewedProducts
          .removeWhere((item) => item.productId == product.productId);
      recentlyViewedProducts.insert(0, product);
      if (recentlyViewedProducts.length > 10) {
        recentlyViewedProducts.removeLast();
      }
    });
  }

  String formatPrice(String price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(double.parse(price))} đ';
  }

  List<ProductApiModel> filterProducts(List<ProductApiModel> products) {
    if (searchQuery.isNotEmpty) {
      products = products
          .where((product) => product.productName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppConstant.navy,
          ),
        ),
        iconTheme: IconThemeData(color: AppConstant.appTextColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 4.0), // Giảm padding lại cho gọn
          child: Image.asset(
            'assets/images/lala-logo.png',
            height: 48, // CHỈNH CHỖ NÀY: từ 100 xuống còn 48
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => Container(
                margin: EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => Get.to(() => CartScreen()),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.shopping_cart,
                          color: AppConstant.appTextColor,
                          size: 28,
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
                            color: Colors.red,
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
                ),
              )),
        ],
      ),
      drawer: DrawerWidget(),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: Get.height / 90.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  prefixIcon: Icon(Icons.search, color: AppConstant.navy),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppConstant.navy),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            if (isLoadingProducts)
              SizedBox(
                height: Get.height / 5,
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (productLoadError.isNotEmpty)
              Center(child: Text(productLoadError))
            else if (searchQuery.isNotEmpty)
              Builder(
                builder: (context) {
                  final filteredProducts = filterProducts(allProducts);
                  if (filteredProducts.isEmpty) {
                    return const Center(
                        child: Text('Không tìm thấy sản phẩm!'));
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(9.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final productModel = filteredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          addToRecentlyViewed(productModel);
                          // Get.to(() =>
                          //     ProductDetailsScreen(productModel: productModel));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: FillImageCard(
                            borderRadius: 10.0,
                            width: double.infinity,
                            heightImage: Get.height / 5,
                            imageProvider: CachedNetworkImageProvider(
                              '$BASE_URL/${productModel.img}',
                            ),
                            title: Center(
                              child: Text(
                                productModel.productName,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            footer: Center(
                              child: Text(
                                formatPrice(
                                    productModel.priceOutput.toString()),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            else
              Column(
                children: [
                  BannerWidget(),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 9, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPromoIcon(
                          icon: Icons.verified,
                          text: 'Chính hãng\n100%',
                          color: Colors.blue,
                        ),
                        _buildPromoIcon(
                          icon: Icons.local_shipping,
                          text: 'Miễn phí\nvận chuyển',
                          color: Colors.green,
                        ),
                        _buildPromoIcon(
                          icon: Icons.timer,
                          text: 'Giao hàng\nnhanh',
                          color: Colors.orange,
                        ),
                        _buildPromoIcon(
                          icon: Icons.security,
                          text: 'Bảo hành\nchất lượng',
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        HeadingWidget(
                          headingTitle: "Phân loại",
                          headingSubTitle: "Danh mục nổi bật",
                          onTap: () => Get.to(() => AllCategoriesScreen()),
                          buttonText: "Xem thêm >",
                        ),
                        CategoriesWidget(),
                      ],
                    ),
                  ),
                  // AnimatedContainer(
                  //   duration: Duration(milliseconds: 500),
                  //   curve: Curves.easeInOut,
                  //   margin: EdgeInsets.symmetric(horizontal: 9),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(16),
                  //     color: Colors.white,
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       HeadingWidget(
                  //         headingTitle: "Thương hiệu",
                  //         headingSubTitle: "Các thương hiệu nước hoa tiêu biểu",
                  //         onTap: () => Get.to(() => AllBrandsScreen()),
                  //         buttonText: "Xem thêm >",
                  //       ),
                  //       const BrandWidget(),
                  //     ],
                  //   ),
                  // ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.symmetric(horizontal: 9),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppConstant.navy.withValues(alpha: 1.0),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        HeadingWidget(
                          headingTitle: "Flash Sale",
                          headingSubTitle: "Sale sốc - Ưu đãi hàng ngày",
                          onTap: () =>
                              Get.to(() => AllFlashSaleProductScreen()),
                          buttonText: "Xem thêm >",
                        ),
                        FlashSaleWidget(),
                      ],
                    ),
                  ),
                  SizedBox(height: Get.height / 40),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          HeadingWidget(
                            headingTitle: "Tất cả sản phẩm",
                            headingSubTitle: "Đa dạng các nhãn hàng nước hoa",
                            onTap: () => Get.to(() => AllProductsScreen()),
                            buttonText: "Xem thêm >",
                          ),
                          AllProductsWidget(
                            addToRecentlyViewed: addToRecentlyViewed,
                            products: allProducts,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: Get.height / 40),
                  if (recentlyViewedProducts.isNotEmpty)
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(horizontal: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            HeadingWidget(
                              headingTitle: "Sản phẩm đã xem gần đây",
                              headingSubTitle: "Các sản phẩm bạn đã xem",
                              onTap: () {},
                              buttonText: "Xem thêm >",
                            ),
                            RecentProductsWidget(
                                recentlyViewedProducts: recentlyViewedProducts),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
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
                    _controller?.forward(from: 0);
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
                    _controller?.forward(from: 0);
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
                    _controller?.forward(from: 0);
                    Get.to(() => SettingsScreen());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          // Mở màn hình Chat AI
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AiChatScreen()),
          );
          // Nếu dùng GetX:
          // Get.to(() => const AiChatScreen());
        },
        child: const Icon(Icons.smart_toy),
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
                color: isSelected ? AppConstant.navy : Colors.transparent),
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

  Widget _buildPromoIcon({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color, width: 1),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        SizedBox(height: 6),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

class AllProductsWidget extends StatelessWidget {
  final Function(ProductApiModel) addToRecentlyViewed;
  final List<ProductApiModel> products;

  const AllProductsWidget({
    super.key,
    required this.addToRecentlyViewed,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat('#,###', 'vi_VN');

    final displayProducts = products.take(4).toList();

    if (displayProducts.isEmpty) {
      return const Center(child: Text('Không có sản phẩm nào.'));
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayProducts.length,
        itemBuilder: (context, index) {
          final product = displayProducts[index];
          return GestureDetector(
            // ...existing code...
            onTap: () {
              final productModel = convertApiToProductModel(product);
              Get.to(() => ProductDetailsScreen(
                    productModel: productModel,
                    allProducts: products, // <-- thêm dòng này!
                  ));
            },
            // ...existing code...
            child: Container(
              width: 150,
              margin: const EdgeInsets.all(8),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image(
                        image: CachedNetworkImageProvider(
                            '$BASE_URL/${product.img}'),
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              product.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${currencyFormat.format(product.priceOutput)} đ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecentProductsWidget extends StatelessWidget {
  final List<ProductApiModel> recentlyViewedProducts;

  const RecentProductsWidget({super.key, required this.recentlyViewedProducts});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentlyViewedProducts.length,
        itemBuilder: (context, index) {
          final product = recentlyViewedProducts[index];
          return GestureDetector(
            onTap: () {
              final mainScreenState =
                  context.findAncestorStateOfType<_MainScreenState>();
              mainScreenState?.addToRecentlyViewed(product);
              // Get.to(() => ProductDetailsScreen(productModel: product));
            },
            child: Container(
              width: 150,
              margin: EdgeInsets.all(8),
              child: Card(
                // Thêm border radius cho toàn bộ card nếu muốn
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Chỉ bo góc trên của hình ảnh
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image(
                        image: CachedNetworkImageProvider(
                            '$BASE_URL/${product.img}'),
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            product.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                                .format(product.priceOutput),
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
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
