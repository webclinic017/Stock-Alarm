import 'package:flutter/material.dart';

class SymbolPicker extends StatefulWidget {
  final Function(String) callback;
  SymbolPicker(this.callback);

  @override
  _SymbolPickerState createState() => _SymbolPickerState();
}

class _SymbolPickerState extends State<SymbolPicker> {
  var chosenSymbol =
      'AAPL'; // <= for Dropdown Menu initialization value, has to be a valid value
  var symbols = <String>['AAPL', 'GOOGL', 'IBM'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return DropdownButton(
          hint: Container(
            width: constraints.maxWidth - 24, //24 = arrow size
            child: FittedBox(
              child: const Text("Choose a Stocksymbol"),
              fit: BoxFit.fill,
            ),
          ),
          value: chosenSymbol,
          items: symbols.map((String symbol) {
            return DropdownMenuItem<String>(
              value: symbol,
              child: Text(symbol),
            );
          }).toList(),
          onChanged: (newValue) {
            widget.callback(newValue);
            setState(() {
              chosenSymbol = newValue;
            });
          },
        );
      },
    );
  }
}
