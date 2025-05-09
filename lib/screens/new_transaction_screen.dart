import 'package:budget_tracker_flutter/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _expController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedCategory;

  final List<String> _categories = [
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final txn = Transaction(
        id: 0, // not used for POST
        date: DateFormat('dd/MM/yy').format(_selectedDate!),
        day: _selectedDate!.day,
        description: _descController.text.trim(),
        expenditure: double.parse(_expController.text.trim()),
        month: _selectedDate!.month,
        year: _selectedDate!.year,
        category: _selectedCategory!,
      );

      await ApiService.addTransaction(txn);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully')),
      );

      setState(() {
        _selectedDate = null;
        _selectedCategory = null;
        _descController.clear();
        _expController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add transaction: $e')),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _expController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _expController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Expenditure'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter amount';
                  final num? amount = num.tryParse(value);
                  return (amount == null || amount <= 0) ? 'Enter valid amount' : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select Category'),
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) => val == null ? 'Select category' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Pick a Date'
                    : DateFormat('dd MMM yyyy').format(_selectedDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}