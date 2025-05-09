class Transaction {
  final int id;
  final String category;
  final String date;         // Optionally convert to DateTime
  final int day;
  final String description;
  final double expenditure;
  final int month;
  final int year;

  Transaction({
    required this.id,
    required this.category,
    required this.date,
    required this.day,
    required this.description,
    required this.expenditure,
    required this.month,
    required this.year,
  });

  /// Factory constructor to create a Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      category: json['Category'],
      date: json['Date'],
      day: json['Day'],
      description: json['Description'],
      expenditure: (json['Expenditure'] as num).toDouble(),
      month: json['Month'],
      year: json['Year'],
    );
  }

  /// Converts this Transaction to a JSON-compatible Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Category': category,
      'Date': date,
      'Day': day,
      'Description': description,
      'Expenditure': expenditure,
      'Month': month,
      'Year': year,
    };
  }

  /// Helper to convert a list of JSON maps to a list of Transactions
  static List<Transaction> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Transaction.fromJson(json)).toList();
  }
}