import 'package:flutter/material.dart';
import 'package:trading_alarm/providers/active_alarms.dart';
import 'package:provider/provider.dart';
import '../widgets/alarm_widget.dart';

class AlarmList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var alarms = Provider.of<Alarms>(context);

    return ListView.builder(
        itemCount: alarms.items.length,
        itemBuilder: (ctx, index) {
          return AlarmWidget(alarms.items[index]);
        });
  }
}
