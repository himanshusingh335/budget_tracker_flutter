import 'package:budget_tracker_flutter/screens/budget_set_screen.dart';
import 'package:budget_tracker_flutter/screens/new_transaction_screen.dart';
import 'package:budget_tracker_flutter/screens/transaction_screen.dart';
import 'package:budget_tracker_flutter/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/summary.dart';
import '../models/transaction.dart';
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
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Ensure icons are white
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RefreshIndicator(
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
                          color: Colors.black.withAlpha(10), // replaces withOpacity(0.04)
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
                          items:
                              months.map((month) {
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
                          items:
                              years.map((year) {
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
                  FutureBuilder<List<Summary>>(
                    future: summaryFuture,
                    builder: (context, snapshot) {
                      if (fetchError != null) {
                        return SizedBox(
                          height: 400,
                          child: Center(
                            child: Text(
                              fetchError!,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return SizedBox(
                          height: 400,
                          child: Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No summary available.'));
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

                        return Column(
                          children: [
                            // 1. TotalCard tiles in a horizontally scrollable row, dynamic width, 1 decimal
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
                            SizedBox(
                              height: 260, // Increased height for bar chart to avoid overflow
                              child: summaries.where((s) => s.category.isNotEmpty).isEmpty
                                  ? const Center(child: Text('No data for chart'))
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        width: (summaries.where((s) => s.category.isNotEmpty).length * 48).toDouble().clamp(320, double.infinity),
                                        child: BarChart(
                                          BarChartData(
                                            alignment: BarChartAlignment.spaceAround,
                                            barTouchData: BarTouchData(enabled: false),
                                            titlesData: FlTitlesData(
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 44,
                                                  interval: _getYAxisInterval(summaries),
                                                  getTitlesWidget: (value, meta) {
                                                    if (value % _getYAxisInterval(summaries) != 0) return const SizedBox.shrink();
                                                    return Padding(
                                                      padding: const EdgeInsets.only(right: 4.0),
                                                      child: Text(
                                                        value.toInt().toString(),
                                                        style: const TextStyle(fontSize: 11),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (double value, TitleMeta meta) {
                                                    final idx = value.toInt();
                                                    final cats = summaries.where((s) => s.category.isNotEmpty).toList();
                                                    if (idx < 0 || idx >= cats.length) return const SizedBox.shrink();
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: Text(
                                                        cats[idx].category.length > 7
                                                            ? '${cats[idx].category.substring(0, 7)}…'
                                                            : cats[idx].category,
                                                        style: const TextStyle(fontSize: 11),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    );
                                                  },
                                                  reservedSize: 48,
                                                ),
                                              ),
                                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            ),
                                            borderData: FlBorderData(show: false),
                                            gridData: FlGridData(show: true, horizontalInterval: _getYAxisInterval(summaries)),
                                            barGroups: [
                                              for (final entry in summaries
                                                  .where((s) => s.category.isNotEmpty)
                                                  .toList()
                                                  .asMap()
                                                  .entries)
                                                BarChartGroupData(
                                                  x: entry.key,
                                                  barRods: [
                                                    BarChartRodData(
                                                      toY: entry.value.budget,
                                                      color: upstoxPrimary,
                                                      width: 12,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    BarChartRodData(
                                                      toY: entry.value.expenditure,
                                                      color: Colors.red[400],
                                                      width: 12,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                            groupsSpace: 18,
                                            maxY: _getMaxY(summaries),
                                          ),
                                        ),
                                      ),
                                    ),
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
                        );
                      }
                    },
                  ),
                  // ...no Expanded here, everything is scrollable...
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: upstoxPrimary,
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
                      tileColor: upstoxPrimary,
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
                      tileColor: upstoxPrimary,
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

  double _getMaxY(List<Summary> summaries) {
    final maxVal = summaries
        .where((s) => s.category.isNotEmpty)
        .expand((s) => [s.budget, s.expenditure])
        .fold<double>(0, (prev, el) => el > prev ? el : prev);
    // Round up to nearest 1000 for a cleaner axis
    return (maxVal / 1000.0).ceil() * 1000.0 + 1000;
  }

  double _getYAxisInterval(List<Summary> summaries) {
    final maxY = _getMaxY(summaries);
    if (maxY <= 2000) return 500;
    if (maxY <= 5000) return 1000;
    if (maxY <= 10000) return 2000;
    return 5000;
  }
}
