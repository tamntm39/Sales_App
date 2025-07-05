import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/models/product-model.dart';
import 'package:chichanka_perfume/screens/user-panel/product-details-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chichanka_perfume/services/favorite_service.dart';
import '../../config.dart'; // Thêm dòng này phía trên cùng các import khác

class FavouriteProductScreen extends StatefulWidget {
  const FavouriteProductScreen({super.key});

  @override
  _FavouriteProductScreenState createState() => _FavouriteProductScreenState();
}

class _FavouriteProductScreenState extends State<FavouriteProductScreen> {
  String searchQuery = '';
  String sortBy = 'name_asc'; // Mặc định sắp xếp theo tên A-Z
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
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
        backgroundColor: AppConstant.navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppConstant.appTextColor),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Thanh tìm kiếm và bộ lọc
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm yêu thích...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        value: sortBy,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                              value: 'name_asc', child: Text('Tên: A-Z')),
                          DropdownMenuItem(
                              value: 'name_desc', child: Text('Tên: Z-A')),
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
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Danh sách sản phẩm yêu thích
                Expanded(
                  child: favoriteProducts.isEmpty
                      ? const Center(child: Text('Chưa có sản phẩm yêu thích'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(5.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.75,
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
                                  border:
                                      Border.all(color: Colors.grey, width: 1.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            '$BASE_URL/${product.productImages[0].replaceAll('\\', '/')}',
                                        fit: BoxFit.cover, // Ảnh sẽ lắp đầy khung
                                        width: double.infinity,
                                        height: Get.height / 5,
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        color: Colors.white.withOpacity(0.85),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 6),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              product.productName,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              product.isSale
                                                  ? formatPrice(product.salePrice)
                                                  : formatPrice(product.fullPrice),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          final prefs = await SharedPreferences.getInstance();
                                          final customerId = prefs.getInt('customerId');
                                          if (customerId != null) {
                                            await FavoriteService().removeFavorite(
                                              customerId,
                                              int.parse(product.productId),
                                            );
                                            loadFavorites();
                                          }
                                        },
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
// This code defines a Flutter screen for displaying a user's favorite products.