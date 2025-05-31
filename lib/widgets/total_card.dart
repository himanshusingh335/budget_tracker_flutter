import 'package:flutter/material.dart';

class TotalCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;

  const TotalCard({
    super.key,
    required this.title,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Show Exp value in red, others as before
    final bool isExp = title.toLowerCase() == 'exp';
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isExp ? Colors.red : (color ?? Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}