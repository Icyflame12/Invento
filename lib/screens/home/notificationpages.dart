import 'package:flutter/material.dart';
import 'package:inventory_app_final/widgets/dashboard/notificationManager.dart'
    as custom;

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor, // Use theme color
        foregroundColor:
            Theme.of(context).appBarTheme.foregroundColor, // Use theme color
      ),
      body: ValueListenableBuilder<List<custom.Notification>>(
        valueListenable: custom.NotificationManager.notifications,
        builder: (context, notifications, _) {
          debugPrint(
              'Building NotificationsPage with notifications: ${notifications.map((n) => n.message).toList()}');

          return notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications available.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          notification.type == 'productAdded'
                              ? Icons.inventory
                              : Icons.shopping_cart,
                          color: Theme.of(context)
                              .colorScheme
                              .primary, // Use theme color
                          size: 40,
                        ),
                        title: Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color, // Use theme text color
                          ),
                        ),
                        subtitle: _buildNotificationDetails(notification),
                        trailing: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: () {
                            custom.NotificationManager.removeNotification(
                                index);
                          },
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  Widget? _buildNotificationDetails(custom.Notification notification) {
    if (notification.sale != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customer: ${notification.sale!.custName}'),
          ...?notification.products
              ?.map((product) => Text('Product: ${product.productName}')),
        ],
      );
    } else if (notification.products != null &&
        notification.products!.isNotEmpty) {
      return Text('Product: ${notification.products!.first.productName}');
    }
    return null; // No details to show
  }
}
