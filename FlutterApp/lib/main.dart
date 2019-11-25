import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/active_alarms.dart';
import 'screens/log_screen.dart';
import 'providers/past_alarms.dart';
//import 'flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Future login(loginData) async {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginData["email"], password: loginData["password"]);
  }

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
