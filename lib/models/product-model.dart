// ignore_for_file: file_names

class ProductModel {
  final String productId;
  final String categoryId;
  final String productName;
  final String categoryName;
  final String salePrice;
  final String fullPrice;
  final List<String> productImages;
  final String deliveryTime;
  final bool isSale;
  final String productDescription;
  final dynamic createdAt;
  final dynamic updatedAt;

  
   final String? img2;
  final String? img3;

  
  ProductModel({
    required this.productId,
    required this.categoryId,
    required this.productName,
    required this.categoryName,
    required this.salePrice,
    required this.fullPrice,
    required this.productImages,
    required this.deliveryTime,
    required this.isSale,
    required this.productDescription,
    required this.createdAt,
    required this.updatedAt,
     this.img2,
    this.img3,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'categoryId': categoryId,
      'productName': productName,
      'categoryName': categoryName,
      'salePrice': salePrice,
      'fullPrice': fullPrice,
      'productImages': productImages,
      'deliveryTime': deliveryTime,
      'isSale': isSale,
      'productDescription': productDescription,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'img2': img2,
      'img3': img3,

    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> json) {
 String normalizePath(dynamic p) {

    print("📥 JSON nhận từ backend: $json");


    if (p == null) return '';
    return p.toString().replaceAll(r'\', '/');
  }

  final rawImg  = normalizePath(json['img']);
  final rawImg2 = normalizePath(json['img2']);
  final rawImg3 = normalizePath(json['img3']);

  final images = <String>[];
  if (rawImg .isNotEmpty) images.add(rawImg);
  if (rawImg2.isNotEmpty) images.add(rawImg2);
  if (rawImg3.isNotEmpty) images.add(rawImg3);

  print("📦 Ảnh sau khi xử lý: $images");

  return ProductModel(
    productId: json['productId'].toString(),
    categoryId: json['categoryId'].toString(),
    productName: json['name'],
    categoryName: "",
    salePrice: json['priceOutput'].toString(),
    fullPrice: json['priceInput'].toString(),
     productImages:images, 
    deliveryTime: "",
    isSale: json['isSell'] ?? false,
    productDescription: json['description'] ?? '',
    createdAt: null,
    updatedAt: null,
     img2:rawImg2.isNotEmpty ? rawImg2 : null,
    img3:rawImg3.isNotEmpty ? rawImg3 : null,
  );
}
}