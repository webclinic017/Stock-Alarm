import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarms.dart';

class AlarmWidget extends StatefulWidget {
  final alarm;
  AlarmWidget(this.alarm);

  @override
  _AlarmWidgetState createState() => _AlarmWidgetState();
}

class _AlarmWidgetState extends State<AlarmWidget> {
  @override
  Widget build(BuildContext context) {
    var alarms = Provider.of<Alarms>(context); //maybe listen=False possible

    return Dismissible(
      key: Key(widget.alarm.id),
      onDismissed: (direction) {
        // Remove the item from the data source.
        setState(() {
          alarms.removeAlarm(widget.alarm);
        });

        SnackBar(
          content: Text("${widget.alarm.symbol}-Alarm deleted"),
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              alarms.addAlarm(
                  widget.alarm.symbol, widget.alarm.level); //TODO Snackback!
            },
          ),
        );
      },
      child: Card(
        elevation: 2,
        child: ListTile(
          trailing: Text(
            widget.alarm.symbol,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          title: Text(widget.alarm.level.toString() + "\$"),
        ),
      ),
    );
  }
}
