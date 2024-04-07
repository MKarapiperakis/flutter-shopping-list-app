import 'package:chat_app/models/expense.dart';
import 'package:flutter/material.dart';

class NewList extends StatefulWidget {
  const NewList({Key? key, required this.onAddList}) : super(key: key);

  final void Function(Expense expense) onAddList;

  @override
  _NewListState createState() => _NewListState();
}

class _NewListState extends State<NewList> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  void _submitList() {
    if (_formKey.currentState!.validate()) {
      final productName = _nameController.text;

      final newList = Expense(
        id: uuid.v4(),
        title: productName,
        date: DateTime.now(),
        products: [],
      );

      widget.onAddList(newList);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();

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
              textInputAction: TextInputAction.done,
              decoration:
                  const InputDecoration(labelText: 'Shopping List Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name for your shopping list.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitList,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                elevation: 8,
                shadowColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add List'),
            ),
          ],
        ),
      ),
    );
  }
}
