import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerButton extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onPressed;

  const DatePickerButton({
    Key? key,
    required this.selectedDate,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Date",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.calendar_today, size: 18),
          label: Text(
            selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                : 'Select Date',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: Color(0xFF435EA6)),
          ),
        ),
      ],
    );
  }
} 