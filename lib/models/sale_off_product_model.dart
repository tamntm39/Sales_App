// models/sale_off_product_model.dart

class SaleOffProduct {
  final int productId;
  final String name;
  final double priceOutput;
  final double saleOff;
  final double finalPrice;
  final String img;

  SaleOffProduct({
    required this.productId,
    required this.name,
    required this.priceOutput,
    required this.saleOff,
    required this.finalPrice,
    required this.img,
  });

  factory SaleOffProduct.fromJson(Map<String, dynamic> json) {
    return SaleOffProduct(
      productId: json['productId'],
      name: json['name'],
      priceOutput: (json['priceOutput'] as num).toDouble(),
      saleOff: (json['saleOff'] as num).toDouble(),
      finalPrice: (json['finalPrice'] as num).toDouble(),
      img: json['img'],
    );
  }
}
