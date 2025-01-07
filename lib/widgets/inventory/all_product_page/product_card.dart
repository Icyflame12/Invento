import 'package:flutter/material.dart';
import 'package:inventory_app_final/widgets/inventory/inventory_screen/product_card_details.dart';
import 'package:inventory_app_final/widgets/inventory/inventory_screen/product_card_image.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String name;
  final int stock;
  final double price;
  final String category;
  final String description;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.stock,
    required this.price,
    required this.category,
    required this.description,
    required this.onEdit,
    required this.onDelete,
    required bool inStock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.3),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductCardImage(image: image),
              const SizedBox(height: 16),
              ProductCardDetails(
                name: name,
                category: category,
                description: description,
                stock: stock,
                price: price,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
