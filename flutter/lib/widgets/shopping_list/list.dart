import 'package:flutter/material.dart';

import 'package:chat_app/widgets/shopping_list/list_item.dart';
import 'package:chat_app/models/expense.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList(
      {super.key,
      required this.expenses,
      required this.onRemoveExpense,
      required this.onSelectItem});

  final List<Expense> expenses;
  final void Function(Expense expense) onRemoveExpense;
  final void Function(Expense expense) onSelectItem;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) => Dismissible(
        key: ValueKey(expenses[index]),
        background: Container(
          color: Colors.red.shade400,
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
        ),
        onDismissed: (direction) {
          onRemoveExpense(expenses[index]);
        },
        child: ExpenseItem(
          expenses[index],
          onSelectItem: onSelectItem,
        ),
      ),
    );
  }
}
