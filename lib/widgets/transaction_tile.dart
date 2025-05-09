import 'package:budget_tracker_flutter/services/services.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction txn;
  final VoidCallback? onDeleted;

  const TransactionTile({super.key, required this.txn, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(txn.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        try {
          await ApiService.deleteTransaction(txn.id.toString());
          if (onDeleted != null) onDeleted!();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction deleted successfully')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete transaction')),
            );
          }
        }
      },
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(txn.category, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(txn.date, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          subtitle: Text(txn.description),
          trailing: Text(
            '₹ ${txn.expenditure.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
          ),
        ),
      ),
    );
  }
}