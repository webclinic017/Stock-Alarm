import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/active_alarms.dart';
import 'package:intl/intl.dart';

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

        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("${widget.alarm.symbol}-Alarm deleted"),
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              alarms.addAlarm(
                  widget.alarm.symbol, widget.alarm.level); //TODO Snackback!
            },
          ),
        ));
      },
      child: Card(
        color: Colors.grey.withOpacity(0.1),
        elevation: 2,
        child: ListTile(
          trailing: Text(
            widget.alarm.symbol,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          title: Center(
            child: Column(
              children: <Widget>[
                Text(DateFormat()
                    .add_Hm()
                    .format(widget.alarm.creationDate)
                    .toString()),
                Text(
                  DateFormat("dd.MM.yy")
                      .format(widget.alarm.creationDate)
                      .toString(),
                ),
              ],
            ),
          ),
          leading: Text(widget.alarm.level.toString() + "\$"),
        ),
      ),
    );
  }
}
