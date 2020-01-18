import 'package:flutter/material.dart';

class SymbolPicker extends StatefulWidget {
  final Function(String) callback;
  final initSymbol;
  SymbolPicker(this.callback, this.initSymbol);

  @override
  _SymbolPickerState createState() => _SymbolPickerState();
}

class _SymbolPickerState extends State<SymbolPicker> {
  var chosenSymbol;
  @override
  void initState() {
    chosenSymbol = widget.initSymbol;
    super.initState();
  }


  var symbols = ["AUDUSD","AUDCAD","AUDJPY","AUDCHF","AUDNZD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"];


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
