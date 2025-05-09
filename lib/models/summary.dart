class Summary {
  final double budget;
  final String category;
  final double difference;
  final double expenditure;
  final String monthYear;

  Summary({
    required this.budget,
    required this.category,
    required this.difference,
    required this.expenditure,
    required this.monthYear,
  });

  /// Parses currency string like "₹ 1,500.00" to 1500.0
  static double _parseCurrency(String currency) {
    return double.tryParse(
      currency.replaceAll(RegExp(r'[₹, ]'), '')
    ) ?? 0.0;
  }

  /// Factory to create a Summary object from JSON
  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      budget: _parseCurrency(json['Budget']),
      category: json['Category'],
      difference: _parseCurrency(json['Difference']),
      expenditure: _parseCurrency(json['Expenditure']),
      monthYear: json['MonthYear'],
    );
  }

  /// Helper to convert a list of JSON maps to a list of Summary objects
  static List<Summary> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Summary.fromJson(json)).toList();
  }
}