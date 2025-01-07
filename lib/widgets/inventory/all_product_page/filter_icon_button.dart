import 'package:flutter/material.dart';

class FilterIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FilterIconButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.filter_list),
      onPressed: onPressed,
    );
  }
}
