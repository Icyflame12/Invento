import 'package:hive/hive.dart';
import 'package:inventory_app_final/model/product_user_model.dart';

class RevenueManager {
  final Box<Salemodel> salesBox;
  final Box<Revenuemodel> revenueBox;

  RevenueManager({required this.salesBox, required this.revenueBox});

  Future<void> updateRevenue() async {
    double totalRevenue = 0.0;
    double dailyRevenue = 0.0;
    double monthlyRevenue = 0.0;
    double previousMonthlyRevenue = 0.0;
    int totalSalesCount = 0; // To calculate the average sale value

    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime startOfPreviousMonth = DateTime(
      now.month == 1 ? now.year - 1 : now.year, // Handle January
      now.month == 1 ? 12 : now.month - 1, // Handle month wrap
      1,
    );

    // Loop through sales and calculate revenue
    for (var sale in salesBox.values) {
      totalRevenue += sale.totalPrice;
      totalSalesCount++; // Count each sale

      // Check if sale is on the current day
      if (sale.saleDate.isAfter(startOfDay)) {
        dailyRevenue += sale.totalPrice;
      }

      // Check if sale is in the current month
      if (sale.saleDate.isAfter(startOfMonth)) {
        monthlyRevenue += sale.totalPrice;
      }

      // Check if sale is in the previous month
      if (sale.saleDate.isAfter(startOfPreviousMonth) &&
          sale.saleDate.isBefore(startOfMonth)) {
        previousMonthlyRevenue += sale.totalPrice;
      }
    }

    // Calculate growth percentage based on the previous revenue data
    double growthPercentage =
        _calculateGrowthPercentage(monthlyRevenue, previousMonthlyRevenue);

    // Calculate average sale value
    double averageSaleValue =
        totalSalesCount > 0 ? totalRevenue / totalSalesCount : 0.0;

    // Save the revenue data to Hive
    final revenue = Revenuemodel(
      totalRevenue: totalRevenue,
      dailyRevenue: dailyRevenue,
      monthlyRevenue: monthlyRevenue,
      growthPercentage: growthPercentage,
      averageSaleValue: averageSaleValue,
      filteredRevenue: totalRevenue, // Assign average sale value here
    );
    await revenueBox.put('currentRevenue', revenue);
  }

  double _calculateGrowthPercentage(
      double currentMonthRevenue, double previousMonthRevenue) {
    if (previousMonthRevenue == 0.0) return 0.0;
    return ((currentMonthRevenue - previousMonthRevenue) /
            previousMonthRevenue) *
        100;
  }
}
