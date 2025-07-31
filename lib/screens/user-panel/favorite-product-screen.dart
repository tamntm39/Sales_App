import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/models/product-model.dart';
import 'package:chichanka_perfume/screens/user-panel/product-details-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chichanka_perfume/services/favorite_service.dart';
import '../../config.dart';

class FavouriteProductScreen extends StatefulWidget {
  const FavouriteProductScreen({super.key});

  @override
  _FavouriteProductScreenState createState() => _FavouriteProductScreenState();
}

class _FavouriteProductScreenState extends State<FavouriteProductScreen> {
  String searchQuery = '';
  String sortBy = 'name_asc';
  List<ProductModel> favoriteProducts = [];
  bool isLoading = true;

  // Hàm định dạng tiền tệ
  String formatPrice(String price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(double.parse(price))} đ';
  }

  Future<void> loadFavorites() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt('customerId');
    if (customerId != null) {
      final data = await FavoriteService().getFavorites(customerId);
      setState(() {
        favoriteProducts = data.map<ProductModel>((e) => ProductModel(
          productId: e['productId'].toString(),
          productName: e['productName'] ?? '',
          productImages: [e['img'] ?? ''],
          fullPrice: e['priceOutput'].toString(),
          salePrice: e['priceOutput'].toString(),
          isSale: false,
          categoryId: '',
          categoryName: '',
          productDescription: '',
          deliveryTime: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        favoriteProducts = [];
        isLoading = false;
      });
    }
  }

  // Lọc và sắp xếp
  List<ProductModel> filterAndSortProducts(List<ProductModel> products) {
    var filtered = products;
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
        filtered.sort((a, b) =>
            double.parse(a.fullPrice).compareTo(double.parse(b.fullPrice)));
        break;
      case 'price_desc':
        filtered.sort((a, b) =>
            double.parse(b.fullPrice).compareTo(double.parse(a.fullPrice)));
        break;
    }
    return filtered;
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Sản phẩm yêu thích',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Container cho tìm kiếm và dropdown
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Thanh tìm kiếm
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm sản phẩm yêu thích...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // Dropdown sắp xếp
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: sortBy,
                    isExpanded: true,
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(
                        value: 'name_asc',
                        child: Text('Tên: A-Z'),
                      ),
                      DropdownMenuItem(
                        value: 'name_desc',
                        child: Text('Tên: Z-A'),
                      ),
                      DropdownMenuItem(
                        value: 'price_asc',
                        child: Text('Giá: Thấp đến Cao'),
                      ),
                      DropdownMenuItem(
                        value: 'price_desc',
                        child: Text('Giá: Cao đến Thấp'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        sortBy = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Danh sách sản phẩm
          Expanded(
            child: favoriteProducts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có sản phẩm yêu thích',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount:
              filterAndSortProducts(favoriteProducts).length,
              itemBuilder: (context, index) {
                final product =
                filterAndSortProducts(favoriteProducts)[index];

                return GestureDetector(
                  onTap: () => Get.to(() =>
                      ProductDetailsScreen(productModel: product)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFF8), // Màu trắng kem nhẹ
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // Container cho hình ảnh
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                    '$BASE_URL/${product.productImages[0].replaceAll('\\', '/')}',
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                            size: 50,
                                          ),
                                        ),
                                    placeholder: (context, url) =>
                                        Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            // Container cho thông tin sản phẩm
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.isSale
                                          ? formatPrice(product.salePrice)
                                          : formatPrice(product.fullPrice),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Nút xóa yêu thích
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () async {
                                // Hiển thị dialog xác nhận
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Xác nhận'),
                                      content: const Text(
                                        'Bạn có muốn xóa sản phẩm này khỏi danh sách yêu thích?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text(
                                            'Xóa',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (shouldDelete == true) {
                                  final prefs = await SharedPreferences.getInstance();
                                  final customerId = prefs.getInt('customerId');
                                  if (customerId != null) {
                                    await FavoriteService().removeFavorite(
                                      customerId,
                                      int.parse(product.productId),
                                    );
                                    loadFavorites();
                                    // Hiển thị snackbar thông báo
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã xóa khỏi danh sách yêu thích'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}