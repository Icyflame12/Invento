import 'package:flutter/material.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  SalesReportScreenState createState() => SalesReportScreenState();
}

class SalesReportScreenState extends State<SalesReportScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Report"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: 10, // Replace with actual data count
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ExpansionTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sale #${index + 1}'),
                        Text('\$250',
                            style: TextStyle(color: Colors.blueAccent)),
                      ],
                    ),
                    children: [
                      ListTile(
                        title: Text('Product: Product A'),
                        subtitle:
                            Text('Date: 2025-01-05\nQuantity: 5\nTotal: \$250'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
