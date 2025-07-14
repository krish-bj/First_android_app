import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../widgets/expense_tile.dart';
import 'package:intl/intl.dart';
import '../screens/add_expense_form.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = "All";

  final List<String> _categories = [
    "All",
    "Food",
    "Transport",
    "Entertainment",
    "Shopping",
    "General",
  ];

  void _showAddExpenseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddExpenseForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseBox = Hive.box<Expense>('expenses');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: expenseBox.listenable(),
        builder: (context, Box<Expense> box, _) {
          final allExpenses = box.values.toList();

          final filteredExpenses = _selectedCategory == "All"
              ? allExpenses
              : allExpenses
                  .where((e) => e.category == _selectedCategory)
                  .toList();

          final total = filteredExpenses.fold<double>(
            0,
            (sum, item) => sum + item.amount,
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Total Summary
                Card(
                  elevation: 4,
                  child: ListTile(
                    title: const Text("Total Spent"),
                    subtitle: Text(
                      "₹ ${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Category Filter Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val!;
                    });
                  },
                  decoration:
                      const InputDecoration(labelText: 'Filter by Category'),
                ),

                const SizedBox(height: 10),

                // Expense List
                Expanded(
                  child: filteredExpenses.isEmpty
                      ? const Center(child: Text("No expenses yet."))
                      : ListView.builder(
                          itemCount: filteredExpenses.length,
                          itemBuilder: (context, index) {
                            return ExpenseTile(
                              expense: filteredExpenses[index],
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
