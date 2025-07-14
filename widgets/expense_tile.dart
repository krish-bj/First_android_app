import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../screens/home_screen.dart';
import '../screens/add_expense_form.dart';
 // to show the edit form

class ExpenseTile extends StatelessWidget {
  final Expense expense;

  const ExpenseTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.key.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Expense"),
            content:
                const Text("Are you sure you want to delete this expense?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Delete"),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        expense.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Expense deleted")),
        );
      },
      child: ListTile(
        title: Text(expense.title),
        subtitle: Text(
          "${expense.category} • ${DateFormat.yMMMd().format(expense.date)}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "₹ ${expense.amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AddExpenseForm(expenseToEdit: expense),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
