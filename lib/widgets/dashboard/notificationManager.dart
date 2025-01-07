import 'package:flutter/material.dart';
import 'package:inventory_app_final/model/product_user_model.dart';

class Notification {
  final String message;
  final String type; // e.g., 'productAdded', 'saleCompleted'
  final List<Productmodel>? products;
  final Salemodel? sale;

  Notification({
    required this.message,
    required this.type,
    this.products,
    this.sale,
  });

  List<Map<String, dynamic>> toList() {
    return [
      {'key': 'message', 'value': message},
      {'key': 'type', 'value': type},
      {
        'key': 'products',
        'value': products?.map((product) => _productToMap(product)).toList()
      },
      {'key': 'sale', 'value': sale != null ? _saleToMap(sale!) : null},
    ];
  }

  Map<String, dynamic> _productToMap(Productmodel product) {
    return {
      'productName': product.productName,
      'productQuantity': product.productQuantity,
      'productPrice': product.productPrice,
      'category': product.category,
      'imagePath': product.imagePath,
      'id': product.id,
      'description': product.description,
    };
  }

  Map<String, dynamic> _saleToMap(Salemodel sale) {
    return {
      'productId': sale.productId,
      'quantitySold': sale.quantitySold,
      'totalPrice': sale.totalPrice,
      'custName': sale.custName,
      'custPhone': sale.custPhone,
      'saleDate': sale.saleDate.toIso8601String(),
      'productName': sale.productName,
      'productPrice': sale.productPrice,
    };
  }
}

class NotificationManager {
  static final ValueNotifier<List<Notification>> notifications =
      ValueNotifier([]);

  static void addNotification({
    required String message,
    required String type,
    List<Productmodel>? products,
    Salemodel? sale,
  }) {
    final notification = Notification(
      message: message,
      type: type,
      products: products,
      sale: sale,
    );
    notifications.value = [...notifications.value, notification];
    print(
        'Notification added: $message, type: $type, products: ${products?.map((p) => p.productName)}, sale: ${sale?.custName}');
    print(
        'Current notifications: ${notifications.value.map((n) => n.toList())}');
  }

  static void removeNotification(int index) {
    final updatedNotifications = List<Notification>.from(notifications.value);
    updatedNotifications.removeAt(index);
    notifications.value = updatedNotifications;
    print('Notification removed at index: $index');
    print(
        'Current notifications: ${notifications.value.map((n) => n.toList())}');
  }
}
