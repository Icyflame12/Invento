import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inventory_app_final/model/product_user_model.dart';

class FullSalesHistoryPage extends StatefulWidget {
  final ValueNotifier<List<Salemodel>> salesNotifier;

  const FullSalesHistoryPage({super.key, required this.salesNotifier});

  @override
  _FullSalesHistoryPageState createState() => _FullSalesHistoryPageState();
}

class _FullSalesHistoryPageState extends State<FullSalesHistoryPage> {
  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  // Load sales from Hive and set them to the notifier
  Future<void> _loadSales() async {
    final saleDB = await Hive.openBox<Salemodel>('salesBox');
    final sales = saleDB.values.toList();
    widget.salesNotifier.value = sales; // Update the sales notifier
    widget.salesNotifier.notifyListeners();
  }

  // Fetch product by ID for sale details
  Future<Productmodel?> _getProductById(int productId) async {
    final productBox = await Hive.openBox<Productmodel>('productBox');
    return productBox.get(productId);
  }

  // Group sales by customer
  Map<String, List<Salemodel>> _groupSalesByCustomer(List<Salemodel> sales) {
    final Map<String, List<Salemodel>> groupedSales = {};
    for (var sale in sales) {
      final key = '${sale.custName}-${sale.custPhone}';
      if (groupedSales.containsKey(key)) {
        groupedSales[key]!.add(sale);
      } else {
        groupedSales[key] = [sale];
      }
    }
    return groupedSales;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Sales History'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ValueListenableBuilder<List<Salemodel>>(
        valueListenable:
            widget.salesNotifier, // Listen to salesNotifier for changes
        builder: (context, sales, child) {
          final groupedSales = _groupSalesByCustomer(sales);
          final groupedSalesList = groupedSales.entries.toList();

          return sales.isEmpty
              ? const Center(child: Text('No sales records available.'))
              : ListView.builder(
                  itemCount: groupedSalesList.length,
                  itemBuilder: (context, index) {
                    final customerSales = groupedSalesList[index].value;
                    final firstSale = customerSales.first;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer: ${firstSale.custName}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Phone: ${firstSale.custPhone}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const Divider(height: 30, thickness: 1),
                            _buildSectionTitle('Sales Details'),
                            const SizedBox(height: 8),
                            ...customerSales.map((sale) {
                              return FutureBuilder<Productmodel?>(
                                future: _getProductById(sale.productId),
                                builder: (context, productSnapshot) {
                                  if (productSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (productSnapshot.hasError) {
                                    return const Center(
                                        child: Text(
                                            'Error loading product details'));
                                  } else if (!productSnapshot.hasData ||
                                      productSnapshot.data == null) {
                                    return const Center(
                                        child: Text('Product not found'));
                                  }

                                  final product = productSnapshot.data!;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            margin: const EdgeInsets.only(
                                                right: 16),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: product
                                                        .imagePath.isNotEmpty &&
                                                    File(product.imagePath)
                                                        .existsSync()
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.file(
                                                        File(
                                                            product.imagePath ??
                                                                ''),
                                                        fit: BoxFit.cover),
                                                  )
                                                : const Icon(
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                    color: Colors.grey),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.productName ??
                                                      'Unknown Product',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                    'Category: ${product.category}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium),
                                                Text(
                                                    'Price: \$${product.productPrice.toStringAsFixed(2)}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium),
                                                Text(
                                                    'Quantity Sold: ${sale.quantitySold}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium),
                                                Text(
                                                  'Date: ${sale.saleDate.toLocal().toString().split(' ')[0]}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 30, thickness: 1),
                                    ],
                                  );
                                },
                              );
                            }),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                'Total Price: \$${customerSales.fold<double>(0.0, (sum, sale) => sum + sale.totalPrice).toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.blueAccent,
      ),
    );
  }
}
