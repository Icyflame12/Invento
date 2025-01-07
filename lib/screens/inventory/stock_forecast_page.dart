import 'package:flutter/material.dart';

class StockForecastPage extends StatelessWidget {
  const StockForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Forecast'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: theme.textTheme.titleLarge?.color,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Center(
        child: Text(
          'Here you can analyze stock trends for better planning.',
          style: TextStyle(
            fontSize: 18,
            color: theme.textTheme.bodyLarge?.color, // Adapts to theme
          ),
        ),
      ),
    );
  }
}
