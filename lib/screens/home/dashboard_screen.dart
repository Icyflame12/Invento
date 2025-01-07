import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory_app_final/widgets/dashboard/Summary_items.dart';
import 'package:inventory_app_final/screens/inventory/Editproduct.dart';
import 'package:inventory_app_final/screens/home/notificationPages.dart';
import 'package:inventory_app_final/screens/home/reminderScreen.dart'
    as reminder;
import 'package:inventory_app_final/screens/home/topSellingProduct.dart'
    as topSelling;
import 'package:inventory_app_final/model/product_user_model.dart';
import 'package:inventory_app_final/screens/revenue/revenue_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'package:inventory_app_final/widgets/dashboard/prfoileimage.dart'; // Import ProfileImageProvider

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  DashBoardScreenState createState() => DashBoardScreenState();
}

class DashBoardScreenState extends State<DashBoardScreen> {
  ValueNotifier<int> totalSalesNotifier = ValueNotifier(0);
  ValueNotifier<int> todaysSalesNotifier = ValueNotifier(0);
  ValueNotifier<double> todaysRevenueNotifier = ValueNotifier(0.0);
  ValueNotifier<int> distinctProductsNotifier = ValueNotifier(0);
  ValueNotifier<String> userNameNotifier =
      ValueNotifier(''); // ValueNotifier for username

  late RevenueManager _revenueManager;
  late Box<Salemodel> salesBox;
  late Box<Revenuemodel> revenueBox;
  late Box<Productmodel> productBox;
  late Box<Userdatamodel> userBox;
  int totalProducts = 0;
  List<Map<String, dynamic>> reminders = [];
  List<Map<String, dynamic>> topSellingProducts = [];

  @override
  void initState() {
    super.initState();
    _initializeHiveAndLoadData();
  }

  Future<void> _initializeHiveAndLoadData() async {
    await Hive.initFlutter();
    await _openBoxes();
    await _loadDataFromHive();
    await _initializeRevenueManager();
    await _loadTotalProducts();
    await _loadReminders();
    await _loadTopSellingProducts();
    await _loadUserData();
  }

  Future<void> _openBoxes() async {
    salesBox = Hive.isBoxOpen('salesBox')
        ? Hive.box<Salemodel>('salesBox')
        : await Hive.openBox<Salemodel>('salesBox');
    revenueBox = Hive.isBoxOpen('revenueBox')
        ? Hive.box<Revenuemodel>('revenueBox')
        : await Hive.openBox<Revenuemodel>('revenueBox');
    productBox = Hive.isBoxOpen('productBox')
        ? Hive.box<Productmodel>('productBox')
        : await Hive.openBox<Productmodel>('productBox');
    userBox = Hive.isBoxOpen('login_db')
        ? Hive.box<Userdatamodel>('login_db')
        : await Hive.openBox<Userdatamodel>('login_db');
  }

  Future<void> _initializeRevenueManager() async {
    try {
      _revenueManager =
          RevenueManager(salesBox: salesBox, revenueBox: revenueBox);
      _revenueManager.updateRevenue();
      await _loadRevenueData();
    } catch (e) {
      print('Error initializing RevenueManager: $e');
    }
  }

  Future<void> _loadRevenueData() async {
    print('Loading revenue data...');
    // Implement the logic to load revenue data here
  }

  Future<void> _loadUserData() async {
    final userDB = await Hive.openBox<Userdatamodel>('login_db');
    if (userDB.isNotEmpty) {
      final user = userDB.values.first; // Assuming there's only one user
      print('Fetched user data: ${user.name}, ${user.email}'); // Debug print
      userNameNotifier.value = user.name;
      print('Loaded user data: ${userNameNotifier.value}'); // Debug print
    } else {
      print('No user data found'); // Debug print
    }
  }

  Future<void> _loadDataFromHive() async {
    try {
      print('Loading data from Hive...');
      int totalSales = 0;
      int todaysSales = 0;
      double todaysRevenue = 0.0;
      final distinctProductsToday = <String>{};

      final today = DateTime.now();

      for (var sale in salesBox.values) {
        totalSales += sale.quantitySold;
        if (sale.saleDate.year == today.year &&
            sale.saleDate.month == today.month &&
            sale.saleDate.day == today.day) {
          todaysSales += sale.quantitySold;
          todaysRevenue += sale.totalPrice;
          distinctProductsToday.add(sale.productName);
        }
      }

      totalSalesNotifier.value = totalSales;
      todaysSalesNotifier.value = todaysSales;
      todaysRevenueNotifier.value = todaysRevenue;
      distinctProductsNotifier.value = distinctProductsToday.length;

      print(
          'Loaded data: totalSales=$totalSales, distinctProducts=${distinctProductsNotifier.value}, todaysSales=$todaysSales, todaysRevenue=$todaysRevenue');
    } catch (e) {
      print('Error loading data from Hive: $e');
    }
  }

  Future<void> _loadTotalProducts() async {
    setState(() {
      totalProducts = productBox.length;
    });
  }

  Future<void> refresh() async {
    try {
      await _loadDataFromHive();
      _revenueManager.updateRevenue();
      await _loadTotalProducts();
      await _loadReminders();
      await _loadTopSellingProducts();
      await _loadUserData();
      print('Refreshed data.');
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  Future<void> _loadReminders() async {
    setState(() {
      reminders = productBox.values
          .where((product) => product.productQuantity < 10)
          .map((product) => {
                'name': product.productName,
                'stock': product.productQuantity,
                'id': product.id,
                'imageUrl': product.imagePath
              })
          .toList();
      print('Loaded reminders: $reminders');
    });
  }

  Future<void> _loadTopSellingProducts() async {
    final productSales = <String, int>{};

    for (var sale in salesBox.values) {
      productSales.update(
          sale.productName, (value) => value + sale.quantitySold,
          ifAbsent: () => sale.quantitySold);
    }

    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      topSellingProducts = sortedProducts.take(5).map((entry) {
        final product = productBox.values
            .firstWhere((product) => product.productName == entry.key,
                orElse: () => Productmodel(
                      productName: '',
                      productQuantity: 0,
                      productPrice: 0.0,
                      category: '',
                      imagePath: '',
                      id: 0,
                      description: '',
                    ));
        return {
          'name': entry.key,
          'sold': entry.value,
          'price': product.productPrice,
          'imageUrl': product.imagePath,
        };
      }).toList();
      print('Loaded top-selling products: $topSellingProducts');
    });
  }

  void _navigateToEditProduct(String productId) {
    final product = productBox.get(int.parse(productId));
    if (product != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateProductScreen(
            product: product, // Pass the product object
            productId: product.id, // Pass the product ID
            onProductUpdated: () =>
                refresh(), // Callback to refresh after update
          ),
        ),
      ).then((_) {
        refresh(); // Refresh the data after navigating back
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileImageProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildSummarySection(),
                  const SizedBox(height: 16),
                  const SizedBox(), // Empty widget to remove the action buttons
                  const SizedBox(height: 32),
                  reminder.RemindersSection(
                    reminders: reminders,
                    onReminderTap: _navigateToEditProduct,
                    onUpdateTap: (productId) {
                      _navigateToEditProduct(productId);
                    },
                  ),
                  const SizedBox(height: 32),
                  topSelling.TopSellingProducts(products: topSellingProducts),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          ValueListenableBuilder<File?>(
            valueListenable:
                Provider.of<ProfileImageProvider>(context).profileImageNotifier,
            builder: (context, profileImage, _) {
              return CircleAvatar(
                radius: 30,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage)
                    : const AssetImage('assets/images/28829132.jpg'),
              );
            },
          ),
          const SizedBox(width: 16),
          ValueListenableBuilder<String>(
            valueListenable: userNameNotifier,
            builder: (context, userName, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi $userName',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text(
                    'Let\'s streamline your inventory!',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              );
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary, // Use theme color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Today\'s Summary',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SummaryItem(
                  title: 'Total Products', count: totalProducts.toString()),
              ValueListenableBuilder<int>(
                valueListenable: totalSalesNotifier,
                builder: (context, totalSales, _) {
                  return SummaryItem(
                      title: 'Total Sales', count: totalSales.toString());
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: todaysSalesNotifier,
                builder: (context, todaysSales, _) {
                  return SummaryItem(
                      title: 'Today\'s Sales', count: todaysSales.toString());
                },
              ),
              ValueListenableBuilder<double>(
                valueListenable: todaysRevenueNotifier,
                builder: (context, todaysRevenue, _) {
                  return SummaryItem(
                      title: 'Today\'s Revenue',
                      count: '\$${todaysRevenue.toStringAsFixed(2)}');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
