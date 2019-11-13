import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:trading_alarm/providers/alarms.dart';
import 'package:trading_alarm/widgets/symbol_picker.dart';
import 'package:trading_alarm/widgets/alarm_list.dart';
import 'package:trading_alarm/widgets/price_picker.dart';
import 'package:trading_alarm/widgets/add_alarm_button.dart';
import 'login_screen.dart';
import '../widgets/new_alarm.dart';
import 'log_screen.dart';

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

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      userId = user.uid;
    });
    super.initState();
  }

  void setupPushNotifications() {
    _firebaseMessaging.configure(
      // ignore: missing_return
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
        showDialog(
            context: context,
            builder: (BuildContext ctx) {
              return AlertDialog(
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
      setupPushNotifications();
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

  @override
  Widget build(BuildContext context) {
    final alarms = Provider.of<Alarms>(context, listen: false);

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
            Container(height: deviceHeight * 0.93, child: AlarmList()),
          ],
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
