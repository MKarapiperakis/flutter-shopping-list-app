import 'package:chat_app/models/expense.dart';
import 'package:flutter/material.dart';

class NewProduct extends StatefulWidget {
  const NewProduct({Key? key, required this.onAddProduct}) : super(key: key);

  final void Function(Product product) onAddProduct;

  @override
  _NewProductState createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController =
      TextEditingController(text: "0");
  final TextEditingController _quantityController = TextEditingController();

  void _submitProductData() {
    if (_formKey.currentState!.validate()) {
      final productName = _nameController.text;
      final productPrice = double.parse(_priceController.text);
      final productQuantity = int.parse(_quantityController.text);

      final newProduct = Product(
        name: productName,
        price: productPrice,
        quantity: productQuantity,
        id: uuid.v4(),
      );

      widget.onAddProduct(newProduct);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              autofocus: true,
              controller: _nameController,
              maxLength: 30,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Product Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a product name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                        labelText: 'Price', prefixText: '\€ '),
                    validator: (value) {
                      if (value == null || double.tryParse(value) == null) {
                        return 'Please enter a valid price.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null) {
                        return 'Please enter a valid quantity.';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitProductData,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                elevation: 8,
                shadowColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
