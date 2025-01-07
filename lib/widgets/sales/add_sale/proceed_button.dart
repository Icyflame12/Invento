import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProceedButton extends StatelessWidget {
  final Future<void> Function() proceedToCustomerDetails;

  const ProceedButton({
    required this.proceedToCustomerDetails,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: proceedToCustomerDetails,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 201, 201, 199),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Proceed to Customer Details',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
