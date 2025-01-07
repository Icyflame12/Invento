import 'package:flutter/material.dart';
import 'dart:io';

class RemindersSection extends StatelessWidget {
  final List<Map<String, dynamic>> reminders;
  final Function(String) onReminderTap;
  final Function(String) onUpdateTap;

  const RemindersSection({
    super.key,
    required this.reminders,
    required this.onReminderTap,
    required this.onUpdateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminders',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (reminders.isEmpty)
          Center(
            child: Text(
              'No Reminders Available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return GestureDetector(
                  onTap: () => onReminderTap(reminder['id'].toString()),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (reminder['imageUrl'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.file(
                                File(reminder['imageUrl']),
                                height: 80,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error,
                                        color: Colors.red, size: 40),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            reminder['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stock: ${reminder['stock']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                          const Spacer(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () =>
                                  onUpdateTap(reminder['id'].toString()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF2C5F2D), // Primary Green
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 4),
                              ),
                              child: const Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color.fromARGB(255, 255, 191, 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
