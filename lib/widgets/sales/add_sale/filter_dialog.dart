import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_app_final/model/product_user_model.dart';

class FilterDialog extends StatelessWidget {
  final List<Productmodel> allProducts;
  final double? minPrice;
  final double? maxPrice;
  final Set<String> selectedCategories;
  final Function(double?) onMinPriceChanged;
  final Function(double?) onMaxPriceChanged;
  final Function(Set<String>) onCategoriesChanged;

  const FilterDialog({
    super.key,
    required this.allProducts,
    required this.minPrice,
    required this.maxPrice,
    required this.selectedCategories,
    required this.onMinPriceChanged,
    required this.onMaxPriceChanged,
    required this.onCategoriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final uniqueCategories =
        allProducts.map((product) => product.category).toSet().toList();

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Apply Filters',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    onMinPriceChanged(null);
                    onMaxPriceChanged(null);
                    onCategoriesChanged({});
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'Clear Filters',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      onMinPriceChanged(double.tryParse(value));
                    },
                    decoration: InputDecoration(
                      labelText: 'Min Price',
                      labelStyle: GoogleFonts.poppins(),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (value) {
                      onMaxPriceChanged(double.tryParse(value));
                    },
                    decoration: InputDecoration(
                      labelText: 'Max Price',
                      labelStyle: GoogleFonts.poppins(),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Select Categories:',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: ListView(
                      shrinkWrap: true,
                      children: uniqueCategories.map((category) {
                        return CheckboxListTile(
                          title: Text(category, style: GoogleFonts.poppins()),
                          value: selectedCategories.contains(category),
                          onChanged: (isChecked) {
                            setState(() {
                              if (isChecked == true) {
                                selectedCategories.add(category);
                              } else {
                                selectedCategories.remove(category);
                              }
                              onCategoriesChanged(selectedCategories);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Apply', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }
}
