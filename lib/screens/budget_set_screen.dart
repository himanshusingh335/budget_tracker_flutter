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
    final data = await ApiService.fetchBudgets(selectedMonth, selectedYear);
    setState(() {
      budgets = data;
    });
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
    await ApiService.deleteBudget(budget.monthYear, budget.category);
    _fetchBudgets();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Budget')),
      body: SafeArea(
        child: Padding(
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
                    items: months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(DateFormat.MMMM().format(DateTime(0, int.parse(month)))),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: selectedYear,
                    onChanged: (value) {
                      if (value != null) _onDateChanged(selectedMonth, value);
                    },
                    items: years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Budget',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
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
                      onDismissed: (direction) => _deleteBudget(budget),
                      child: Card(
                        child: ListTile(
                          title: Text(budget.category),
                          trailing: Text('₹ ${budget.budget.toStringAsFixed(2)}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add Budget Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select Category'),
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
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _submitBudget,
                child: const Text('Set Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}