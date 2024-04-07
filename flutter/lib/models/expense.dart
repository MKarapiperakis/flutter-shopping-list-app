import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

const uuid = Uuid();

class Product {
  final String id;
  String name;
  double price;
  int quantity;
  final Function()? onQuantityChanged;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.onQuantityChanged,
  });

  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
    if (onQuantityChanged != null) {
      onQuantityChanged!();
    }
  }
}

class Expense {
  Expense({
    this.id,
    required this.title,
    required this.date,
    required this.products,
  }) : amount = _calculateTotalAmount(products);

  String? id;
  String title;
  double amount;
  final DateTime date;
  final List<Product> products;

  String get formattedDate {
    return formatter.format(date);
  }

  void updateAmount(product) {
    amount = _calculateTotalAmount(product);
  }

  static double _calculateTotalAmount(List<Product> products) {
    double totalAmount = 0;
    for (var product in products) {
      totalAmount += product.price * product.quantity;
    }
    return totalAmount;
  }
}
