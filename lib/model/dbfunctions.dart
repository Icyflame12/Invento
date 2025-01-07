import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inventory_app_final/model/product_user_model.dart';

// ValueNotifiers for state management
ValueNotifier<List<Productmodel>> productListNotifier = ValueNotifier([]);
ValueNotifier<List<Salemodel>> salesListNotifier = ValueNotifier([]);
ValueNotifier<List<Revenuemodel>> revenueListNotifier = ValueNotifier([]);
ValueNotifier<List<Userdatamodel>> userListNotifier = ValueNotifier([]);

// IDGenerator Class for unique ID generation
class IDGenerator {
  static const String _counterBoxKey = 'counterBoxKey';
  static late Box<int> _counterBox;

  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_counterBoxKey)) {
      _counterBox = await Hive.openBox<int>(_counterBoxKey);
    } else {
      _counterBox = Hive.box<int>(_counterBoxKey);
    }
  }

  static int generateUniqueID() {
    int counter = _counterBox.get('counter', defaultValue: 0)!;
    _counterBox.put('counter', counter + 1);
    return counter;
  }
}

// Database Utility Functions
Future<Box<T>> _openBox<T>(String boxName) async {
  if (!Hive.isBoxOpen(boxName)) {
    return await Hive.openBox<T>(boxName);
  } else {
    return Hive.box<T>(boxName);
  }
}

// Product Functions

/// Add a new product to the database
Future<void> addProduct(Productmodel product) async {
  final productDB = await _openBox<Productmodel>('productBox');

  // Generate a unique ID for the new product
  product.id = IDGenerator.generateUniqueID();

  // Save the product
  await productDB.put(product.id, product);

  // Update the notifier
  productListNotifier.value = productDB.values.toList();
  productListNotifier.notifyListeners();

  debugPrint("Added product with ID: ${product.id}");
}

/// Fetch all products from the database
Future<List<Productmodel>> getAllProducts() async {
  final productDB = await _openBox<Productmodel>('productBox');
  final products = productDB.values.toList();

  // Update the notifier
  productListNotifier.value = products;
  productListNotifier.notifyListeners();

  debugPrint("Fetched ${products.length} products from database.");
  return products;
}

/// Update an existing product
Future<void> updateProduct(int id, Productmodel updatedProduct) async {
  final productDB = await _openBox<Productmodel>('productBox');

  if (productDB.containsKey(id)) {
    updatedProduct.id = id; // Ensure ID remains unchanged
    await productDB.put(id, updatedProduct);

    // Update the notifier
    productListNotifier.value = productDB.values.toList();
    productListNotifier.notifyListeners();

    debugPrint("Updated product with ID: $id.");
  } else {
    debugPrint("Error: Product with ID $id not found.");
  }
}

/// Delete a product by ID
Future<void> deleteProduct(int id) async {
  final productDB = await _openBox<Productmodel>('productBox');

  if (productDB.containsKey(id)) {
    await productDB.delete(id);

    // Update the notifier
    productListNotifier.value = productDB.values.toList();
    productListNotifier.notifyListeners();

    debugPrint("Deleted product with ID: $id.");
  } else {
    debugPrint("Error: Product with ID $id not found.");
  }
}

// Sale Functions
Future<void> addSale(Salemodel sale) async {
  final saleDB = await _openBox<Salemodel>('salesBox');
  await saleDB.add(sale);
  salesListNotifier.value = saleDB.values.toList();
  salesListNotifier.notifyListeners();

  final productDB = await _openBox<Productmodel>('productBox');
  final product = productDB.get(sale.productId);

  if (product != null && product.productQuantity >= sale.quantitySold) {
    product.productQuantity -= sale.quantitySold;
    await productDB.put(product.id, product);
  }

  await updateRevenue();
}

Future<List<Salemodel>> getAllSales() async {
  final saleDB = await _openBox<Salemodel>('salesBox');
  return saleDB.values.toList();
}

Future<void> updateRevenue() async {
  final saleDB = await _openBox<Salemodel>('salesBox');
  final sales = saleDB.values;

  // Ensure default value if sales are empty or revenue is null
  double totalRevenue =
      sales.fold(0, (sum, sale) => sum + (sale.totalPrice ?? 0.0));
  double dailyRevenue = sales
      .where((sale) => sale.saleDate
          .isAfter(DateTime.now().subtract(const Duration(days: 1))))
      .fold(0, (sum, sale) => sum + (sale.totalPrice ?? 0.0));
  double monthlyRevenue = sales
      .where((sale) => sale.saleDate
          .isAfter(DateTime(DateTime.now().year, DateTime.now().month, 1)))
      .fold(0, (sum, sale) => sum + (sale.totalPrice ?? 0.0));

  int numberOfSales = sales.length; // Count of total sales transactions
  double averageSaleValue = numberOfSales > 0
      ? totalRevenue / numberOfSales
      : 0.0; // Avoid division by zero

  final revenueDB = await _openBox<Revenuemodel>('revenue');
  double growthPercentage = 0;

  if (revenueDB.isNotEmpty) {
    final lastRevenue = revenueDB.values.last;
    // Ensure totalRevenue is not null and handle division by zero
    growthPercentage = lastRevenue.totalRevenue > 0
        ? ((totalRevenue - lastRevenue.totalRevenue) /
                lastRevenue.totalRevenue) *
            100
        : 0;
  }

  // Create a new revenue model with safe defaults
  final newRevenue = Revenuemodel(
    totalRevenue: totalRevenue,
    dailyRevenue: dailyRevenue,
    monthlyRevenue: monthlyRevenue,
    growthPercentage: growthPercentage,
    averageSaleValue: averageSaleValue,
    filteredRevenue: totalRevenue, // Assign calculated value here
  );

  await revenueDB.put(0, newRevenue); // Save the new revenue data
  revenueListNotifier.value = revenueDB.values.toList(); // Update the notifier
  revenueListNotifier.notifyListeners(); // Notify listeners

  debugPrint("Updated revenue data with average sale value: $averageSaleValue");
}

// Function to add a new user during sign-up
Future<void> addSignUp(String email, String username, String password) async {
  final userDB = await _openBox<Userdatamodel>('login_db');
  final newUser = Userdatamodel(
    id: IDGenerator.generateUniqueID(), // Generate a unique ID
    email: email,
    name: username,
    password: password,
    isLoggedIn: false,
  );

  await userDB.put(newUser.id, newUser); // Save the user
  userListNotifier.value = userDB.values.toList(); // Update the user list
  userListNotifier.notifyListeners(); // Notify listeners for changes
}

// Function to log in using email and password
Future<Userdatamodel?> login(String email, String password) async {
  final userDB = await _openBox<Userdatamodel>('login_db');
  try {
    return userDB.values.firstWhere(
      (user) => user.email == email && user.password == password,
    );
  } catch (e) {
    return null; // Return null if no matching user is found
  }
}

// Function to save logged-in user ID
Future<void> saveLoggedInUserID(String userID) async {
  final userDB = await Hive.openBox('login_db');
  await userDB.put('currentUserID', userID); // Save the logged-in user's ID
}

// Function to load logged-in user data
Future<Map<String, String>> loadLoggedInUserData() async {
  final userDB = await _openBox<Userdatamodel>('login_db');
  final currentUserID = userDB.get('currentUserID'); // Get logged-in user's ID

  if (currentUserID != null) {
    final user = userDB.get(currentUserID); // Retrieve the user's data
    if (user != null) {
      return {
        'username': user.name,
        'email': user.email,
      };
    }
  }

  return {
    'username': 'Username',
    'email': 'Email',
  }; // Default values if no user is logged in
}

// Function to log out user
Future<void> logout() async {
  final userDB = await Hive.openBox('login_db');
  await userDB.delete('currentUserID'); // Remove the logged-in user's ID
}
