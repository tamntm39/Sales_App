class ProductApiModel {
  final int productId;
  final String productName;
  final String description;
  final int priceOutput;
  final bool isActive;
  final int quantity;
  final int categoryId;
  final String img;
  final String? img2;
  final String? img3;
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
    this.img2,
    this.img3,
  });

  
  static String? normalize(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    if (str.isEmpty) return null;
    return str.replaceAll('\\', '/');
  }

  factory ProductApiModel.fromApi(Map<String, dynamic> json) {
    return ProductApiModel(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      priceOutput: json['priceOutput'] ?? 0,
      isActive: json['isActive'] ?? false,
      quantity: json['quantity'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      img: normalize(json['img']) ?? '',
      img2: normalize(json['img2']),
      img3: normalize(json['img3']),
      categoryName: json['categoryName'] ?? '',
    );
  }
}
