import 'package:flutter/material.dart';

class TotalCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;
  final Color? accent;

  const TotalCard({
    super.key,
    required this.title,
    required this.value,
    this.color,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExp = title.toLowerCase() == 'exp';
    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 160),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.white,
        shadowColor: (accent != null)
            ? accent!.withAlpha(31) // replaces withOpacity(0.12)
            : Colors.black12,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: accent ?? Colors.deepPurple,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isExp
                          ? Colors.red[600]
                          : (color ?? Colors.black),
                      letterSpacing: 0.2,
                    ),
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