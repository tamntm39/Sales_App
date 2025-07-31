import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/category_api_model.dart';
import '../../models/product_api_model.dart';
import '../../services/category_service.dart';
import '../../services/suggest-service.dart';
import 'suggest-screen.dart';

class PersonalizedSuggestionsScreen extends StatefulWidget {
  const PersonalizedSuggestionsScreen({super.key});

  @override
  State<PersonalizedSuggestionsScreen> createState() =>
      _PersonalizedSuggestionsScreenState();
}

class _PersonalizedSuggestionsScreenState
    extends State<PersonalizedSuggestionsScreen> {
  List<CategoryApiModel> categories = [];
  Map<int, ProductApiModel?> productsByCategory = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSuggestions();
  }

  Future<void> fetchSuggestions() async {
    try {
      final fetchedCategories = await CategoryService.fetchCategories();
      final Map<int, ProductApiModel?> productMap = {};

      for (final category in fetchedCategories) {
        final products =
            await SuggestionProductService.fetchProductsByCategoryId(
                category.categoryId);
        productMap[category.categoryId] =
            products.isNotEmpty ? products.first : null;
      }

      setState(() {
        categories = fetchedCategories;
        productsByCategory = productMap;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
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
        backgroundColor:  Colors.green.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      category.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: const Text('Gợi ý theo sở thích của bạn'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Get.to(() => SuggestionsScreen(
                          selectedCategory: category.categoryId));
                    },
                  ),
                );
              },
            ),
    );
  }
}
