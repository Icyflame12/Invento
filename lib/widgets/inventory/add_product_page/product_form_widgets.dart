// product_form_widgets.dart
import 'package:flutter/material.dart';

Widget buildTextField(String label, TextEditingController controller,
    {TextInputType keyboardType = TextInputType.text}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter $label',
        ),
        keyboardType: keyboardType,
      ),
    ),
  );
}

Widget buildCategorySelector(
    BuildContext context, String selectedCategory, Function selectCategory) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    child: ListTile(
      title: const Text('Category'),
      subtitle:
          Text(selectedCategory.isEmpty ? 'Select Category' : selectedCategory),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () => selectCategory(),
    ),
  );
}
