import 'package:flutter/material.dart';

class SlowMovingItemsPage extends StatelessWidget {
  const SlowMovingItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slow-Moving Items'),
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
          'Here you can identify items with low sales velocity.',
          style: TextStyle(
            fontSize: 18,
            color: theme.textTheme.bodyLarge?.color, // Adapts to theme
          ),
        ),
      ),
    );
  }
}
