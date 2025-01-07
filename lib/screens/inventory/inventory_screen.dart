import 'package:flutter/material.dart';
import 'package:inventory_app_final/screens/inventory/Addproduct.dart';
import 'package:inventory_app_final/screens/inventory/allproduct.dart';
import 'package:inventory_app_final/screens/inventory/check_in_page.dart';
import 'package:inventory_app_final/screens/inventory/low_in_stock.dart';
import 'package:inventory_app_final/screens/inventory/recently_added_page.dart';
import 'package:inventory_app_final/screens/inventory/slow_moving_items_page.dart';
import 'package:inventory_app_final/widgets/inventory/inventory_screen/bar_chart_widget.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed Header Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF023E8A), // Dark Blue
                  Color(0xFF0077B6), // Medium Blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Center(
              child: Text(
                'Inventory Dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Daily Check-in Reminder Section
                  _buildReminderCard(context, theme),

                  const SizedBox(height: 24),

                  // Analytics Section
                  Text(
                    'Inventory Analytics',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(height: 300, child: BarChartWidget()),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Categories Section
                  Text(
                    'Categories',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoriesRow(context),

                  const SizedBox(height: 32),

                  // Inventory Insights Section
                  Text(
                    'Inventory Insights',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      _buildInsightCard(
                        context,
                        theme,
                        title: 'Slow-Moving Items',
                        subtitle: 'Identify items with low sales velocity.',
                        icon: Icons.hourglass_empty,
                        color: const Color(0xFFCAF0F8), // Pale Blue
                        page: const SlowMovingItemsPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Add the Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
        title: Text(
          "Don't Forget to Check In!",
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          "Ensure your inventory is up to date for accurate tracking.",
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CheckInPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Check In",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.fromARGB(255, 252, 250, 250),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip(context, 'All Products', Icons.inventory_2,
              const Color.fromARGB(255, 255, 217, 0), const AllProductsPage()),
          _buildCategoryChip(
              context,
              'Recently Added',
              Icons.flash_on,
              const Color.fromARGB(255, 53, 115, 248),
              const RecentlyAddedPage()),
          _buildCategoryChip(context, 'Low in Stock', Icons.warning,
              const Color.fromARGB(255, 255, 83, 31), const LowInStockPage()),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, IconData icon,
      Color color, Widget page) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        avatar: Icon(icon, color: const Color.fromARGB(255, 31, 30, 30)),
        backgroundColor: color,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        },
        labelStyle: const TextStyle(
            color: Color.fromARGB(255, 14, 14, 14),
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(.9),
          child: Icon(icon, color: Colors.red),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
