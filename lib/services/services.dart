import 'dart:convert';
import 'package:budget_tracker_flutter/models/budget.dart';
import 'package:budget_tracker_flutter/models/summary.dart';
import 'package:budget_tracker_flutter/models/transaction.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://100.127.54.94:8502/';

  // ==================== SUMMARY ====================
  static Future<List<Summary>> fetchSummary(String month, String year) async {
    final url = Uri.parse('$baseUrl/summary/$month/$year');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((jsonItem) => Summary.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Failed to load summary');
    }
  }

  // ==================== TRANSACTIONS ====================
  static Future<List<Transaction>> fetchTransactions(String month, String year) async {
    final url = Uri.parse('$baseUrl/transactions/$month/$year');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((jsonItem) => Transaction.fromJson(jsonItem)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  static Future<void> addTransaction(Transaction txn) async {
    final url = Uri.parse('$baseUrl/transactions');

    final Map<String, dynamic> requestBody = {
      'Date': txn.date,
      'Description': txn.description,
      'Category': txn.category,
      'Expenditure': txn.expenditure,
      'Year': txn.year,
      'Month': txn.month,
      'Day': txn.day,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add transaction');
    }
  }

  static Future<void> deleteTransaction(String id) async {
    final url = Uri.parse('$baseUrl/transactions/$id');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Failed to delete transaction');
    }
  }

  // ==================== BUDGET ====================
  static Future<List<Budget>> fetchBudgets(String month, String year) async {
    final url = Uri.parse('$baseUrl/budget/$month/$year');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return Budget.fromJsonList(jsonData);
    } else {
      throw Exception('Failed to load budgets');
    }
  }

  static Future<void> addBudget(Budget budget) async {
    final url = Uri.parse('$baseUrl/budget');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(budget.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add budget');
    }
  }

  static Future<void> deleteBudget(String monthYear, String category) async {
    final url = Uri.parse('$baseUrl/budget');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'MonthYear': monthYear, 'Category': category}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete budget');
    }
  }
}