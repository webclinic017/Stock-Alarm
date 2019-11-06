import 'package:flutter/material.dart';

class AddAlarmButton extends StatelessWidget {
  final TextEditingController priceController;
  final Function addAlarm;

  AddAlarmButton(this.priceController, this.addAlarm);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        addAlarm();
      },
      child: Text("Add Alarm"),
      color: Theme.of(context).primaryColor,
    );
  }
}
