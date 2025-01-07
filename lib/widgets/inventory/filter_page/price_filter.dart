import 'package:flutter/material.dart';

class PriceFilter extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onPriceRangesChanged;
  final List<Map<String, dynamic>> initialSelectedPriceRanges;

  const PriceFilter({
    super.key,
    required this.onPriceRangesChanged,
    required this.initialSelectedPriceRanges,
  });

  @override
  _PriceFilterState createState() => _PriceFilterState();
}

class _PriceFilterState extends State<PriceFilter> {
  final List<bool> _priceSelections = List<bool>.filled(3, false);

  final List<Map<String, dynamic>> priceRanges = [
    {'label': '2000 and below', 'min': 0.0, 'max': 2000.0},
    {'label': '2000-5000', 'min': 2000.0, 'max': 5000.0},
    {'label': '5000 and above', 'min': 5000.0, 'max': double.infinity},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize selections based on previously selected price ranges
    for (int i = 0; i < priceRanges.length; i++) {
      _priceSelections[i] = widget.initialSelectedPriceRanges
          .any((range) => range['label'] == priceRanges[i]['label']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: priceRanges.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            title: Text(priceRanges[index]['label']),
            value: _priceSelections[index],
            onChanged: (bool? value) {
              setState(() {
                _priceSelections[index] = value!;
                widget.onPriceRangesChanged(_getSelectedPriceRanges());
              });
            },
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getSelectedPriceRanges() {
    return [
      for (int i = 0; i < priceRanges.length; i++)
        if (_priceSelections[i]) priceRanges[i]
    ];
  }
}
