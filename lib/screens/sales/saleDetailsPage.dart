import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory_app_final/screens/sales/salesDashboard.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:inventory_app_final/model/dbfunctions.dart';
import 'package:inventory_app_final/model/product_user_model.dart';
import 'package:inventory_app_final/widgets/dashboard/notificationManager.dart';

class SaleDetailPage extends StatefulWidget {
  final List<Map<String, Object>> selectedProducts;

  const SaleDetailPage({super.key, required this.selectedProducts});

  @override
  _SaleDetailPageState createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerPhoneController = TextEditingController();

  // GlobalKey to manage the Form state
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    super.dispose();
  }

  Future<void> processSaleAction() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate product quantities
      for (var entry in widget.selectedProducts) {
        final product = entry['product'] as Productmodel;
        final quantity = entry['quantity'] as int;

        if (quantity > product.productQuantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Quantity for ${product.productName} exceeds available stock.')),
          );
          return; // Stop the sale process if any product quantity exceeds the stock
        }
      }

      // Proceed only if form is valid and quantities are correct
      final customerName = customerNameController.text;
      final customerPhone = customerPhoneController.text;

      final sales = widget.selectedProducts.map((entry) {
        final product = entry['product'] as Productmodel;
        final quantity = entry['quantity'] as int;
        final totalPrice = product.productPrice * quantity;

        return Salemodel(
          productId: product.id,
          quantitySold: quantity,
          totalPrice: totalPrice,
          custName: customerName,
          custPhone: customerPhone,
          saleDate: DateTime.now(),
          productName: product.productName ?? 'Unknown Product',
          productPrice: product.productPrice,
        );
      }).toList();

      for (var sale in sales) {
        await addSale(sale); // Assuming addSale is a method to add sale data
      }

      // Add notification for sale completion
      NotificationManager.addNotification(
        message: 'Sale completed for ${sales.length} products to $customerName',
        type: 'saleCompleted',
        products: widget.selectedProducts
            .map((entry) => entry['product'] as Productmodel)
            .toList(),
        sale: sales.first,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sales recorded successfully.')),
      );

      // Navigate to the Sales Dashboard after completing the sale
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const SalesDashboard(),
        ),
        ModalRoute.withName(
            '/'), // Replace with the route name of your main dashboard
      );
    } else {
      // If the form is invalid, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the required fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the total amount for all selected products
    double totalAmount = 0;
    for (var entry in widget.selectedProducts) {
      final product = entry['product'] as Productmodel;
      final quantity = entry['quantity'] as int;
      totalAmount += product.productPrice * quantity;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the form key to manage form state
          child: ListView(
            children: [
              // Header Section for Invoice look
              Center(
                child: Text(
                  'INVOICE',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),

              // Customer Details
              _buildTextField(
                label: 'Customer Name',
                controller: customerNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: 'Customer Phone',
                controller: customerPhoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer phone';
                  }
                  // You can add more phone validation logic here, e.g., checking length
                  if (value.length < 10) {
                    return 'Phone number must be at least 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Divider(),

              // Product List
              const Text(
                'Selected Products:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...widget.selectedProducts.map((entry) {
                final product = entry['product'] as Productmodel;
                final quantityController = TextEditingController(
                  text: entry['quantity'].toString(),
                );

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Product image
                        Image.file(
                          File(product.imagePath),
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 10),
                        // Product details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.productName ?? 'Unknown Product',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text('Price: \$${product.productPrice}'),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Text('Qty: '),
                                  SizedBox(
                                    width: 50,
                                    child: TextFormField(
                                      controller: quantityController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          final quantity =
                                              int.tryParse(value) ?? 0;
                                          if (quantity >
                                              product.productQuantity) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Quantity for ${product.productName} exceeds available stock.',
                                                ),
                                              ),
                                            );
                                          } else {
                                            entry['quantity'] = quantity;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Total for the product
                        Text(
                          '\$${(product.productPrice * (entry['quantity'] as int)).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
              const Divider(),

              // Total Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Total: ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '\$${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Complete Sale Sliding Button
              Center(
                child: SlideAction(
                  text: 'Slide to Complete Sale',
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  outerColor: const Color.fromARGB(255, 0, 0, 0),
                  innerColor: const Color.fromARGB(255, 250, 252, 250),
                  onSubmit: () => processSaleAction(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }
}
