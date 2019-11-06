import 'package:flutter/material.dart';
import '../models/alarm.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:trading_alarm/providers/alarms.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var init = true;
  var chosenSymbol =
      "GOOGL"; // <= for Dropdown Menu initialization value, has to be a valid value
  final myController = TextEditingController();

  //dummy data
  var pairs = <String>['AAPL', 'GOOGL', 'IBM'];
  //List<Alarm> alarms = [Alarm("AAPL", 250.43), Alarm("GOOGL", 500.03)];
  //List<Alarm> alarms = [];
  //List<String> pairs = ["AAPL"];

  var userId;

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((user) {
      userId = user.uid;
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (init) {
      final _firebaseMessaging = FirebaseMessaging();
      _firebaseMessaging.configure(
        // ignore: missing_return
        onMessage: (Map<String, dynamic> message) {
          print('on message ${message}');
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
                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return DropdownButton(
                        hint: Container(
                          width: constraints.maxWidth - 24,
                          child: FittedBox(
                            child: Text("Choose a Stocksymbol"),
                            fit: BoxFit.fill,
                          ),
                        ),
                        value: chosenSymbol,
                        items: pairs.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            chosenSymbol = newValue;
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 16.0,
                ),
                Flexible(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        filled: true,
                        hintText: 'Enter text',
                        labelText: 'Alarm Price'),
                    controller: myController,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Container(
            height: deviceHeight * 0.08,
            child: FlatButton(
              onPressed: () {
                double level = double.parse(myController.text);
                alarms.addAlarm(chosenSymbol, level);
              },
              child: Text("Add Alarm"),
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Container(
            height: deviceHeight * 0.77,
            child: ListView.builder(
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
            ),
          )
          //Alternate
        ],
      ),
    );
  }
}
