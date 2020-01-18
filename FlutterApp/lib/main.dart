import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/active_alarms.dart';
import 'screens/log_screen.dart';
import 'providers/past_alarms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'providers/user.dart';
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {


  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseUser fbUser;
  User user =User();

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (context) => Alarms(),
        ),
        ChangeNotifierProvider(
          builder: (context) => PastAlarms(),
        ),
        ChangeNotifierProvider.value(value: user)
      ],
      child: MaterialApp(
          title: 'Stock Alarm',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Medium',
          ),
          home: LoginScreen(),
          routes: {
            HomeScreen.routeName: (ctx) => HomeScreen(),
            LoginScreen.routeName: (ctx) => LoginScreen(),
            LogScreen.routeName: (ctx) => LogScreen(),
          }),
    );
  }
}
