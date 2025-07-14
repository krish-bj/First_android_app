import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class AddExpenseForm extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseForm({super.key, this.expenseToEdit});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedCategory = "General";

  final List<String> categories = [
    "Food",
    "Transport",
    "Entertainment",
    "Shopping",
    "General",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      _titleController.text = widget.expenseToEdit!.title;
      _amountController.text = widget.expenseToEdit!.amount.toString();
      _selectedCategory = widget.expenseToEdit!.category;
      _selectedDate = widget.expenseToEdit!.date;
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final updatedExpense = Expense(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate!,
      );

      if (widget.expenseToEdit != null) {
        widget.expenseToEdit!
          ..title = updatedExpense.title
          ..amount = updatedExpense.amount
          ..category = updatedExpense.category
          ..date = updatedExpense.date
          ..save();
      } else {
        Hive.box<Expense>('expenses').add(updatedExpense);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 12,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter a title' : null,
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (val) =>
                  val == null || double.tryParse(val) == null
                      ? 'Enter valid amount'
                      : null,
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories
                  .map((cat) =>
                      DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() {
                _selectedCategory = val!;
              }),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? 'No Date Chosen!'
                      : DateFormat.yMMMd().format(_selectedDate!),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: const Text('Choose Date'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add Expense'),
            )
          ],
        ),
      ),
    );
  }
}
