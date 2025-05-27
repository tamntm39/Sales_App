class CategoryApiModel {
  final int categoryId;
  final String name;
  final String slug;
  final String image;
  final bool isActive;
  final String createOn;
  final int totalProduct;

  CategoryApiModel({
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.image,
    required this.isActive,
    required this.createOn,
    required this.totalProduct,
  });

  factory CategoryApiModel.fromJson(Map<String, dynamic> json) {
    return CategoryApiModel(
      categoryId: json['categoryId'],
      name: json['name'],
      slug: json['slug'],
      image: json['image'],
      isActive: json['isActive'],
      createOn: json['createOn'],
      totalProduct: json['totalProduct'],
    );
  }
}
