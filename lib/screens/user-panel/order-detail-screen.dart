import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/order_service.dart';
import '../../models/order_detail_product_model.dart';
import '../../config.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<Map<String, dynamic>> _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailsFuture = OrderService().getOrderDetails(widget.orderId);
  }

  String _getOrderStatusText(dynamic stateId) {
    switch (stateId) {
      case 0:
        return 'Chưa duyệt';
      case 1:
        return 'Đã duyệt';
      case 2:
        return 'Đang giao';
      case 3:
        return 'Đã nhận';
      case 4:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Có'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final isCancelled = await OrderService().cancelOrder(widget.orderId);
      if (isCancelled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hủy đơn hàng thành công')),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hủy đơn hàng thất bại')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _orderDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final data = snapshot.data ?? {};
          if (data.isEmpty) {
            return const Center(child: Text('Không có chi tiết đơn hàng'));
          }

          final customerName = data['nameCustomer'] ?? '';
          final address = data['address'] ?? '';
          final stateId = data['stateId'];
          final detailProductsRaw = data['detailProducts'];
          final List<OrderDetailProductModel> detailProducts =
              (detailProductsRaw is List)
                  ? detailProductsRaw
                      .map((e) => OrderDetailProductModel.fromMap(e))
                      .toList()
                  : [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Khách hàng: $customerName',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Địa chỉ: $address'),
                const SizedBox(height: 4),
                Text('Trạng thái: ${_getOrderStatusText(stateId)}'),
                const Divider(height: 24),
                const Text('Sản phẩm:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: detailProducts.isEmpty
                      ? const Text('Không có sản phẩm nào trong đơn hàng này.')
                      : ListView.separated(
                          itemCount: detailProducts.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = detailProducts[index];
                            return ListTile(
                              leading: item.img.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            '$BASE_URL/${item.img.replaceAll("\\", "/")}',
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: Colors.green.shade50,
                                          child: const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.broken_image,
                                                color: Colors.grey),
                                      ),
                                    )
                                  : const Icon(Icons.shopping_bag),
                              title: Text(item.name),
                              subtitle: Text('Số lượng: ${item.quantity}'),
                              trailing: Text('${item.price}₫'),
                            );
                          },
                        ),
                ),
                if (stateId == 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _cancelOrder,
                        child: const Text('Hủy đơn hàng',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
