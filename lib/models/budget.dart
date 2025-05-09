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
  factory Budget.fromJson(Map<String, dynamic> json, String monthYear) {
    return Budget(
      monthYear: monthYear,
      category: json['Category'],
      budget: (json['Budget'] as num).toDouble(),
    );
  }

  /// Optional helper if you're dealing with a list of budgets
  static List<Budget> fromJsonList(Map<String, dynamic> json) {
    final String monthYear = json['MonthYear'];
    final List<dynamic> budgets = json['Budgets'];
    return budgets.map((b) => Budget.fromJson(b, monthYear)).toList();
  }
  Map<String, dynamic> toJson() {
    return {
      'MonthYear': monthYear,
      'Category': category,
      'Budget': budget,
    };
  }
}