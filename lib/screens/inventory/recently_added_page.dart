import 'package:flutter/material.dart';
import 'package:inventory_app_final/model/product_user_model.dart';
import 'package:inventory_app_final/screens/inventory/Editproduct.dart';
import 'package:inventory_app_final/widgets/inventory/all_product_page/product_list.dart';
import 'package:inventory_app_final/widgets/inventory/recently_added_page/confirmation_dialog.dart';
import 'package:inventory_app_final/widgets/inventory/recently_added_page/product_service.dart';

class RecentlyAddedPage extends StatefulWidget {
  const RecentlyAddedPage({super.key});

  @override
  _RecentlyAddedPageState createState() => _RecentlyAddedPageState();
}

class _RecentlyAddedPageState extends State<RecentlyAddedPage> {
  late Future<List<Productmodel>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _futureProducts = ProductService.getRecentlyAddedProducts();
  }

  void _handleDeleteProduct(int productId) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirm Deletion',
      content: 'Are you sure you want to delete this product?',
    );
    if (confirmed) {
      await ProductService.deleteProduct(productId);
      _loadProducts();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully.')),
      );
    }
  }

  Future<void> _handleEditProduct(Productmodel product, int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProductScreen(
          product: product,
          productId: product.id,
          onProductUpdated: () {
            _loadProducts();
            setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Added Products'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: theme.textTheme.titleLarge?.color,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Productmodel>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          }
          return ProductList(
            products: snapshot.data!,
            onEdit: (product, index) => _handleEditProduct(product, index),
            onDelete: _handleDeleteProduct,
          );
        },
      ),
    );
  }
}
