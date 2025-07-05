import 'package:chichanka_perfume/controllers/cart-price-controller.dart';
import 'package:chichanka_perfume/models/order_api_model.dart';
import 'package:chichanka_perfume/services/order_service.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'order-detail-screen.dart';

class OrderGroup {
  final int orderId;
  final DateTime orderDate;
  final double totalAmount;
  final int state;
  final List<OrderApiModel> items;

  OrderGroup({
    required this.orderId,
    required this.orderDate,
    required this.totalAmount,
    required this.state,
    required this.items,
  });
}

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  final ProductPriceController productPriceController =
      Get.put(ProductPriceController());
  dynamic _filterStatus = 'all';
  late Future<List<OrderApiModel>> _ordersFuture;
  int? customerId;

  @override
  void initState() {
    super.initState();
    _loadCustomerIdAndOrders();
  }

  Future<void> _loadCustomerIdAndOrders() async {
    final prefs = await SharedPreferences.getInstance();
    customerId = prefs.getInt('customerId');
    setState(() {
      _ordersFuture = OrderService().getOrdersByCustomerId(customerId ?? 0);
    });
  }

  Future<void> _refreshOrders() async {
    await _loadCustomerIdAndOrders();
    Get.snackbar('Thành công', 'Danh sách đơn hàng đã được làm mới');
  }

  List<OrderGroup> groupOrders(List<OrderApiModel> orders) {
    final Map<int, List<OrderApiModel>> grouped = {};
    for (var order in orders) {
      grouped.putIfAbsent(order.orderId, () => []).add(order);
    }
    return grouped.entries.map((entry) {
      final first = entry.value.first;
      return OrderGroup(
        orderId: first.orderId,
        orderDate: first.orderDate,
        totalAmount: first.totalAmount,
        state: first.state,
        items: entry.value,
      );
    }).toList();
  }

  List<OrderGroup> _filterOrderGroups(List<OrderGroup> groups) {
    if (_filterStatus == 'all') return groups;
    if (_filterStatus == 4) {
      return groups.where((group) => group.state > 3).toList();
    }
    return groups.where((group) => group.state == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: FutureBuilder<List<OrderApiModel>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingWidget();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorWidget("Đã xảy ra lỗi");
                  }
                  final orders = snapshot.data ?? [];
                  final groupedOrders = groupOrders(orders);
                  final filteredGroups = _filterOrderGroups(groupedOrders);
                  if (filteredGroups.isEmpty) {
                    return _buildEmptyWidget(
                        message: "Không có đơn hàng phù hợp!");
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, index) {
                      final orderGroup = filteredGroups[index];
                      return _buildOrderGroupCard(orderGroup);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstant.navy,
      elevation: 0,
      title: const Text(
        "Tất cả đơn hàng",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshOrders,
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {'label': 'Tất cả', 'value': 'all'},
      {'label': 'Chưa duyệt', 'value': 0},
      {'label': 'Đã duyệt', 'value': 1},
      {'label': 'Đang giao', 'value': 2},
      {'label': 'Đã nhận', 'value': 3},
      {'label': 'Hủy', 'value': 4},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      color: Colors.grey[200],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _filterStatus == filter['value'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _filterStatus = filter['value'];
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppConstant.appMainColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppConstant.appMainColor),
                ),
                child: Text(
                  filter['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppConstant.appMainColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CupertinoActivityIndicator(radius: 20),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 18, color: Colors.red),
      ),
    );
  }

  Widget _buildEmptyWidget({String message = "Bạn chưa có đơn hàng nào!"}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderGroupCard(OrderGroup group) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: group.orderId),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mã đơn: ${group.orderId}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppConstant.navy),
              ),
              Text(
                "Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(group.orderDate)}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ...group.items.map((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.shopping_bag,
                        color: AppConstant.appMainColor),
                    title: Text(item.productName),
                    subtitle: Text("Số lượng: ${item.productQuantity}"),
                    trailing: Text(formatter.format(item.priceOutput)),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tổng tiền:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatter.format(group.totalAmount),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstant.appMainColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildStatusChip(group.state),
              const SizedBox(height: 8),
              if (group.state == 0)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Xác nhận"),
                          content: const Text(
                              "Bạn có chắc muốn hủy đơn hàng này không?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Không"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Có"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final isCancelled =
                            await OrderService().cancelOrder(group.orderId);

                        if (isCancelled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Hủy đơn hàng thành công")),
                          );
                          _refreshOrders();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Hủy đơn hàng thất bại")),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      "Hủy đơn",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(int state) {
    String label;
    Color color;
    Color bgColor;

    switch (state) {
      case 0:
        label = "Chưa duyệt";
        color = Colors.orange;
        bgColor = Colors.orange.withOpacity(0.1);
        break;
      case 1:
        label = "Đã duyệt";
        color = Colors.blue;
        bgColor = Colors.blue.withOpacity(0.1);
        break;
      case 2:
        label = "Đang giao";
        color = Colors.purple;
        bgColor = Colors.purple.withOpacity(0.1);
        break;
      case 3:
        label = "Đã nhận";
        color = Colors.green;
        bgColor = Colors.green.withOpacity(0.1);
        break;
      default:
        label = "Hủy";
        color = Colors.red;
        bgColor = Colors.red.withOpacity(0.1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
