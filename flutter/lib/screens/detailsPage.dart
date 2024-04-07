// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:chat_app/api/addProductRequest.dart';
import 'package:chat_app/api/updateProductRequest.dart';
import 'package:chat_app/api/deleteProductRequest.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/expense.dart';
import 'package:chat_app/widgets/shopping_list/add_item.dart';
import 'package:chat_app/utils/snackbar.dart';

class Details extends StatefulWidget {
  const Details(this.expense, {Key? key}) : super(key: key);

  final Expense expense;

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  void _removeExistingProduct(Product product) {
    widget.expense.products.remove(product);
    widget.expense.updateAmount(widget.expense.products);
    _removeProduct(product);
  }

  void _addNewProduct(Product product) {
    _addProduct(product);
  }

  void _removeProduct(Product product) async {
    try {
      var response = await DeleteProductRequest.deleteProduct(product.id);
      var responseData = json.decode(response);
      if (responseData != null || !responseData.containsKey('errors')) {
        CustomSnackBar.show(
          context,
          'Product has been deleted succesfully',
          const Icon(Icons.check, color: Colors.white),
          Colors.green,
        );
      } else {
        CustomSnackBar.show(
          context,
          'Product deletion failed',
          const Icon(Icons.error_outline_outlined, color: Colors.white),
          Colors.red,
        );
      }
    } catch (error) {
      CustomSnackBar.show(
        context,
        'Product deletion failed',
        const Icon(Icons.error_outline_outlined, color: Colors.white),
        Colors.red,
      );
    }
  }

  void _addProduct(Product product) async {
    try {
      var response = await AddProductRequest.addProduct(
          widget.expense.id, product.name, product.price, product.quantity);

      var responseData = json.decode(response);

      if (responseData.containsKey('errors')) {
        CustomSnackBar.show(
          context,
          'Product insertion failed',
          const Icon(Icons.error_outline_outlined, color: Colors.white),
          Colors.red,
        );
      } else {
        String title = widget.expense.title;
        String shortenedTitle =
            title.length <= 8 ? title : title.substring(0, 8);
        CustomSnackBar.show(
          context,
          'Product has been added to list: $shortenedTitle',
          const Icon(Icons.check, color: Colors.white),
          Colors.green,
        );
        setState(() {
          widget.expense.products.add(Product(
              id: responseData['data']['createProduct'],
              name: product.name,
              price: product.price,
              quantity: product.quantity));
        });
        widget.expense.updateAmount(widget.expense.products);
      }
    } catch (err) {
      print(err);
      CustomSnackBar.show(
        context,
        'Product insertion failed',
        const Icon(Icons.error_outline_outlined, color: Colors.white),
        Colors.red,
      );
    }
  }

  Future<void> _editProduct(Product product) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    nameController.text = product.name;
    priceController.text = product.price.toString();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                maxLength: 30,
              ),
              TextField(
                controller: priceController,
                maxLength: 3,
                decoration: const InputDecoration(
                    labelText: 'Price', prefixText: '\€ '),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  product.name = nameController.text;
                  product.price = double.parse(priceController.text);
                  widget.expense.updateAmount(widget.expense.products);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProductRequest() async {
    try {
      for (var product in widget.expense.products) {
        await UpdateProductRequest.updateProduct(
          productId: product.id,
          title: product.name,
          price: product.price,
          quantity: product.quantity,
        );
      }
      print('Products updated successfully.');
    } catch (error) {
      print('Error updating products: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = const Center(
      child: Text('No products found. Start adding some!'),
    );

    if (widget.expense.products.length > 0) {
      mainContent = ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final Product product = widget.expense.products.removeAt(oldIndex);
            widget.expense.products.insert(newIndex, product);
          });
        },
        children: widget.expense.products
            .map((product) => Dismissible(
                  key: Key(product.id.toString()),
                  onDismissed: (direction) {
                    setState(() {
                      _removeExistingProduct(product);
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                  ),
                  child: GestureDetector(
                    key: GlobalKey(),
                    onTap: () => _editProduct(product),
                    child: ListTile(
                      key: ValueKey(product.id),
                      title: Row(
                        children: [
                          Expanded(child: Text(product.name)),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (product.quantity > 0) {
                                  product.updateQuantity(product.quantity - 1);
                                  widget.expense
                                      .updateAmount(widget.expense.products);
                                }
                              });
                            },
                          ),
                          Text(product.quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                product.updateQuantity(
                                    product.quantity + 1); // Update quantity
                                widget.expense
                                    .updateAmount(widget.expense.products);
                              });
                            },
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price: \€${product.price.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, widget.expense);
        await _updateProductRequest();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Details'),
        ),
        body: Hero(tag: widget.expense.id ?? '', child: mainContent),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              // isScrollControlled: true,
              context: context,
              builder: (ctx) => NewProduct(onAddProduct: _addNewProduct),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
