// ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/screens/user-panel/single-category-products-screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import '../models/category_api_model.dart';
import '../services/category_service.dart';
import '../config.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryApiModel>>(
      future: CategoryService.fetchCategories(),
      builder: (BuildContext context, AsyncSnapshot<List<CategoryApiModel>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Lỗi"),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: Get.height / 5,
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text("Không tìm thấy dữ liệu!"),
          );
        }

        final categories = snapshot.data!;
        return Container(
          height: Get.height / 5.0,
          child: ListView.builder(
            itemCount: categories.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.to(() => AllSingleCategoryProductsScreen(
                        categoryId: category.categoryId)),
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Container(
                        child: FillImageCard(
                          borderRadius: 10.0,
                          width: Get.width / 3.0,
                          heightImage: Get.height / 10,
                          imageProvider: CachedNetworkImageProvider(
                            '$BASE_URL/${category.image}',
                          ),
                          title: Center(
                            child: Text(
                              category.name,
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
