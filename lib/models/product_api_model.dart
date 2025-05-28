class ProductApiModel {
  final int productId;
  final String productName;
  final String description;
  final int priceOutput;
  final bool isActive;
  final int quantity;
  final int categoryId;
  final String img;
  final String categoryName;

  ProductApiModel({
    required this.productId,
    required this.productName,
    required this.description,
    required this.priceOutput,
    required this.isActive,
    required this.quantity,
    required this.categoryId,
    required this.img,
    required this.categoryName,
  });

  factory ProductApiModel.fromApi(Map<String, dynamic> json) {
    return ProductApiModel(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      description: json['description'] ?? '',
      priceOutput: json['priceOutput'] ?? 0,
      isActive: json['isActive'] ?? false,
      quantity: json['quantity'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      img: json['img'] ?? '',
      categoryName: json['categoryName'] ?? '',
    );
  }
}
