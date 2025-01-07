import 'package:flutter/material.dart';

class CustomerDetailPage extends StatelessWidget {
  final String customerName;

  const CustomerDetailPage({super.key, required this.customerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Details: $customerName'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Text(
            'Details for $customerName'), // You can fetch more details here as needed
      ),
    );
  }
}
