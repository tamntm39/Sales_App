import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/screens/user-panel/main-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/product-details-screen.dart';
import 'package:chichanka_perfume/screens/user-panel/settings-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chichanka_perfume/models/product_api_model.dart';
import 'package:chichanka_perfume/services/product_service.dart';
import '../../config.dart';
import 'package:chichanka_perfume/models/product-model.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  List<ProductApiModel> products = [];
  bool isLoading = true;
  String error = '';

  String searchQuery = '';
  String sortBy = 'name_asc';
  int _selectedIndex = 0;
  int _currentPage = 1;
  final int _itemsPerPage = 6;
   final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  double? _activeMinPriceFilter; 
  double? _activeMaxPriceFilter; 

  String formatPrice(num price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(price)} đ';
  }

  List<ProductApiModel> filterAndSortProducts(List<ProductApiModel> docs) {
    List<ProductApiModel> filtered = docs;
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((product) => product.productName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }
    switch (sortBy) {
      case 'name_asc':
        filtered.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case 'name_desc':
        filtered.sort((a, b) => b.productName.compareTo(a.productName));
        break;
      case 'price_asc':
        filtered.sort((a, b) => a.priceOutput.compareTo(b.priceOutput));
        break;
      case 'price_desc':
        filtered.sort((a, b) => b.priceOutput.compareTo(a.priceOutput));
        break;
    }
    return filtered;
  }

  List<ProductApiModel> getPaginatedProducts(List<ProductApiModel> products) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return products.sublist(
      startIndex,
      endIndex > products.length ? products.length : endIndex,
    );
  }

  int get totalPages {
    final filtered = filterAndSortProducts(products);
    return (filtered.length / _itemsPerPage)
        .ceil()
        .clamp(1, double.infinity)
        .toInt();
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }
   @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }
  Future<void> fetchProductsByPrice(double? minPrice, double? maxPrice) async {
  try {
    final allProducts = await ProductService.fetchProducts();
    setState(() {
      products = allProducts.where((product) {
        final price = product.priceOutput;
        final matchMin = minPrice == null || price >= minPrice;
        final matchMax = maxPrice == null || price <= maxPrice;
        return matchMin && matchMax;
      }).toList();
      _currentPage = 1;
    });
  } catch (e) {
    setState(() {
      error = 'Lỗi khi lọc sản phẩm theo giá: $e';
    });
  }
}


  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    try {
      final fetchedProducts = await ProductService.fetchProducts();
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');
    final filteredSorted = filterAndSortProducts(products);
    final paginated = getPaginatedProducts(filteredSorted);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.navy,
        iconTheme: IconThemeData(color: AppConstant.appTextColor),
        title: Text(
          'Tất cả sản phẩm',
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : products.isEmpty
                  ? const Center(child: Text('Không có sản phẩm nào.'))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm sản phẩm...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                    _currentPage = 1;
                                  });
                                },
                              ),
                              Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _minPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Giá từ',
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    border: OutlineInputBorder(),
                                    isDense: true, // Làm nhỏ lại
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _maxPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Đến',
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    border: OutlineInputBorder(),
                                    isDense: true, // Làm nhỏ lại
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  double? min = double.tryParse(_minPriceController.text);
                                  double? max = double.tryParse(_maxPriceController.text);
                                  await fetchProductsByPrice(min, max);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                                child: Text('Lọc'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                              const SizedBox(height: 10),
                              DropdownButton<String>(
                                value: sortBy,
                                isExpanded: true,
                                items: [
                                  DropdownMenuItem(
                                      value: 'name_asc',
                                      child: Text('Tên: A-Z')),
                                  DropdownMenuItem(
                                      value: 'name_desc',
                                      child: Text('Tên: Z-A')),
                                  DropdownMenuItem(
                                      value: 'price_asc',
                                      child: Text('Giá: Thấp đến Cao')),
                                  DropdownMenuItem(
                                      value: 'price_desc',
                                      child: Text('Giá: Cao đến Thấp')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    sortBy = value!;
                                    _currentPage = 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: paginated.length,
                            itemBuilder: (context, index) {
                              final product = paginated[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  // ...existing code...
                                  onTap: () {
                                    final productModel =
                                        convertApiToProductModel(product);
                                    Get.to(() => ProductDetailsScreen(
                                          productModel: productModel,
                                          productApiModel: product,
                                          allProducts:
                                              products, // <-- truyền danh sách này
                                        ));
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '$BASE_URL/${product.img}',
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
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
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${currencyFormat.format(product.priceOutput)} đ',
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_left),
                                onPressed: _currentPage > 1
                                    ? () {
                                        setState(() {
                                          _currentPage--;
                                        });
                                      }
                                    : null,
                              ),
                              Text(
                                'Trang $_currentPage / $totalPages',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_right),
                                onPressed: _currentPage < totalPages
                                    ? () {
                                        setState(() {
                                          _currentPage++;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
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
                    Get.to(() => SettingsScreen());
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

ProductModel convertApiToProductModel(ProductApiModel apiModel) {
  return ProductModel(
    productId: apiModel.productId.toString(), // ép kiểu về String
    productName: apiModel.productName,
    productImages: [apiModel.img ?? ''],
    fullPrice: apiModel.priceOutput.toString(),
    salePrice: apiModel.priceOutput.toString(),
    isSale: false,
    categoryId: apiModel.categoryId.toString() ?? '',
    categoryName: apiModel.categoryName.toString() ?? '',
    productDescription: apiModel.description ?? '', // dùng đúng tên trường
    deliveryTime: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
