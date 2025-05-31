import 'package:flutter/material.dart';
import '../models/summary.dart';

class SummaryTile extends StatelessWidget {
  final Summary summary;
  final Color? accent;

  const SummaryTile({super.key, required this.summary, this.accent});

  @override
  Widget build(BuildContext context) {
    return SummaryCard(summary: summary, accent: accent);
  }
}

class SummaryCard extends StatelessWidget {
  final Summary summary;
  final Color? accent;

  const SummaryCard({super.key, required this.summary, this.accent});

  @override
  Widget build(BuildContext context) {
    final diffColor = summary.difference < 0
        ? Colors.red[600]
        : Colors.green[600];
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      shadowColor: accent?.withOpacity(0.12) ?? Colors.black12,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                summary.category,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: accent ?? const Color(0xFF6C47FF),
                  letterSpacing: 0.2,
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
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '₹ ${summary.budget.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '₹ ${summary.expenditure.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
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
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      fontSize: 15,
                    ),
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