class Budget {
  final String monthYear;
  final String category;
  final double budget;

  Budget({
    required this.monthYear,
    required this.category,
    required this.budget,
  });

  /// Factory constructor to create a Budget from JSON
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      monthYear: json['MonthYear'],
      category: json['Category'],
      budget: (json['Budget'] as num).toDouble(),
    );
  }

  /// Optional helper if you're dealing with a list of budgets
  static List<Budget> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Budget.fromJson(json)).toList();
  }
  Map<String, dynamic> toJson() {
    return {
      'MonthYear': monthYear,
      'Category': category,
      'Budget': budget,
    };
  }
}