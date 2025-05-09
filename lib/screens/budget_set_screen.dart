import 'package:flutter/material.dart';

class SetBudgetScreen extends StatelessWidget {
  const SetBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Budget')),
      body: const Center(child: Text('Set Budget Screen')),
    );
  }
}