import 'package:budget_tracker_flutter/screens/budget_set_screen.dart';
import 'package:budget_tracker_flutter/screens/new_transaction_screen.dart';
import 'package:budget_tracker_flutter/screens/transaction_screen.dart';
import 'package:budget_tracker_flutter/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/summary.dart';
import '../models/transaction.dart';
import '../widgets/summary_tile.dart';
import '../widgets/total_card.dart';
import '../widgets/bar_chart.dart';

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
      ).timeout(const Duration(seconds: 8), onTimeout: () {
        throw Exception('Request timed out. Please check your connection.');
      });
      if (!mounted) return;
      setState(() {
        transactions = fetchedTransactions;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        fetchError = 'Failed to load data: $e';
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
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Budget Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Ensure white text on purple
          ),
        ),
        backgroundColor: const Color(0xFF6C47FF),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Ensure icons are white
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Summary>>(
            future: summaryFuture,
            builder: (context, snapshot) {
              final Color upstoxPrimary = const Color(0xFF6C47FF);
              if (fetchError != null) {
                return RefreshIndicator(
                  color: upstoxPrimary,
                  onRefresh: _fetchData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 400,
                        child: Center(
                          child: Text(
                            fetchError!,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return RefreshIndicator(
                  color: upstoxPrimary,
                  onRefresh: _fetchData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 400,
                        child: Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return RefreshIndicator(
                  color: upstoxPrimary,
                  onRefresh: _fetchData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 400,
                        child: Center(
                          child: Text('No summary available.'),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                final summaries = snapshot.data!;
                final totalSummary = summaries.firstWhere(
                  (s) => s.category.isEmpty,
                  orElse: () => Summary(
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
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                icon: Icon(Icons.keyboard_arrow_down, color: upstoxPrimary),
                                onChanged: (value) {
                                  if (value != null) _onDateChanged(value, selectedYear);
                                },
                                items: months.map((month) {
                                  return DropdownMenuItem(
                                    value: month,
                                    child: Text(
                                      DateFormat.MMMM().format(
                                        DateTime(0, int.parse(month)),
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                icon: Icon(Icons.keyboard_arrow_down, color: upstoxPrimary),
                                onChanged: (value) {
                                  if (value != null) _onDateChanged(selectedMonth, value);
                                },
                                items: years.map((year) {
                                  return DropdownMenuItem(
                                    value: year,
                                    child: Text(
                                      year,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Show all cards in a row if enough space, else make scrollable
                            final cardCount = 3;
                            final minCardWidth = 120.0;
                            final spacing = 16.0;
                            final totalMinWidth = cardCount * minCardWidth + (cardCount - 1) * spacing;
                            final showScrollable = constraints.maxWidth < totalMinWidth;

                            final cards = [
                              TotalCard(
                                title: 'Bud',
                                value: '₹ ${totalSummary.budget.toStringAsFixed(1)}',
                                color: Colors.grey[900],
                                accent: upstoxPrimary,
                              ),
                              TotalCard(
                                title: 'Exp',
                                value: '₹ ${totalSummary.expenditure.toStringAsFixed(1)}',
                                color: Colors.red[600],
                                accent: upstoxPrimary,
                              ),
                              TotalCard(
                                title: 'Dif',
                                value: '₹ ${totalSummary.difference.toStringAsFixed(1)}',
                                color: totalDiffColor,
                                accent: upstoxPrimary,
                              ),
                            ];

                            if (showScrollable) {
                              return SizedBox(
                                height: 110,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: cards.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                                  itemBuilder: (context, i) => cards[i],
                                ),
                              );
                            } else {
                              return SizedBox(
                                height: 110,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: cards
                                      .map((card) => Expanded(child: card))
                                      .toList(),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // 2. Summary title
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
                        // 3. Bar chart (no title)
                        SummaryBarChart(
                          summaries: summaries,
                          accent: upstoxPrimary,
                        ),
                        const SizedBox(height: 24),
                        // 4. Summary tiles
                        SizedBox(
                          height: 220,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: summaries
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
                        const SizedBox(height: 18),
                        // 5. Transactions button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: upstoxPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.list_alt),
                            label: const Text(
                              'View Transactions',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TransactionScreen(),
                                  settings: RouteSettings(
                                    arguments: {
                                      'selectedMonth': selectedMonth,
                                      'selectedYear': selectedYear,
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C47FF),
        foregroundColor: Colors.white,
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
                      tileColor: const Color(0xFF6C47FF),
                      title: const Text(
                        'Add Transaction',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                      leading: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                      ),
                      tileColor: const Color(0xFF6C47FF),
                      title: const Text(
                        'Set Budget',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
