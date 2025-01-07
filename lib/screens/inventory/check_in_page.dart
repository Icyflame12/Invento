import 'dart:io';
import 'package:flutter/material.dart';
import '../../model/dbfunctions.dart';
import '../../model/product_user_model.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({Key? key}) : super(key: key);

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  List<Productmodel> checkInProducts = [];
  Map<int, TextEditingController> stockControllers =
      {}; // To hold controllers for each product

  @override
  void initState() {
    super.initState();
    _loadCheckInProducts();
  }

  Future<void> _loadCheckInProducts() async {
    final products = await getAllProducts();
    setState(() {
      checkInProducts = products
          .where((product) => product.productQuantity <= 10)
          .toList(); // Adjust this condition as per your requirement

      // Initialize controllers for each product
      for (var product in checkInProducts) {
        stockControllers[product.id] = TextEditingController(
            text: product.productQuantity
                .toString()); // Pre-fill with existing stock quantity
      }
    });
  }

  Future<void> _updateStock(Productmodel product) async {
    final newQuantity = int.tryParse(stockControllers[product.id]!.text);

    if (newQuantity != null) {
      product.productQuantity = newQuantity; // Update the product's quantity

      // Update the product in the database
      await updateProduct(product.id, product);

      setState(() {
        checkInProducts
            .remove(product); // Optionally remove product after updating
      });
    } else {
      // Show a validation message if input is not a valid number
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Products'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: checkInProducts.isEmpty
          ? const Center(child: Text('No products to check in.'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: checkInProducts.length,
                itemBuilder: (context, index) {
                  final product = checkInProducts[index];
                  return Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: product.imagePath != null &&
                                  product.imagePath!.isNotEmpty
                              ? Image.file(
                                  File(product.imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.productName ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stock: ${product.productQuantity}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Text field to manually enter stock quantity
                              TextField(
                                controller: stockControllers[product.id],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Enter Stock',
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _updateStock(product),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                ),
                                child: const Text('Update Stock'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
