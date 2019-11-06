import 'package:flutter/material.dart';

class PricePicker extends StatelessWidget {
  final TextEditingController priceController;

  PricePicker(this.priceController);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            filled: true, hintText: 'Enter text', labelText: 'Alarm Price'),
        controller: priceController,
      ),
    );
  }
}
