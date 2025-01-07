import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inventory_app_final/model/dbfunctions.dart';
import 'package:inventory_app_final/model/product_user_model.dart';
import 'package:inventory_app_final/widgets/sales/sales_dashbord/metric_card.dart';
import 'package:inventory_app_final/screens/sales/salesHistory.dart';
import 'package:inventory_app_final/screens/sales/addSales.dart';
import 'package:intl/intl.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  _SalesDashboardState createState() => _SalesDashboardState();
}

final ValueNotifier<List<Salemodel>> salesNotifier =
    ValueNotifier<List<Salemodel>>([]);

class _SalesDashboardState extends State<SalesDashboard> {
  int totalSales = 0;
  int productsSold = 0;
  Salemodel? latestSale;
  Productmodel topProduct = Productmodel(
    id: 0,
    productName: 'None',
    productPrice: 0.0,
    productQuantity: 0,
    category: 'Unknown',
    imagePath: '',
    description: '',
  );

  String _selectedView =
      'Bar Chart'; // Switch between "Bar Chart" and "Pie Chart"

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    try {
      final sales = await getAllSales();
      if (sales.isNotEmpty) {
        setState(() {
          latestSale = sales.last;
        });
        salesNotifier.value = sales;
        await _updateMetrics(sales);
      }
    } catch (e) {
      debugPrint('Error loading sales: $e');
    }
  }

  Future<void> _updateMetrics(List<Salemodel> sales) async {
    int newTotalSales = 0;
    int newProductsSold = 0;
    Map<int, int> productSalesCount = {};

    for (var sale in sales) {
      newTotalSales += sale.totalPrice.toInt();
      newProductsSold += sale.quantitySold;

      productSalesCount.update(
        sale.productId,
        (value) => value + sale.quantitySold,
        ifAbsent: () => sale.quantitySold,
      );
    }

    Productmodel? newTopProduct;
    int maxSales = 0;

    for (var entry in productSalesCount.entries) {
      final product = await getProductById(entry.key);
      if (product != null && entry.value > maxSales) {
        maxSales = entry.value;
        newTopProduct = product;
      }
    }

    setState(() {
      totalSales = newTotalSales;
      productsSold = newProductsSold;
      if (newTopProduct != null) {
        topProduct = newTopProduct;
      }
    });
  }

  Future<Productmodel?> getProductById(int productId) async {
    final productBox = await Hive.openBox<Productmodel>('productBox');
    return productBox.get(productId);
  }

  void _navigateToAddSalePage() async {
    final newSale = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SalesPage(),
      ),
    );

    if (newSale != null && newSale is Salemodel) {
      await addSale(newSale);
      _loadSales();
    }
  }

  void _navigateToSalesHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FullSalesHistoryPage(salesNotifier: salesNotifier),
      ),
    );
  }

  Widget _buildAnalyticsChart() {
    Map<String, double> productSalesData = {};

    // Aggregate sales data by product
    for (var sale in salesNotifier.value) {
      productSalesData.update(
        sale.productName,
        (value) => value + sale.totalPrice,
        ifAbsent: () => sale.totalPrice,
      );
    }

    if (_selectedView == 'Bar Chart') {
      List<BarChartGroupData> barGroups = [];
      int index = 0;

      productSalesData.forEach((productName, totalSales) {
        barGroups.add(
          BarChartGroupData(
            x: index++,
            barRods: [
              BarChartRodData(
                toY: totalSales,
                color: Colors.blueAccent,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      });

      return BarChart(
        BarChartData(
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= productSalesData.length) {
                    return const Text('');
                  }
                  return Text(
                    productSalesData.keys.elementAt(index),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text('\$${value.toInt()}');
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Colors.grey, width: 1),
              left: BorderSide(color: Colors.grey, width: 1),
            ),
          ),
          gridData: const FlGridData(show: true),
        ),
      );
    } else {
      // Pie Chart for Sales Distribution
      return PieChart(
        PieChartData(
          sections: productSalesData.entries.map((entry) {
            final color = Colors.primaries[
                productSalesData.keys.toList().indexOf(entry.key) %
                    Colors.primaries.length];
            return PieChartSectionData(
              value: entry.value,
              title: entry.key,
              color: color,
              radius: 50,
              titleStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 30,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📊 Sales Dashboard'),
          backgroundColor: theme.colorScheme.primary, // Use theme color
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _navigateToSalesHistory,
            ),
          ],
        ),
        body: ValueListenableBuilder<List<Salemodel>>(
          valueListenable: salesNotifier,
          builder: (context, sales, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales Overview',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MetricCard(
                        title: 'Total Sales',
                        value: '\$${totalSales.toStringAsFixed(2)}',
                        color:
                            theme.colorScheme.errorContainer, // Use theme color
                      ),
                      MetricCard(
                        title: 'Products Sold',
                        value: '$productsSold',
                        color: theme
                            .colorScheme.primaryContainer, // Use theme color
                      ),
                      MetricCard(
                        title: 'Top Product',
                        value: topProduct.productName,
                        color: theme
                            .colorScheme.onSurfaceVariant, // Use theme color
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (latestSale != null) ...[
                    Text(
                      'Latest Sale',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.sell, color: Colors.white),
                      ),
                      title: Text(
                        latestSale!.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          'Quantity: ${latestSale!.quantitySold}, Total: \$${latestSale!.totalPrice.toStringAsFixed(2)}'),
                      trailing: Text(
                        DateFormat('MMM d, y').format(latestSale!.saleDate),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sales Analytics',
                        style: theme.textTheme.titleLarge,
                      ),
                      DropdownButton<String>(
                        value: _selectedView,
                        items: ['Bar Chart', 'Pie Chart'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedView = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: _buildAnalyticsChart(),
                  ),
                  const SizedBox(height: 100),
                  Center(
                    child: ElevatedButton(
                      onPressed: _navigateToAddSalePage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.primary, // Use theme color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('+ Add Sale'),
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
