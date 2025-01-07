import 'package:flutter/material.dart';

class ProductCardDetails extends StatelessWidget {
  final String name;
  final String category;
  final String description;
  final int stock;
  final double price;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCardDetails({
    super.key,
    required this.name,
    required this.category,
    required this.description,
    required this.stock,
    required this.price,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Category: $category',
          style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.6),
              fontStyle: FontStyle.italic),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDetail("Stock", stock.toString()),
            _buildDetail("Price", "\$${price.toStringAsFixed(2)}"),
            _buildDetail("Status", _getStockStatus(stock)),
          ],
        ),
      ],
    );
  }

  Widget _buildDetail(String label, String value) {
    Color backgroundColor;
    Color textColor;

    switch (label) {
      case "Stock":
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        break;
      case "Price":
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        break;
      case "Status":
        backgroundColor =
            value == "In Stock" ? Colors.teal.shade50 : Colors.red.shade50;
        textColor =
            value == "In Stock" ? Colors.teal.shade800 : Colors.red.shade800;
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.black;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
          ),
        ],
      ),
    );
  }

  String _getStockStatus(int stock) {
    if (stock == 0) {
      return "Out of Stock";
    } else if (stock < 10) {
      return "Low in Stock";
    } else {
      return "In Stock";
    }
  }
}
