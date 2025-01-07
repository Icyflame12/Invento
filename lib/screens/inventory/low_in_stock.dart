import 'package:flutter/material.dart';
import 'package:inventory_app_final/screens/inventory/Editproduct.dart';
import 'package:inventory_app_final/widgets/inventory/all_product_page/product_card.dart';
import '../../model/dbfunctions.dart';
import '../../model/product_user_model.dart';

class LowInStockPage extends StatelessWidget {
  const LowInStockPage({super.key});

  Future<void> _navigateToEditProduct(
      BuildContext context, Productmodel product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProductScreen(
          product: product,
          productId: product.id,
          onProductUpdated: () {
            // Refresh the page after editing
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, int productId) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await deleteProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Low in Stock'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: theme.textTheme.titleLarge?.color,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: FutureBuilder<List<Productmodel>>(
        future: getAllProducts(), // Fetch all products
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          } else {
            // Filter products with low stock (e.g., quantity <= 10)
            final lowStockProducts = snapshot.data!
                .where((product) => product.productQuantity <= 10)
                .toList();

            if (lowStockProducts.isEmpty) {
              return const Center(child: Text('No products are low in stock.'));
            }

            // Display the low stock products
            return ListView.builder(
              itemCount: lowStockProducts.length,
              itemBuilder: (context, index) {
                final product = lowStockProducts[index];
                return Card(
                  color: theme.cardColor, // Card background color
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ProductCard(
                    image: product.imagePath ?? 'default_image_path',
                    name: product.productName ?? 'Unknown Product',
                    stock: product.productQuantity ?? 0,
                    price: product.productPrice,
                    category: product.category,
                    inStock: product.productQuantity > 0,
                    description: product.description,
                    onEdit: () => _navigateToEditProduct(context, product),
                    onDelete: () => _deleteProduct(context, product.id),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
