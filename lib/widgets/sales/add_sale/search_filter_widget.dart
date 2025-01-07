import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final Function showFilterDialog;

  const SearchFilterWidget({
    required this.searchController,
    required this.onSearchChanged,
    required this.showFilterDialog,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: 'Search Products',
          labelStyle: GoogleFonts.poppins(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => showFilterDialog(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}
