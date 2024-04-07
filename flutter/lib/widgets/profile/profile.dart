import 'package:flutter/material.dart';
import 'package:chat_app/models/expense.dart';
import 'dart:convert';
import 'package:chat_app/api/getShoppingListRequest.dart';
import 'package:fl_chart/fl_chart.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key, required this.userId, required this.token});

  final userId;
  final token;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isLoading = true;
  List<Expense> _registeredExpenses = [];

  @override
  void initState() {
    getShoppingList();
    super.initState();
  }

  void getShoppingList() async {
    setState(() {
      _isLoading = true;
    });

    var response = await GetShoppingListRequest.getShoppingList(
        widget.userId, widget.token);

    var responseData = json.decode(response);

    var shoppingListData = responseData['data']['getShoppingList'];

    List<Expense> updatedExpenses = [];

    for (var item in shoppingListData) {
      List<Product> products = [];
      for (var productData in item['products']) {
        products.add(Product(
          id: productData['product_id'],
          name: productData['product_title'],
          price: productData['price'].toDouble(),
          quantity: productData['quantity'],
        ));
      }
      var epochTime = int.parse(item['date']);

      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochTime);

      dateTime = dateTime.add(Duration(days: 1));

      updatedExpenses.add(Expense(
        id: item["_id"],
        title: item['title'],
        date: dateTime,
        products: products,
      ));
    }

    setState(() {
      _registeredExpenses = updatedExpenses;
      _isLoading = false;
    });
  }

  int calculateTotalAmountLastMonth() {
    DateTime now = DateTime.now();

    DateTime firstDayLastMonth = DateTime(now.year, now.month, 1);

    DateTime lastDayLastMonth = DateTime(now.year, now.month + 1, 0);

    List<Expense> expensesLastMonth = _registeredExpenses
        .where((expense) =>
            expense.date.isAfter(firstDayLastMonth) &&
            expense.date.isBefore(lastDayLastMonth))
        .toList();

    double totalAmount = expensesLastMonth
        .map((expense) => expense.products.fold(
            0.0,
            (previousValue, product) =>
                previousValue + (product.price * product.quantity)))
        .fold(0.0,
            (previousValue, expenseAmount) => previousValue + expenseAmount);
    return totalAmount.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Amount Spent Last Month:',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '\€${calculateTotalAmountLastMonth().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}
