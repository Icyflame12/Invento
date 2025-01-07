import 'package:flutter/material.dart';

class StockFilter extends StatefulWidget {
  final Function(List<String>) onStockStatusChanged;
  final List<String> initialSelectedStockStatuses;

  const StockFilter({
    super.key,
    required this.onStockStatusChanged,
    required this.initialSelectedStockStatuses,
  });

  @override
  _StockFilterState createState() => _StockFilterState();
}

class _StockFilterState extends State<StockFilter> {
  final List<bool> _stockSelections = [false, false, false];
  final List<String> stockOptions = [
    'In Stock',
    'Out of Stock',
    'Low in Stock'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize selections based on previously selected stock statuses
    for (int i = 0; i < stockOptions.length; i++) {
      _stockSelections[i] =
          widget.initialSelectedStockStatuses.contains(stockOptions[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(stockOptions.length, (index) {
        return CheckboxListTile(
          title: Text(stockOptions[index]),
          value: _stockSelections[index],
          onChanged: (bool? value) {
            setState(() {
              _stockSelections[index] = value!;
              widget.onStockStatusChanged(_getSelectedStockStatuses());
            });
          },
        );
      }),
    );
  }

  List<String> _getSelectedStockStatuses() {
    return [
      for (int i = 0; i < stockOptions.length; i++)
        if (_stockSelections[i]) stockOptions[i]
    ];
  }
}
