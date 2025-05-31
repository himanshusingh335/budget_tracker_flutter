import 'package:budget_tracker_flutter/screens/budget_set_screen.dart';
import 'package:budget_tracker_flutter/screens/new_transaction_screen.dart';
import 'package:budget_tracker_flutter/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/summary.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String selectedMonth;
  late String selectedYear;
  late Future<List<Summary>> summaryFuture;
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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month.toString().padLeft(2, '0');
    selectedYear = now.year.toString();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      fetchError = null;
      summaryFuture = ApiService.fetchSummary(selectedMonth, selectedYear);
      transactionFuture = ApiService.fetchTransactions(
        selectedMonth,
        selectedYear,
      );
    });

    try {
      final fetchedTransactions = await ApiService.fetchTransactions(
        selectedMonth,
        selectedYear,
      );
      if (!mounted) return;
      setState(() {
        transactions = fetchedTransactions;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        fetchError = 'Failed to load data. Swipe down to retry.';
      });
    }
  }

  void _onDateChanged(String month, String year) {
    setState(() {
      selectedMonth = month;
      selectedYear = year;
      _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedMonth,
                  onChanged: (value) {
                    if (value != null) _onDateChanged(value, selectedYear);
                  },
                  items:
                      months.map((month) {
                        return DropdownMenuItem(
                          value: month,
                          child: Text(
                            DateFormat.MMMM().format(
                              DateTime(0, int.parse(month)),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedYear,
                  onChanged: (value) {
                    if (value != null) _onDateChanged(selectedMonth, value);
                  },
                  items:
                      years.map((year) {
                        return DropdownMenuItem(value: year, child: Text(year));
                      }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Summary>>(
                future: summaryFuture,
                builder: (context, snapshot) {
                  if (fetchError != null) {
                    return RefreshIndicator(
                      onRefresh: _fetchData,
                      child: ListView(
                        children: [
                          SizedBox(height: 200),
                          Center(child: Text(fetchError!)),
                        ],
                      ),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No summary available.'));
                  } else {
                    final totalSummary = snapshot.data!.firstWhere(
                      (s) => s.category.isEmpty,
                      orElse: () => Summary(
                        category: '',
                        expenditure: 0,
                        budget: 0,
                        difference: 0,
                        monthYear: '',
                      ),
                    );
                    final totalDiffColor = totalSummary.difference < 0 ? Colors.red : Colors.green;

                    return RefreshIndicator(
                      onRefresh: _fetchData,
                      child: Column(
                        children: [
                          // Add the 3 summary tiles at the top (Bud, Exp, Dif order)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TotalCard(
                                title: 'Bud',
                                value: '₹ ${totalSummary.budget.toStringAsFixed(2)}',
                              ),
                              TotalCard(
                                title: 'Exp',
                                value: '₹ ${totalSummary.expenditure.toStringAsFixed(2)}',
                              ),
                              TotalCard(
                                title: 'Dif',
                                value: '₹ ${totalSummary.difference.toStringAsFixed(2)}',
                                color: totalDiffColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Summary',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 220, // Increased vertical size
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: snapshot.data!
                                    .where((summary) => summary.category.isNotEmpty)
                                    .map((summary) {
                                  final diffColor = summary.difference < 0 ? Colors.red : Colors.green;
                                  return Container(
                                    width: 200, // Increased horizontal size
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Card(
                                      elevation: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                        child: SingleChildScrollView(
                                          // Make card content scrollable if overflow
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              // Category title left aligned
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
                                              // Bud, Exp, Dif and their values side by side
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
                                                      color: Colors.red, // Exp number in red
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
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 16.0,
                              bottom: 8.0,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Transactions',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child:
                                transactions.isEmpty
                                    ? const Center(
                                      child: Text('No transactions found.'),
                                    )
                                    : ListView.builder(
                                      itemCount: transactions.length,
                                      itemBuilder: (context, index) {
                                        final txn = transactions[index];
                                        return TransactionTile(
                                          txn: txn,
                                          onDeleted: () {
                                            setState(() {
                                              transactions.removeWhere(
                                                (t) => t.id == txn.id,
                                              );
                                            });
                                          },
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Add Transaction'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewTransactionScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet),
                      title: const Text('Set Budget'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SetBudgetScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
