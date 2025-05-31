import 'package:flutter/material.dart';
import '../models/summary.dart';

class SummaryTile extends StatelessWidget {
  final Summary summary;

  const SummaryTile({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return SummaryCard(summary: summary);
  }
}

class SummaryCard extends StatelessWidget {
  final Summary summary;

  const SummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final diffColor = summary.difference < 0 ? Colors.red : Colors.green;
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                summary.category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bud',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
                  ),
                  Text(
                    '₹ ${summary.budget.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 17),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exp',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
                  ),
                  Text(
                    '₹ ${summary.expenditure.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.red,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dif',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
                  ),
                  Text(
                    '₹ ${summary.difference.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 17,
                      color: diffColor,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}