class OrderDetailProductModel {
  final String name;
  final int quantity;
  final int price;
  final String img;

  OrderDetailProductModel({
    required this.name,
    required this.quantity,
    required this.price,
    required this.img,
  });

  factory OrderDetailProductModel.fromMap(Map<String, dynamic> map) {
    return OrderDetailProductModel(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: map['price'] ?? 0,
      img: map['img'] ?? '',
    );
  }
}
