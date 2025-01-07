import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Ensure these models and adapters are defined and imported correctly
import 'model/product_user_model.dart';
import 'model/dbfunctions.dart';
import 'widgets/bottomNavigation.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/sales/addSales.dart';
import 'screens/sales/salesDashboard.dart';
import 'screens/revenue/revenue_sectio_page.dart';
import 'screens/profile/login.dart';
import 'widgets/dashboard/prfoileimage.dart';

// Declare Hive boxes globally
late Box<Productmodel> productBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive and register adapters
    await Hive.initFlutter();
    Hive.registerAdapter(ProductmodelAdapter());
    Hive.registerAdapter(UserdatamodelAdapter());
    Hive.registerAdapter(SalemodelAdapter());
    Hive.registerAdapter(RevenuemodelAdapter());

    // Open necessary boxes
    productBox = await Hive.openBox<Productmodel>('product');
    await Hive.openBox<Salemodel>('salesBox');
    await Hive.openBox<Userdatamodel>('login_db');
    await Hive.openBox<Revenuemodel>('revenueBox');
    await Hive.openBox('login_state');

    // Ensure IDGenerator is defined and imported correctly
    await IDGenerator.initialize();

    // Check login state from login_db
    final loginBox = Hive.box<Userdatamodel>('login_db');
    final user = loginBox.get('user');
    final isLoggedIn = user?.isLoggedIn ?? false;

    // Ensure ProfileImageProvider is defined and imported correctly
    final profileImageProvider = ProfileImageProvider();
    await profileImageProvider.loadProfileImage();

    // Run the app with ChangeNotifierProvider for profile image
    runApp(
      ChangeNotifierProvider(
        create: (_) => profileImageProvider,
        child: MyApp(isLoggedIn: isLoggedIn),
      ),
    );
  } catch (e) {
    print('Error initializing Hive or opening boxes: $e');
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('An error occurred while initializing the app.'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invento App',
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: const Color(0xFF023E8A), // Dark blue
          primaryContainer: const Color(0xFF0077B6), // Medium blue
          secondary: const Color(0xFF90E0EF), // Light blue
          secondaryContainer: const Color(0xFFCAF0F8), // Pale blue
          surface: Colors.white, // Surface color for cards, buttons, etc.
          background:
              const Color.fromARGB(238, 224, 224, 224), // Light gray background
          error: Colors.red, // Default error color
          onPrimary: Colors.white, // Color for text/icons on primary color
          onSecondary: Colors.black, // Color for text/icons on secondary color
          onSurface: Colors.black, // Color for text/icons on surface
          onBackground: Colors.black, // Color for text/icons on background
          onError: Colors.white, // Color for text/icons on error
          brightness: Brightness.light, // Light theme
        ),
        scaffoldBackgroundColor:
            const Color(0xFFF5F5F5), // Light gray background color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF023E8A), // Dark blue for the app bar
          foregroundColor: Colors.white, // White color for text in app bar
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(
              255, 24, 9, 112), // Light green for bottom navigation bar
          selectedItemColor: Colors.white, // White color for selected items
          unselectedItemColor: Color.fromARGB(
              255, 206, 203, 17), // Dark green for unselected items
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
              fontSize: 16, color: Colors.black), // Dark text for readability
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        useMaterial3: true, // Enables Material 3 design
      ),
      initialRoute: isLoggedIn ? '/bottomNavigation' : '/login',
      routes: {
        '/': (context) => const BottomNavigationBarscreen(),
        '/login': (context) => const MyLogin(),
        '/bottomNavigation': (context) => const BottomNavigationBarscreen(),
        '/dashboard': (context) => const DashBoardScreen(),
        '/addSales': (context) => const SalesPage(),
        '/salesDashboard': (context) => const SalesDashboard(),
        '/revenueSummary': (context) => const RevenueDashboardPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory App'),
      ),
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Light theme background
      body: const Center(
        child: Text('Welcome to Inventory App',
            style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
