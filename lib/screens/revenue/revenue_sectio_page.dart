import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:inventory_app_final/model/product_user_model.dart';

class RevenueDashboardPage extends StatefulWidget {
  const RevenueDashboardPage({super.key});

  @override
  _RevenueDashboardPageState createState() => _RevenueDashboardPageState();
}

class _RevenueDashboardPageState extends State<RevenueDashboardPage> {
  ValueNotifier<Revenuemodel> revenueNotifier = ValueNotifier(
    Revenuemodel(
      totalRevenue: 0.0,
      dailyRevenue: 0.0,
      monthlyRevenue: 0.0,
      growthPercentage: 0.0,
      averageSaleValue: 0.0,
      filteredRevenue: 0.0,
    ),
  );

  late Box<Salemodel> salesBox;
  bool isLoading = true;
  String selectedFilterType = "All Time"; // Default filter
  DateTimeRange? selectedDateRange;

  List<FlSpot> dailyRevenueSpots = [];
  List<Map<String, dynamic>> revenueByProduct = [];

  @override
  void initState() {
    super.initState();
    _initializeHiveAndLoadData();
  }

  Future<void> _initializeHiveAndLoadData() async {
    await Hive.initFlutter();
    await _openBoxes();
    await _calculateRevenueData();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _openBoxes() async {
    salesBox = Hive.isBoxOpen('salesBox')
        ? Hive.box<Salemodel>('salesBox')
        : await Hive.openBox<Salemodel>('salesBox');
  }

  Future<void> _calculateRevenueData() async {
    double totalRevenue = 0.0;
    double filteredRevenue = 0.0;
    int totalSalesCount = 0;

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime startOfMonth = DateTime(now.year, now.month, 1);

    Map<DateTime, double> dailyRevenueMap = {};
    Map<String, double> productRevenueMap = {};

    for (var sale in salesBox.values) {
      totalRevenue += sale.totalPrice;
      totalSalesCount++;

      // Calculate filtered revenue
      if (selectedFilterType == "Daily" && sale.saleDate.isAfter(startOfDay)) {
        filteredRevenue += sale.totalPrice;
      } else if (selectedFilterType == "Monthly" &&
          sale.saleDate.isAfter(startOfMonth)) {
        filteredRevenue += sale.totalPrice;
      } else if (selectedFilterType == "All Time") {
        filteredRevenue = totalRevenue;
      } else if (selectedDateRange != null &&
          sale.saleDate.isAfter(selectedDateRange!.start) &&
          sale.saleDate.isBefore(selectedDateRange!.end)) {
        filteredRevenue += sale.totalPrice;
      }

      // Track revenue by product
      DateTime saleDate =
          DateTime(sale.saleDate.year, sale.saleDate.month, sale.saleDate.day);
      dailyRevenueMap[saleDate] =
          (dailyRevenueMap[saleDate] ?? 0) + sale.totalPrice;

      productRevenueMap[sale.productName] =
          (productRevenueMap[sale.productName] ?? 0) + sale.totalPrice;
    }

    dailyRevenueSpots = _generateDailyRevenueSpots(dailyRevenueMap);
    revenueByProduct = productRevenueMap.entries
        .map((entry) => {'product': entry.key, 'revenue': entry.value})
        .toList();

    double averageSaleValue =
        totalSalesCount > 0 ? totalRevenue / totalSalesCount : 0.0;
    revenueNotifier.value = Revenuemodel(
      totalRevenue: totalRevenue,
      dailyRevenue: filteredRevenue,
      monthlyRevenue: filteredRevenue, // Update as needed
      growthPercentage: 0.0, // Add growth calculation logic if required
      averageSaleValue: averageSaleValue,
      filteredRevenue: filteredRevenue,
    );
  }

  List<FlSpot> _generateDailyRevenueSpots(
      Map<DateTime, double> dailyRevenueMap) {
    List<DateTime> sortedDates = dailyRevenueMap.keys.toList()..sort();
    return sortedDates.asMap().entries.map((entry) {
      int index = entry.key;
      DateTime date = entry.value;
      return FlSpot(index.toDouble(), dailyRevenueMap[date]!);
    }).toList();
  }

  void _showDateRangePicker() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
        selectedFilterType = "Custom Range";
      });
      await _calculateRevenueData();
    }
  }

  Widget _buildSummaryCard(String title, double value,
      {bool isPercentage = false}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPercentage
                  ? '${value.toStringAsFixed(2)}%'
                  : NumberFormat.currency(symbol: '\$').format(value),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueGraph() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: dailyRevenueSpots,
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.blue,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueList() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: revenueByProduct.length,
          itemBuilder: (context, index) {
            final item = revenueByProduct[index];
            return ListTile(
              title: Text(
                item['product'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                NumberFormat.currency(symbol: '\$').format(item['revenue']),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<String>(
              value: selectedFilterType,
              items: ["All Time", "Daily", "Monthly", "Custom Range"]
                  .map((filter) => DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      ))
                  .toList(),
              onChanged: (value) async {
                if (value == "Custom Range") {
                  _showDateRangePicker();
                } else {
                  setState(() {
                    selectedFilterType = value!;
                    selectedDateRange = null;
                  });
                  await _calculateRevenueData();
                }
              },
            ),
            if (selectedDateRange != null)
              Text(
                "${DateFormat.yMMMd().format(selectedDateRange!.start)} - ${DateFormat.yMMMd().format(selectedDateRange!.end)}",
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Dashboard'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Revenue Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    _buildFilterSection(),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return _buildSummaryCard(
                              'Total Revenue',
                              revenueNotifier.value.totalRevenue,
                            );
                          case 1:
                            return _buildSummaryCard(
                              'Daily Revenue',
                              revenueNotifier.value.dailyRevenue,
                            );
                          case 2:
                            return _buildSummaryCard(
                              'Filtered Revenue',
                              revenueNotifier.value.filteredRevenue,
                            );
                          case 3:
                            return _buildSummaryCard(
                              'Average Sale Value',
                              revenueNotifier.value.averageSaleValue,
                            );
                          default:
                            return const SizedBox.shrink();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Revenue Graph',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    _buildRevenueGraph(),
                    const SizedBox(height: 20),
                    Text(
                      'Revenue by Product',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    _buildRevenueList(),
                  ],
                ),
              ),
            ),
    );
  }
}
