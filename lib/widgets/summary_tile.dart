import 'package:flutter/material.dart';
import '../models/summary.dart';

class SummaryTile extends StatelessWidget {
  final Summary summary;

  const SummaryTile({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final diffColor = summary.difference < 0 ? Colors.red : Colors.green;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expenditure: ₹ ${summary.expenditure}'),
                Text('Budget: ₹ ${summary.budget}'),
                Text(
                  'Diff: ₹ ${summary.difference}',
                  style: TextStyle(color: diffColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}