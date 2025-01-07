import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inventory_app_final/model/product_user_model.dart';

class ProductGrid extends StatelessWidget {
  final List<Productmodel> products;
  final Set<Productmodel> selectedProducts;
  final Function(Productmodel) toggleProductSelection;

  const ProductGrid({
    required this.products,
    required this.selectedProducts,
    required this.toggleProductSelection,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isSelected = selectedProducts.contains(product);
        return ProductCard(
          product: product,
          isSelected: isSelected,
          toggleProductSelection: toggleProductSelection,
        );
      },
    );
  }
}

class ProductCard extends StatefulWidget {
  final Productmodel product;
  final bool isSelected;
  final Function(Productmodel) toggleProductSelection;

  const ProductCard({
    required this.product,
    required this.isSelected,
    required this.toggleProductSelection,
    super.key,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.product.productQuantity > 0
          ? () => setState(() {
                widget.toggleProductSelection(widget.product);
              })
          : null,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.file(
                File(widget.product.imagePath),
                height: 140, // Reduced image height
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.product.productName ?? 'Unknown Product',
                      style: const TextStyle(
                        fontSize: 14, // Reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    widget.isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: widget.isSelected ? Colors.blue : Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Category: ${widget.product.category}',
                style: const TextStyle(fontSize: 12), // Reduced font size
              ),
              Text(
                'Price: \$${widget.product.productPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12), // Reduced font size
              ),
              if (widget.product.productQuantity ==
                  0) // Assuming stock is an integer field
                const Text(
                  'Out of Stock',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Reduced font size
                  ),
                )
              else
                Text(
                  'Quantity: ${widget.product.productQuantity}',
                  style: const TextStyle(fontSize: 12), // Reduced font size
                ),
            ],
          ),
        ),
      ),
    );
  }
}
