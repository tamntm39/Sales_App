class OrderApiModel {
  final int orderId;
  final DateTime orderDate;
  final double totalAmount;
  final int state;
  final int productId;
  final String productName;
  final int productQuantity;
  final double priceOutput;
  final String categoryName;

  OrderApiModel({
    required this.orderId,
    required this.orderDate,
    required this.totalAmount,
    required this.state,
    required this.productId,
    required this.productName,
    required this.productQuantity,
    required this.priceOutput,
    required this.categoryName,
  });

  factory OrderApiModel.fromMap(Map<String, dynamic> map) {
    return OrderApiModel(
      orderId: map['orderId'] ?? 0,
      orderDate: DateTime.parse(map['orderDate']),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0,
      state: map['state'] ?? 0,
      productId: map['productId'] ?? 0,
      productName: map['productName'] ?? '',
      productQuantity: map['quantity'] ?? 0,
      priceOutput: (map['priceOutput'] as num?)?.toDouble() ?? 0,
      categoryName: map['categoryName'] ?? '',
    );
  }
}
