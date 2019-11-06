import 'package:flutter/material.dart';
import 'package:trading_alarm/providers/alarms.dart';
import 'package:provider/provider.dart';

class AlarmList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var alarms = Provider.of<Alarms>(context);

    return ListView.builder(
      itemCount: alarms.items.length,
      itemBuilder: (ctx, index) {
        return ListTile(
          trailing: Text(
            alarms.items[index].symbol,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          title: Text(alarms.items[index].level.toString() + "\$"),
        );
      },
    );
  }
}
