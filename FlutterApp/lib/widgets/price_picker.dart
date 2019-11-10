import 'package:flutter/material.dart';

class PricePicker extends StatelessWidget {
  final TextEditingController priceController;

  PricePicker(this.priceController);

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(filled: true, labelText: 'Price'),
      controller: priceController,
    );
  }
}
