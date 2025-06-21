import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';
import '../services/services.dart';
import '../widgets/dropdown_monthyear.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late String selectedMonth;
  late String selectedYear;
  late Future<List<Transaction>> transactionFuture;
  List<Transaction> transactions = [];
  String? fetchError;

  final List<String> months = List.generate(
    12,
    (i) => (i + 1).toString().padLeft(2, '0'),
  );
  final List<String> years = List.generate(
    5,
    (i) => (DateTime.now().year - i).toString(),
  );

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
      final now = DateTime.now();
      selectedMonth = args?['selectedMonth'] ?? now.month.toString().padLeft(2, '0');
      selectedYear = args?['selectedYear'] ?? now.year.toString();
      _fetchTransactions();
      _initialized = true;
    }
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      fetchError = null;
      transactionFuture = ApiService.fetchTransactions(selectedMonth, selectedYear);
    });

    try {
      final fetchedTransactions = await transactionFuture;
      if (!mounted) return;
      setState(() {
        transactions = fetchedTransactions;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        fetchError = 'Failed to load transactions. Swipe down to retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color upstoxPrimary = const Color(0xFF6C47FF);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: upstoxPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
          color: upstoxPrimary,
          onRefresh: _fetchTransactions,
          child: Column(
            children: [
              // Replace the heading with the dropdown if you want to allow changing month/year
              DropdownMonthYear(
                selectedMonth: selectedMonth,
                selectedYear: selectedYear,
                months: months,
                years: years,
                onChanged: (month, year) {
                  setState(() {
                    selectedMonth = month;
                    selectedYear = year;
                  });
                  _fetchTransactions();
                },
                primaryColor: upstoxPrimary,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Transaction>>(
                  future: transactionFuture,
                  builder: (context, snapshot) {
                    if (fetchError != null) {
                      return Center(
                        child: Text(
                          fetchError!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No transactions found.'));
                    } else {
                      final txns = snapshot.data!;
                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: txns.length,
                        itemBuilder: (context, index) {
                          final txn = txns[index];
                          return TransactionTile(
                            txn: txn,
                            onDeleted: () {
                              setState(() {
                                transactions.removeWhere((t) => t.id == txn.id);
                              });
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
