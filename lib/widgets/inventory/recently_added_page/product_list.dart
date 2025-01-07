import 'package:flutter/material.dart';
import 'package:inventory_app_final/model/product_user_model.dart';
import 'package:inventory_app_final/widgets/inventory/all_product_page/product_card.dart';

class ProductList extends StatelessWidget {
  final List<Productmodel> products;
  final void Function(Productmodel product, int index) onEdit;
  final void Function(int productId) onDelete;

  const ProductList({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          image: product.imagePath ?? 'default_image_path',
          name: product.productName ?? 'Default Product Name',
          stock: product.productQuantity ?? 0,
          price: product.productPrice,
          category: product.category,
          inStock: product.productQuantity > 0,
          description: product.description,
          onEdit: () => onEdit(product, index),
          onDelete: () => onDelete(product.id),
        );
      },
    );
  }
}
