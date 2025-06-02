import 'package:chichanka_perfume/screens/user-panel/suggest-screen.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersonalizedSuggestionsScreen extends StatelessWidget {
  final List<String> suggestions;

  const PersonalizedSuggestionsScreen({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gợi ý cây cảnh',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 88, 209, 54),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                'Chủ đề: ${suggestions[index]}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Phù hợp với sở thích của bạn'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.to(() => SuggestionsScreen(selectedCategory: suggestions[index]));
              },
            ),
          );
        },
      ),
    );
  }
}
