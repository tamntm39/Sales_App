class ReviewApiModel {
  final int reviewId;
  final int customerId;
  final int productId;
  final String comment;
  final String fullName;

  ReviewApiModel({
    required this.reviewId,
    required this.customerId,
    required this.productId,
    required this.comment,
    required this.fullName,
  });

  factory ReviewApiModel.fromJson(Map<String, dynamic> json) {
    return ReviewApiModel(
      reviewId: json['reviewId'] ?? 0,
      customerId: json['customerId'] ?? 0,
      productId: json['productId'] ?? 0,
      comment: json['comment'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }
}