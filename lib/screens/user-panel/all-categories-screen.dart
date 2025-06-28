// ignore_for_file: file_names, prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chichanka_perfume/screens/user-panel/single-category-products-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chichanka_perfume/models/category_api_model.dart';
import 'package:chichanka_perfume/services/category_service.dart';
import '../../config.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  List<CategoryApiModel> categories = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    try {
      final fetchedCategories = await CategoryService.fetchCategories();
      setState(() {
        categories = fetchedCategories;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.navy,
        iconTheme: IconThemeData(color: AppConstant.appTextColor),
        title: Text(
          'Tất cả danh mục',
          style: TextStyle(color: AppConstant.appTextColor),
        ),
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : categories.isEmpty
                  ? const Center(child: Text('Không có danh mục nào.'))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Get.to(() => AllSingleCategoryProductsScreen(
                              categoryId: category.categoryId,));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: AppConstant.navy.withOpacity(0.08),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 18, bottom: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppConstant.navy.withOpacity(0.10),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: '$BASE_URL/${category.image}',
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(child: CupertinoActivityIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error, size: 40, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    category.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Sản phẩm: ${category.totalProduct}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppConstant.navy.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
