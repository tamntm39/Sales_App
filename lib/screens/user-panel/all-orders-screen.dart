import 'package:chichanka_perfume/controllers/cart-price-controller.dart';
import 'package:chichanka_perfume/models/order_api_model.dart';
import 'package:chichanka_perfume/services/order_service.dart';
import 'package:chichanka_perfume/utils/app-constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chichanka_perfume/config.dart';

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
  String _filterStatus = 'all'; // 'all', 'pending', 'delivered'
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
    return groups.where((group) {
      final delivered = group.state == 1;
      return _filterStatus == 'delivered' ? delivered : !delivered;
    }).toList();
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFilterButton("Tất cả", 'all'),
          _buildFilterButton("Đang chờ", 'pending'),
          _buildFilterButton("Đã giao", 'delivered'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String filterValue) {
    final isSelected = _filterStatus == filterValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = filterValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppConstant.appMainColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppConstant.appMainColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppConstant.appMainColor,
            fontWeight: FontWeight.w500,
          ),
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
    return Card(
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
                  leading:
                      Icon(Icons.shopping_bag, color: AppConstant.appMainColor),
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
            _buildStatusChip(group.state == 1),
            if (group.state == 1)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Gửi đánh giá cho đơn hàng này (nếu muốn)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstant.appMainColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    "Đánh giá",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool delivered) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: delivered
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        delivered ? "Đã giao" : "Đang chờ...",
        style: TextStyle(
          color: delivered ? Colors.green : Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
