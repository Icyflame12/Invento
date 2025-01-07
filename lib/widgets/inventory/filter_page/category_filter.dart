import 'package:flutter/material.dart';

class CategoryFilter extends StatefulWidget {
  final List<String> categories;
  final Function(List<String>) onSelectedCategoriesChanged;
  final List<String> initialSelectedCategories;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.onSelectedCategoriesChanged,
    required this.initialSelectedCategories,
  });

  @override
  _CategoryFilterState createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  late List<bool> _categorySelections;

  @override
  void initState() {
    super.initState();
    _categorySelections = List<bool>.filled(widget.categories.length, false);
    // Initialize with previously selected categories
    for (int i = 0; i < widget.categories.length; i++) {
      _categorySelections[i] =
          widget.initialSelectedCategories.contains(widget.categories[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(widget.categories[index]),
            value: _categorySelections[index],
            onChanged: (bool? value) {
              setState(() {
                _categorySelections[index] = value!;
                widget.onSelectedCategoriesChanged(_getSelectedCategories());
              });
            },
          );
        },
      ),
    );
  }

  List<String> _getSelectedCategories() {
    return [
      for (int i = 0; i < widget.categories.length; i++)
        if (_categorySelections[i]) widget.categories[i]
    ];
  }
}
