import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/product_api_model.dart';
import '../../services/suggest-service.dart';
import 'product-details-screen.dart';
import 'package:chichanka_perfume/models/product-model.dart';
import 'package:chichanka_perfume/config.dart';

class SuggestionsScreen extends StatefulWidget {
  final int selectedCategory;

  const SuggestionsScreen({super.key, required this.selectedCategory});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  List<ProductApiModel> products = [];
  bool isLoading = true;
  String error = '';

  final currencyFormat = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    fetchSuggestions();
  }

  Future<void> fetchSuggestions() async {
    try {
      final fetchedProducts =
          await SuggestionProductService.fetchProductsByCategoryId(
              widget.selectedCategory);
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gợi ý sản phẩm',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 88, 209, 54),
      ),
      body: isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : products.isEmpty
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
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Get.to(() => ProductDetailsScreen(
                                    productModel:
                                        convertApiToProductModel(product),
                                  ));
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
    );
  }
}

ProductModel convertApiToProductModel(ProductApiModel apiModel) {
  String normalize(String? p) => p?.replaceAll(r'\', '/') ?? '';

  final rawImg = normalize(apiModel.img);
  final rawImg2 = normalize(apiModel.img2);
  final rawImg3 = normalize(apiModel.img3);

  // Gom list ảnh cho carousel
  final images = <String>[];
  if (rawImg.isNotEmpty) images.add(rawImg);
  if (rawImg2.isNotEmpty) images.add(rawImg2);
  if (rawImg3.isNotEmpty) images.add(rawImg3);
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
