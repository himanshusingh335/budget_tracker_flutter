import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction txn;

  const TransactionTile({super.key, required this.txn});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(
          txn.category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(txn.description),
        trailing: Text(
          '₹ ${txn.expenditure.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}