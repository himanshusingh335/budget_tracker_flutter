import 'package:budget_tracker_flutter/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/summary.dart';
import '../models/transaction.dart';
import '../widgets/total_card.dart';
import '../widgets/summary_tile.dart';
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

  void _fetchData() {
    summaryFuture = ApiService.fetchSummary(selectedMonth, selectedYear);
    transactionFuture = ApiService.fetchTransactions(
      selectedMonth,
      selectedYear,
    );
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No summary available.'));
                  } else {
                    final totalSummary = snapshot.data!.firstWhere(
                      (s) => s.category.isEmpty,
                      orElse:
                          () => Summary(
                            category: '',
                            expenditure: 0,
                            budget: 0,
                            difference: 0,
                            monthYear: '',
                          ),
                    );
                    final totalDiffValue = totalSummary.difference;
                    final totalDiffColor =
                        totalDiffValue < 0 ? Colors.red : Colors.green;

                    return Column(
                      children: [
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TotalCard(
                              title: 'Expenditure',
                              value:
                                  '₹ ${totalSummary.expenditure.toStringAsFixed(2)}',
                            ),
                            TotalCard(
                              title: 'Budget',
                              value:
                                  '₹ ${totalSummary.budget.toStringAsFixed(2)}',
                            ),
                            TotalCard(
                              title: 'Difference',
                              value:
                                  '₹ ${totalSummary.difference.toStringAsFixed(2)}',
                              color: totalDiffColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          flex: 1,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final summary = snapshot.data![index];
                              if (summary.category.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return SummaryTile(summary: summary);
                            },
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
                          child: FutureBuilder<List<Transaction>>(
                            future: transactionFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                  child: Text('No transactions found.'),
                                );
                              } else {
                                return ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    final txn = snapshot.data![index];
                                    return TransactionTile(txn: txn);
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
