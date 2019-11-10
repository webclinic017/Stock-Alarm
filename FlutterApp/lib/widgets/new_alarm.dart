import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarms.dart';
import 'symbol_picker.dart';
import 'price_picker.dart';

class NewAlarm extends StatefulWidget {
  @override
  _NewAlarmState createState() => _NewAlarmState();
}

class _NewAlarmState extends State<NewAlarm> {
  final amountController = TextEditingController();
  var chosenSymbol;

  callback(newSymbol) {
    chosenSymbol = newSymbol;
  }

  void _submitData() {
    if (amountController.text.isEmpty) {
      return;
    }
    final enteredTitle = chosenSymbol;
    final enteredAmount = double.parse(amountController.text);

    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      return;
    }
    var alarms = Provider.of<Alarms>(context, listen: false);
    alarms.addAlarm(enteredTitle, enteredAmount);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          height: MediaQuery.of(context).viewInsets.bottom + 100,
          padding: EdgeInsets.only(
              top: 10,
              right: 10,
              left: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                flex: 2,
                child: Container(
                  height: 60,
                  child: SymbolPicker(callback),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                  flex: 2,
                  child: Container(
                      height: 50, child: PricePicker(amountController))),
              SizedBox(
                width: 20,
              ),
              Flexible(
                flex: 1,
                child: RaisedButton(
                  child: FittedBox(
                    child: Text(
                      'Add Alarm',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    fit: BoxFit.cover,
                  ),
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).textTheme.button.color,
                  onPressed: _submitData,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
