// ignore_for_file: use_build_context_synchronously

import 'package:chat_app/api/createShoppingListRequest.dart';
import 'package:chat_app/widgets/shopping_list/add_list.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/expense.dart';
import 'package:chat_app/widgets/shopping_list/list.dart';
import 'package:chat_app/screens/detailsPage.dart';
import 'package:chat_app/api/getShoppingListRequest.dart';
import 'dart:convert';
import 'package:chat_app/utils/snackbar.dart';
import 'package:chat_app/api/deleteShoppingListRequest.dart';
import 'package:chat_app/widgets/profile/profile.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen(
      {super.key,
      required this.logout,
      required this.username,
      required this.id,
      required this.token});

  final void Function() logout;
  final String username;
  final int id;
  final String token;

  @override
  State<ShoppingCartScreen> createState() {
    return _ShoppingCartState();
  }
}

class _ShoppingCartState extends State<ShoppingCartScreen> {
  bool _isLoading = true;
  bool _shouldDelete = true;
  bool _isUndoSnackbarVisible = false;
  Expense? _lastDeletedExpense;
  bool isProfile = false;
  String title = 'Your Shopping Lists';

  @override
  void initState() {
    getShoppingList();
    super.initState();
  }

  void getShoppingList() async {
    setState(() {
      _isLoading = true;
    });

    var response =
        await GetShoppingListRequest.getShoppingList(widget.id, widget.token);
    print(response);

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

  void _addNewList(Expense expense) {
    createShoppingList(expense);
  }

  void createShoppingList(expense) async {
    try {
      var response = await CreateShoppingListRequest.createShoppingList(
          widget.id, expense.title);

      var responseData = json.decode(response);

      if (responseData.containsKey('errors')) {
        CustomSnackBar.show(
          context,
          'Shopping list creation failed',
          const Icon(Icons.error_outline_outlined, color: Colors.white),
          Colors.red,
        );
      } else {
        CustomSnackBar.show(
          context,
          'Shopping list has been created succesfully',
          const Icon(Icons.check, color: Colors.white),
          Colors.green,
        );
        setState(() {
          _registeredExpenses.add(Expense(
            id: responseData['data']['createShoppingList'],
            title: expense.title,
            date: expense.date,
            products: expense.products,
          ));
        });
      }
    } catch (err) {
      print(err);
      CustomSnackBar.show(
        context,
        'Shopping list creation failed',
        const Icon(Icons.error_outline_outlined, color: Colors.white),
        Colors.red,
      );
    }
  }

  List<Expense> _registeredExpenses = [];

  void _selectShoppingListItem(Expense expense) async {
    final modifiedExpense = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Details(expense)),
    );
    if (modifiedExpense != null) {
      setState(() {
        for (int i = 0; i < _registeredExpenses.length; i++) {
          if (_registeredExpenses[i].id == modifiedExpense.id) {
            _registeredExpenses[i] = modifiedExpense;
            break;
          }
        }
      });
    }
  }

  void _removeShoppingList(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);

    setState(() {
      _registeredExpenses.remove(expense);
    });

    if (!_isUndoSnackbarVisible) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          content: const Text('Shopping list has been deleted.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _registeredExpenses.insert(expenseIndex, _lastDeletedExpense!);
                _isUndoSnackbarVisible = false;
                _lastDeletedExpense = null;
              });
            },
          ),
        ),
      );

      _isUndoSnackbarVisible = true;
      _lastDeletedExpense = expense;

      Future.delayed(const Duration(seconds: 5), () {
        if (_isUndoSnackbarVisible) {
          _deleteShoppingList(expense);
          _isUndoSnackbarVisible = false;
        }
      });
    } else {
      _deleteShoppingList(expense);
    }
  }

  void _deleteShoppingList(Expense expense) {
    DeleteShoppingListRequest.deleteShoppingList(expense.id);
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = const Center(
      child: Text('No Shopping lists found. Start adding some!'),
    );

    if (_isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (_registeredExpenses.isNotEmpty && !isProfile) {
      mainContent = ExpensesList(
          expenses: _registeredExpenses,
          onRemoveExpense: _removeShoppingList,
          onSelectItem: _selectShoppingListItem);
    } else if (isProfile) {
      mainContent = Profile(
        userId: widget.id,
        token: widget.token,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!isProfile)
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  // isScrollControlled: true,
                  context: context,
                  builder: (ctx) => NewList(onAddList: _addNewList),
                );
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: mainContent,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 18),
                        Text(
                          'ShopApp',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Shopping Lists'),
                    leading: const Icon(Icons.shopping_bag_outlined),
                    onTap: () {
                      setState(() {
                        isProfile = false;
                        title = 'Your Shopping Lists';
                      });

                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Profile'),
                    leading: const Icon(Icons.person),
                    onTap: () {
                      setState(() {
                        isProfile = true;
                        title = 'Profile';
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout),
              onTap: widget.logout,
            ),
          ],
        ),
      ),
    );
  }
}
