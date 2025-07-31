import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantitySelectorWidget extends StatelessWidget {
  final int selectedQuantity;
  final int minQuantity;
  final int maxQuantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final Function(String) onQuantityChanged;
  final double totalPrice;
  final String Function(String) formatPrice;

  const QuantitySelectorWidget({
    super.key,
    required this.selectedQuantity,
    required this.minQuantity,
    required this.maxQuantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onQuantityChanged,
    required this.totalPrice,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Chọn số lượng:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),

          Row(
            children: [
              // Nút giảm số lượng
              _buildQuantityButton(
                icon: Icons.remove,
                isEnabled: selectedQuantity > minQuantity,
                onPressed: onDecrease,
              ),

              // Input số lượng với validation
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: selectedQuantity.toString()),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      hintText: "1-$maxQuantity",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: onQuantityChanged,
                    onFieldSubmitted: (value) {
                      if (value.isEmpty) {
                        onQuantityChanged("1");
                      }
                    },
                  ),
                ),
              ),

              // Nút tăng số lượng
              _buildQuantityButton(
                icon: Icons.add,
                isEnabled: selectedQuantity < maxQuantity,
                onPressed: onIncrease,
              ),
            ],
          ),

          SizedBox(height: 8),

          // Hiển thị giới hạn số lượng
          Text(
            "Có thể chọn từ $minQuantity đến $maxQuantity cây",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),

          SizedBox(height: 12),

          // Hiển thị tổng giá với animation
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tổng tiền:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                    fontSize: 16,
                  ),
                ),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: Text(
                    "${formatPrice(totalPrice.toString())} VNĐ",
                    key: ValueKey(selectedQuantity),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget nút tăng/giảm số lượng
  Widget _buildQuantityButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isEnabled
            ? Colors.green.shade600
            : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: Colors.green.shade300,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ] : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isEnabled ? onPressed : null,
          child: Container(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}