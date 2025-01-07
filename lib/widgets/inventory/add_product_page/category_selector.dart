// category_selector.dart
// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;

  const CategorySelector(
      {super.key, required this.categories, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectCategory(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: const ListTile(
          title: Text('Category'),
          subtitle: Text('Tap to select a category'),
          trailing: Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }

  Future<void> _selectCategory(BuildContext context) async {
    final selectedCategory = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: Column(
            children: [
              ...categories.map((category) {
                return ListTile(
                  title: Text(category),
                  onTap: () {
                    Navigator.pop(context, category);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
    if (selectedCategory != null) {
      onCategorySelected(selectedCategory);
    }
  }
}
