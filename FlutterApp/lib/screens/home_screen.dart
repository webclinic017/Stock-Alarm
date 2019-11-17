import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:trading_alarm/providers/active_alarms.dart';
import 'package:trading_alarm/widgets/symbol_picker.dart';
import 'package:trading_alarm/widgets/alarm_list.dart';
import 'package:trading_alarm/widgets/price_picker.dart';
import 'package:trading_alarm/widgets/add_alarm_button.dart';
import 'login_screen.dart';
import '../widgets/new_alarm.dart';
import 'log_screen.dart';
import '../providers/past_alarms.dart';

import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var chosenSymbol;
  var init = true;
  final priceController = TextEditingController();
  var userId; //evtl user oder userid als provider, im falle von user screen oder so
  final _firebaseMessaging = FirebaseMessaging();

  callback(newSymbol) {
    chosenSymbol = newSymbol;
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  void handleAppLifecycleState() {
    AppLifecycleState _lastLifecyleState;
    // ignore: missing_return
    SystemChannels.lifecycle.setMessageHandler((msg) {
      print('SystemChannels> $msg');
      switch (msg) {
        case "AppLifecycleState.resumed":
          _lastLifecyleState = AppLifecycleState.resumed;
          print(_lastLifecyleState);
          Provider.of<Alarms>(context).update();
          break;
        default:
      }
    });
  }

  @override
  void initState() {
    handleAppLifecycleState();
    FirebaseAuth.instance.currentUser().then((user) {
      userId = user.uid;
    });
    super.initState();
  }

  void setupPushNotifications(Alarms alarms, PastAlarms pastAlarms) {
    _firebaseMessaging.configure(
      // ignore: missing_return
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
        var alarmId = message.values.elementAt(1)[
            "alarmId"]; //TODO look into firebase messaging options and make this less hardcoded
        showDialog(
            context: context,
            builder: (BuildContext ctx) {
              //TODO implement pull down for refresh
              return AlertDialog(
                actions: <Widget>[
                  //TODO think about highlighting in the background in home screen when popup is there
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      pastAlarms.addAlarm(alarms.findById(alarmId));
                      alarms.removeLocalAlarmById(alarmId);

                      Navigator.pushNamed(context, LogScreen.routeName,
                          arguments: alarmId);
                    },
                    child: Text("Show"),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      pastAlarms.addAlarm(alarms.findById(alarmId));

                      alarms.removeLocalAlarmById(alarmId);
                    },
                    child: Text("Dimiss"),
                  ),
                ],
                title: Text("ALARM"),
              );
            });
      },
      // ignore: missing_return
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      // ignore: missing_return
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );
  }

  @override
  void didChangeDependencies() {
    if (init) {
      setupPushNotifications(Provider.of<Alarms>(context, listen: false),
          Provider.of<PastAlarms>(context, listen: false));
      init = false;
    }
    super.didChangeDependencies();
  }

  void _startAddNewAlarm(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewAlarm(),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  Future<void> _update(alarms) async {
    await alarms.update();
  }

  @override
  Widget build(BuildContext context) {
    final alarms = Provider.of<Alarms>(context);

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
                  .resetUser(); //try to solve this otherwise to not have the provider of alarms in this class, maybe with a provider for the user
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
      body: RefreshIndicator(
        onRefresh: () {
          return _update(alarms);
        },
        child: Container(
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
              Container(height: deviceHeight * 0.93, child: AlarmList()),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).accentColor,
        onPressed: () => _startAddNewAlarm(context),
      ),
    );
  }
}
