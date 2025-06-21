import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DropdownMonthYear extends StatelessWidget {
  final String selectedMonth;
  final String selectedYear;
  final List<String> months;
  final List<String> years;
  final void Function(String month, String year) onChanged;
  final Color? primaryColor;

  const DropdownMonthYear({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.months,
    required this.years,
    required this.onChanged,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color upstoxPrimary = primaryColor ?? const Color(0xFF6C47FF);

    return Container(
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
              if (value != null) onChanged(value, selectedYear);
            },
            items: months.map((month) {
              return DropdownMenuItem(
                value: month,
                child: Text(
                  DateFormat.MMMM().format(DateTime(0, int.parse(month))),
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
              if (value != null) onChanged(selectedMonth, value);
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
  }
}
