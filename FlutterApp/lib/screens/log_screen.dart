import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:trading_alarm/models/alarm.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login_screen.dart';
import '../widgets/alarm_list.dart';
import 'package:provider/provider.dart';
import '../providers/active_alarms.dart';
import '../widgets/alarm_widget.dart';
import '../providers/past_alarms.dart';

class LogScreen extends StatefulWidget {
  static const routeName = "/log-screen";

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  @override
  Widget build(BuildContext context) {
    final alarms = Provider.of<PastAlarms>(context);

    final appBar = AppBar(
      title: Text('Stock Alarm'),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.pushNamed(context, LogScreen.routeName);
            }),
        IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              alarms
                  .resetUser(); //TODO try to solve this otherwise to not have the provider of alarms in this class, maybe with a provider for the user

              Navigator.pushNamed(context, LoginScreen.routeName);
            }),
      ],
    );

    final deviceHeight = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        (2 * 16) -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: appBar,
      body: Container(
        height: deviceHeight,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: deviceHeight * 0.07,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Price",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_upward),
                  Spacer(),
                  Text(
                    "Creation",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_upward),
                  Spacer(),
                  Text(
                    "Symbol",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_upward),
                ],
              ),
            ),
            Container(
                height: deviceHeight * 0.93,
                child: ListView.builder(
                    itemCount: alarms.items.length,
                    itemBuilder: (ctx, index) {
                      return AlarmWidget(alarms.items[index]);
                    })),
          ],
        ),
      ),
    );
  }
}
