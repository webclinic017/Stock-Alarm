import 'package:flutter/material.dart';
import 'models/alarm.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String chosenSymbol;
  var pairs = <String>['AAPL', 'GOOGL', 'IBM'];
  List<Alarm> alarms = [Alarm("AAPL", 250.43), Alarm("GOOGL", 500.03)];

  @override
  Widget build(BuildContext context) {
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
                          return new DropdownMenuItem<String>(
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
                    controller: new TextEditingController(),
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
              onPressed: () {},
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
              itemCount: alarms.length,
              itemBuilder: (ctx, index) {
                return ListTile(
                  trailing: Text(
                    alarms[index].symbol,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  title: Text(alarms[index].level.toString() + "\$"),
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
