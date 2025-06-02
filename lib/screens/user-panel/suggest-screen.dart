import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/models/product_api_model.dart';
import 'package:chichanka_perfume/screens/user-panel/product-details-screen.dart';
import 'package:chichanka_perfume/services/product_service.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config.dart';
import '../../models/product-model.dart';

class SuggestionsScreen extends StatefulWidget {
  final String? selectedCategory;

  const SuggestionsScreen({super.key, this.selectedCategory});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  List<ProductApiModel> products = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final fetchedProducts = await ProductService.fetchProducts();
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Lỗi khi tải sản phẩm: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    // Nếu muốn lọc theo selectedCategory, chỉ cần bỏ comment đoạn dưới:
    // final filteredProducts = widget.selectedCategory == null
    //     ? products
    //     : products.where((p) => p.categoryName == widget.selectedCategory).toList();

    final filteredProducts = products; // hiện toàn bộ sản phẩm

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gợi ý sản phẩm'),
        backgroundColor: const Color.fromARGB(255, 88, 209, 54),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : filteredProducts.isEmpty
                  ? const Center(child: Text('Không có sản phẩm nào.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () {
                              final productModel =
                                  convertApiToProductModel(product);
                              Get.to(() => ProductDetailsScreen(
                                  productModel: productModel));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: CachedNetworkImage(
                                      imageUrl: '$BASE_URL/${product.img}',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
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
                                            fontSize: 14),
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
    );
  }

  ProductModel convertApiToProductModel(ProductApiModel apiModel) {
    return ProductModel(
      productId: apiModel.productId.toString(),
      productName: apiModel.productName,
      productImages: [apiModel.img ?? ''],
      fullPrice: apiModel.priceOutput.toString(),
      salePrice: apiModel.priceOutput.toString(),
      isSale: false,
      categoryId: apiModel.categoryId?.toString() ?? '',
      categoryName: apiModel.categoryName?.toString() ?? '',
      productDescription: apiModel.description ?? '',
      deliveryTime: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
