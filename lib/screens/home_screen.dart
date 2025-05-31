import 'package:budget_tracker_flutter/screens/budget_set_screen.dart';
import 'package:budget_tracker_flutter/screens/new_transaction_screen.dart';
import 'package:budget_tracker_flutter/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/summary.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/summary_tile.dart';
import '../widgets/total_card.dart';

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
    final Color upstoxPrimary = const Color(0xFF6C47FF);
    final Color upstoxBg = const Color(0xFFF7F8FA);

    return Scaffold(
      backgroundColor: upstoxBg,
      appBar: AppBar(
        title: const Text(
          'Budget Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Ensure white text on purple
          ),
        ),
        backgroundColor: upstoxPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Ensure icons are white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: selectedMonth,
                    underline: Container(),
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: Colors.white,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                    icon: Icon(Icons.keyboard_arrow_down, color: upstoxPrimary),
                    onChanged: (value) {
                      if (value != null) _onDateChanged(value, selectedYear);
                    },
                    items: months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(
                          DateFormat.MMMM().format(DateTime(0, int.parse(month))),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: selectedYear,
                    underline: Container(),
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: Colors.white,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                    icon: Icon(Icons.keyboard_arrow_down, color: upstoxPrimary),
                    onChanged: (value) {
                      if (value != null) _onDateChanged(selectedMonth, value);
                    },
                    items: years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year, style: const TextStyle(fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                  ),
                ],
              ),
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
                      orElse:
                          () => Summary(
                            category: '',
                            expenditure: 0,
                            budget: 0,
                            difference: 0,
                            monthYear: '',
                          ),
                    );
                    final totalDiffColor =
                        totalSummary.difference < 0 ? Colors.red : Colors.green;

                    return RefreshIndicator(
                      color: upstoxPrimary,
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
                                color: Colors.grey[900],
                                accent: upstoxPrimary,
                              ),
                              TotalCard(
                                title: 'Exp',
                                value: '₹ ${totalSummary.expenditure.toStringAsFixed(2)}',
                                color: Colors.red[600],
                                accent: upstoxPrimary,
                              ),
                              TotalCard(
                                title: 'Dif',
                                value: '₹ ${totalSummary.difference.toStringAsFixed(2)}',
                                color: totalDiffColor,
                                accent: upstoxPrimary,
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
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: upstoxPrimary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 220,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: snapshot.data!
                                    .where((summary) => summary.category.isNotEmpty)
                                    .map((summary) {
                                  return Container(
                                    width: 200,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: SummaryCard(
                                      summary: summary,
                                      accent: upstoxPrimary,
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
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: upstoxPrimary,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: transactions.isEmpty
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
        backgroundColor: upstoxPrimary,
        foregroundColor: Colors.white, // White icon
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.add, color: Colors.white),
                      tileColor: upstoxPrimary,
                      title: const Text(
                        'Add Transaction',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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
                    const SizedBox(height: 2),
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet, color: Colors.white),
                      tileColor: upstoxPrimary,
                      title: const Text(
                        'Set Budget',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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
