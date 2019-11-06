import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:trading_alarm/providers/alarms.dart';
import 'package:trading_alarm/widgets/symbol_picker.dart';
import 'package:trading_alarm/widgets/alarm_list.dart';
import 'package:trading_alarm/widgets/price_picker.dart';
import 'package:trading_alarm/widgets/add_alarm_button.dart';

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

  @override
  Widget build(BuildContext context) {
    final alarms =
        Provider.of<Alarms>(context); // TODO bau consumer around list builder

    final appBar = AppBar(
      title: Text('Stock Alarm'),
    );
    final deviceHeight = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        (2 * 16) -
        MediaQuery.of(context).padding.top;

    print(deviceHeight);
    print(MediaQuery.of(context).size.height);
    print(appBar.preferredSize.height);
    print(MediaQuery.of(context).padding.top);
    //console.log(deviceHeight);

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: <Widget>[
          //Material example
          Container(
            //margin: EdgeInsets.all(15),
            padding: EdgeInsets.all(10),
            height: deviceHeight * 0.15,
            child: Row(
              children: <Widget>[
                SymbolPicker(callback),
                SizedBox(
                  width: 16.0,
                ),
                PricePicker(priceController),
              ],
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Container(
            height: deviceHeight * 0.08,
            child: AddAlarmButton(priceController, () {
              alarms.addAlarm(chosenSymbol, double.parse(priceController.text));
            }),
          ),
          SizedBox(
            height: 16.0,
          ),
          Container(
            height: deviceHeight * 0.77,
            child: AlarmList(),
          )
          //Alternate
        ],
      ),
    );
  }
}
