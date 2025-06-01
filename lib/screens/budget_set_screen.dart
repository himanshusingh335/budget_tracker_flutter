import 'package:budget_tracker_flutter/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';

class SetBudgetScreen extends StatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final _amountController = TextEditingController();
  String? _selectedCategory;
  List<Budget> budgets = [];
  String? _fetchError; // <-- Add this line

  final List<String> categories = [
    'Auto',
    'Entertainment',
    'Food',
    'Home',
    'Medical',
    'Personal Items',
    'Travel',
    'Utilities',
    'Other'
  ];

  late String selectedMonth;
  late String selectedYear;

  final List<String> months = List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
  final List<String> years = List.generate(5, (i) => (DateTime.now().year - i).toString());

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month.toString().padLeft(2, '0');
    selectedYear = now.year.toString();
    _fetchBudgets();
  }

  Future<void> _fetchBudgets() async {
    try {
      final data = await ApiService.fetchBudgets(selectedMonth, selectedYear)
          .timeout(const Duration(seconds: 8), onTimeout: () {
        throw Exception('Request timed out. Please check your connection.');
      });
      setState(() {
        budgets = data;
        _fetchError = null; // clear error on success
      });
    } catch (e) {
      setState(() {
        budgets = [];
        _fetchError = 'Failed to load budgets: $e';
      });
    }
  }

  void _onDateChanged(String month, String year) {
    setState(() {
      selectedMonth = month;
      selectedYear = year;
    });
    _fetchBudgets();
  }

  Future<void> _submitBudget() async {
    if (_selectedCategory == null || _amountController.text.isEmpty) return;

    try {
      final budget = Budget(
        category: _selectedCategory!,
        budget: double.parse(_amountController.text.trim()),
        monthYear: '$selectedMonth/${selectedYear.substring(2)}',
      );

      await ApiService.addBudget(budget);
      _amountController.clear();
      setState(() => _selectedCategory = null);
      await _fetchBudgets();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget set successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set budget: $e')),
      );
    }
  }

  Future<void> _deleteBudget(Budget budget) async {
    try {
      await ApiService.deleteBudget(budget.monthYear, budget.category);
      await _fetchBudgets();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete budget')),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color upstoxPrimary = const Color(0xFF6C47FF);
    final Color upstoxBg = const Color(0xFFF7F8FA);

    Widget dropdownRow = Container(
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
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
            icon: Icon(Icons.keyboard_arrow_down, color: upstoxPrimary),
            onChanged: (value) {
              if (value != null) _onDateChanged(value, selectedYear);
            },
            items: months.map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(DateFormat.MMMM().format(DateTime(0, int.parse(month))),
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
    );

    return Scaffold(
      backgroundColor: upstoxBg,
      appBar: AppBar(
        title: const Text(
          'Set Budget',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: upstoxPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              dropdownRow,
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Budget',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: upstoxPrimary),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _fetchError != null
                    ? RefreshIndicator(
                        color: upstoxPrimary,
                        onRefresh: _fetchBudgets,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  _fetchError!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: budgets.length,
                        itemBuilder: (context, index) {
                          final budget = budgets[index];
                          return Dismissible(
                            key: Key('${budget.monthYear}-${budget.category}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              setState(() {
                                budgets.removeAt(index);
                              });
                              _deleteBudget(budget);
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              child: ListTile(
                                title: Text(
                                  budget.category,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                trailing: Text(
                                  '₹ ${budget.budget.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: upstoxPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add Budget Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: upstoxPrimary),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select Category'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: categories
                    .where((cat) => !budgets.any((b) => b.category == cat))
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: upstoxPrimary,
                    foregroundColor: Colors.white, // White text
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _submitBudget,
                  child: const Text(
                    'Set Budget',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}