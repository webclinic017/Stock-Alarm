import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/alarms.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (context) => Alarms(),
      child: MaterialApp(
          title: 'Stock Alarm',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: LoginScreen(),
          routes: {
            HomeScreen.routeName: (ctx) => HomeScreen(),
          }),
    );
  }
}
