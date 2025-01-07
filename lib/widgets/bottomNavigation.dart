import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:inventory_app_final/screens/home/dashboard_screen.dart';
import 'package:inventory_app_final/screens/inventory/inventory_screen.dart';
import 'package:inventory_app_final/screens/revenue/revenue_sectio_page.dart';
import 'package:inventory_app_final/screens/sales/salesDashboard.dart';
import 'package:inventory_app_final/screens/profile/profile.dart';

class BottomNavigationBarscreen extends StatefulWidget {
  const BottomNavigationBarscreen({super.key});

  @override
  State<BottomNavigationBarscreen> createState() =>
      _BottomNavigationBarscreenState();
}

class _BottomNavigationBarscreenState extends State<BottomNavigationBarscreen> {
  int _selectedIndex = 2; // Default to Dashboard (centered)

  // Handle navigation and refresh on selected screen
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          InventoryScreen(), // Inventory Screen
          SalesDashboard(), // Sales Screen
          DashBoardScreen(), // Dashboard Screen
          RevenueDashboardPage(), // Revenue Screen
          AccountsPage(), // Accounts Screen
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react, // Style options: react, fixed, flip, etc.
        items: const [
          TabItem(icon: Icons.inventory, title: 'Inventory'),
          TabItem(icon: Icons.attach_money, title: 'Sales'),
          TabItem(icon: Icons.dashboard_customize, title: 'Dashboard'),
          TabItem(icon: Icons.bar_chart, title: 'Revenue'),
          TabItem(icon: Icons.account_circle, title: 'Accounts'),
        ],
        initialActiveIndex: _selectedIndex, // Default selected index
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context)
            .bottomNavigationBarTheme
            .backgroundColor, // Applied from theme
        activeColor: Theme.of(context)
            .bottomNavigationBarTheme
            .selectedItemColor, // Applied from theme
        color: Theme.of(context)
            .bottomNavigationBarTheme
            .unselectedItemColor, // Applied from theme
      ),
    );
  }
}
