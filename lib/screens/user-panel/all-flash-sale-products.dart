import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/screens/user-panel/product-details-screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/sale_off_product_model.dart'; // Model riêng cho sản phẩm sale
import '../../utils/app-constant.dart';
import 'package:chichanka_perfume/models/product-model.dart';
import '../../config.dart';

String getImageUrl(String img) {
  // Đổi dấu \ thành /
  String path = img.replaceAll('\\', '/');
  // Nối domain và port backend vào đường dẫn
  return '$BASE_URL/$path'; // Đổi IP cho đúng backend của bạn
}

// Hàm chuyển SaleOffProduct (object) sang ProductModel
ProductModel convertToProductModel(SaleOffProduct saleProduct) {
  return ProductModel(
    productId: saleProduct.productId.toString(),
    categoryId: '',
    productName: saleProduct.name,
    categoryName: '',
    salePrice: saleProduct.finalPrice.toString(),
    fullPrice: saleProduct.priceOutput.toString(),
    productImages: [saleProduct.img],
    deliveryTime: '',
    isSale: true,
    productDescription: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

// Hàm định dạng tiền tệ với dấu chấm và ký hiệu đ
String formatPrice(num price) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(price)} đ';
}

// Hàm lấy dữ liệu từ API
Future<List<SaleOffProduct>> fetchSaleOffProducts() async {
  final response =
      await http.get(Uri.parse('$BASE_URL/api/Product/GetSaleOffProducts'));
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    if (jsonData['success'] == true && jsonData['data'] != null) {
      return (jsonData['data'] as List)
          .map((item) => SaleOffProduct.fromJson(item))
          .toList();
    } else {
      throw Exception('API trả về lỗi: ${jsonData['message']}');
    }
  } else {
    throw Exception('Không kết nối được API');
  }
}

class AllFlashSaleProductScreen extends StatelessWidget {
  const AllFlashSaleProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.navy,
        iconTheme: IconThemeData(color: AppConstant.appTextColor),
        title: Text(
          'Flash Sale - Khuyến Mãi',
          style: TextStyle(color: AppConstant.appTextColor),
        ),
      ),
      body: FutureBuilder<List<SaleOffProduct>>(
        future: fetchSaleOffProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Có lỗi xảy ra'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: Get.height / 5,
              child: const Center(child: CupertinoActivityIndicator()),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Không tìm thấy sản phẩm khuyến mãi!'));
          }
          final products = snapshot.data!;
          return GridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.61,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              double discountPercent = product.priceOutput == 0
                  ? 0
                  : ((product.priceOutput - product.finalPrice) /
                          product.priceOutput) *
                      100;
              return GestureDetector(
                onTap: () => Get.to(() => ProductDetailsScreen(
                      productModel: convertToProductModel(
                          product), // product là item từ API
                    )),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image section
                          Expanded(
                            child: FillImageCard(
                              borderRadius: 10.0,
                              width: double.infinity,
                              heightImage: Get.height * 0.21,
                              imageProvider: CachedNetworkImageProvider(
                                  getImageUrl(product.img)),
                            ),
                          ),
                          // Text section
                          Container(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 5.5, left: 8.0, right: 8.0),
                            color: Colors.white,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  product.name,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  formatPrice(product.priceOutput),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  formatPrice(product.finalPrice),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Discount badge
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${discountPercent.round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Giả định ProductModel có phương thức fromMap
extension ProductModelExtension on ProductModel {
  static ProductModel fromMap(Map<String, dynamic> data) {
    return ProductModel(
      productId: data['productId'],
      categoryId: data['categoryId'],
      productName: data['productName'],
      categoryName: data['categoryName'],
      salePrice: data['salePrice'],
      fullPrice: data['fullPrice'],
      productImages: List<String>.from(data['productImages']),
      deliveryTime: data['deliveryTime'],
      isSale: data['isSale'],
      productDescription: data['productDescription'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }
}
