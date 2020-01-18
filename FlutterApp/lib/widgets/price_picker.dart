import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PricePicker extends StatelessWidget {
  final TextEditingController priceController;

  PricePicker(this.priceController);

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      //inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
      decoration: InputDecoration(filled: true, labelText: 'Price'),
      controller: priceController,
    );
  }
}
