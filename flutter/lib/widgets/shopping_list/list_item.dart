import 'package:flutter/material.dart';
import 'package:chat_app/models/expense.dart';

class ExpenseItem extends StatelessWidget {
  const ExpenseItem(this.expense, {super.key, required this.onSelectItem});

  final Expense expense;
  final void Function(Expense expense) onSelectItem;

  @override
  Widget build(BuildContext context) {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);

    Color getCardColor() {
      if (expense.date.isBefore(date)) {
        return Colors.red.shade400;
      } else {
        return Theme.of(context).cardColor;
      }
    }

    Color getTextColor() {
      if (expense.date.isBefore(date)) {
        return Theme.of(context).cardColor;
      } else {
        return Colors.black87;
      }
    }

    bool isDatePast = expense.date.isBefore(date);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 11,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        color: getCardColor(),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                onSelectItem(expense);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: getTextColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\€${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: getTextColor(),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          expense.formattedDate,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: getTextColor(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isDatePast)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  size: 19,
                  Icons.access_time,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
