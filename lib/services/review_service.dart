import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_api_model.dart';
import '../config.dart';

class ReviewService {
  static Future<List<ReviewApiModel>> getReviewsByProductId(
      int productId) async {
    final url = Uri.parse('$BASE_URL/api/Review/GetReviewsByProductId/$productId');
    final response = await http.get(url);

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true && body['data'] is List) {
        print('Parse data: ${body['data']}');
        final reviews = (body['data'] as List)
            .map((e) => ReviewApiModel.fromJson(e))
            .toList();
        print('Số lượng review parse được: ${reviews.length}');
        return reviews;
      }
    }
    return [];
  }

  static Future<bool> createReview(ReviewApiModel review) async {
    final url = Uri.parse('$BASE_URL/api/Review/CreateReview');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "reviewId": 0,
        "customerId": review.customerId,
        "productId": review.productId,
        "comment": review.comment,
      }),
    );

    return response.statusCode == 200;
  }
}
