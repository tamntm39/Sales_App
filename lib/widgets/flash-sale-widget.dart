import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/models/product-model.dart';
import 'package:chichanka_perfume/models/sale_off_product_model.dart';
import 'package:chichanka_perfume/screens/user-panel/product-details-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

String getImageUrl(String img) {
  String path = img.replaceAll('\\', '/');
  return 'http://192.168.1.102:7072/$path'; // Đổi IP cho đúng backend của bạn
}

class FlashSaleWidget extends StatelessWidget {
  const FlashSaleWidget({super.key});

  Future<List<SaleOffProduct>> fetchFlashSaleProducts() async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.102:7072/api/Product/GetSaleOffProducts'), // Đổi IP theo backend của bạn
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true && jsonData['data'] != null) {
        return (jsonData['data'] as List)
            .take(4) // Lấy tối đa 4 sản phẩm cho flash sale trang chủ
            .map((item) => SaleOffProduct.fromJson(item))
            .toList();
      }
    }
    return [];
  }

  // Hàm chuyển SaleOffProduct sang ProductModel để không ảnh hưởng chức năng khác
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

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat('#,###', 'vi_VN');
    return FutureBuilder<List<SaleOffProduct>>(
      future: fetchFlashSaleProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Lỗi"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: Get.height / 5,
            child: const Center(child: CupertinoActivityIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không tìm thấy sản phẩm!"));
        }
        final products = snapshot.data!;
        return SizedBox(
          height: Get.height / 4.5,
          child: ListView.builder(
            itemCount: products.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            itemBuilder: (context, index) {
              final saleProduct = products[index];
              final productModel = convertToProductModel(saleProduct);
              return GestureDetector(
                onTap: () => Get.to(
                  () => ProductDetailsScreen(productModel: productModel),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Get.width / 4,
                    ),
                    child: FillImageCard(
                      borderRadius: 10.0,
                      width: Get.width / 4,
                      heightImage: Get.height / 9,
                      imageProvider: CachedNetworkImageProvider(
                        getImageUrl(productModel.productImages[0]),
                      ),
                      title: Center(
                        child: Text(
                          productModel.productName,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 10.0),
                        ),
                      ),
                      footer: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${currencyFormat.format(double.parse(productModel.fullPrice))} đ',
                              style: TextStyle(
                                fontSize: 10.0,
                                color: AppConstant.appScendoryColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              '${currencyFormat.format(double.parse(productModel.salePrice))} đ',
                              style: const TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: AppConstant.appMainColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
