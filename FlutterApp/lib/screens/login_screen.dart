import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import 'package:trading_alarm/providers/active_alarms.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers/past_alarms.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var token;

  String loginText = "";
  FirebaseUser user;
  var ref = FirebaseDatabase.instance.reference();

  void checkToken() async {
    user = await FirebaseAuth.instance.currentUser();
    token = await FirebaseMessaging().getToken();
    await ref
        .child("Users")
        .child(user.uid)
        .child("token")
        .once()
        .then((snapshot) {
      if (snapshot.value != token) {
        ref.child("Users").child(user.uid).set({"token": token});
      }
    });
  }

  void handleAppLifecycleState() {
    AppLifecycleState _lastLifecyleState;
    // ignore: missing_return
    SystemChannels.lifecycle.setMessageHandler((msg) {
      print('SystemChannels> $msg');
      switch (msg) {
        case "AppLifecycleState.paused":
          _lastLifecyleState = AppLifecycleState.paused;
          print(_lastLifecyleState);
          break;
        case "AppLifecycleState.inactive":
          _lastLifecyleState = AppLifecycleState.inactive;
          print(_lastLifecyleState);
          break;
        case "AppLifecycleState.resumed":
          _lastLifecyleState = AppLifecycleState.resumed;
          print(_lastLifecyleState);
          Provider.of<Alarms>(context, listen: false).update();
          break;
        case "AppLifecycleState.suspending":
          _lastLifecyleState = AppLifecycleState.suspending;
          print(_lastLifecyleState);
          break;
        default:
      }
    });
  }

  void writeUserToDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    token = await FirebaseMessaging().getToken();
    await ref.child("Users").child(user.uid).set({
      "token": token,
      "email": user.email,
    });
  }

  Future<String> _authUser(LoginData data) async {
    print('Name: ${data.name}, Password: ${data.password}');
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: data.name, password: data.password)
        .then((val) {
      checkToken();
      Provider.of<Alarms>(context)
          .update(); // <- turn this into a future and put navigator .push in then teil
      Provider.of<PastAlarms>(context).connectToFirebase();
      return null;
    }).catchError((error) {
      return "Username does not exist!";
    });
  }

  Future<String> _registerUser(LoginData data) async {
    print('Name: ${data.name}, Password: ${data.password}');
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: data.name, password: data.password)
        .then((val) {
      writeUserToDatabase();
      Provider.of<Alarms>(context)
          .update(); //<- to get the user ready in alarms.dart

      return null;
    }).catchError((error) {
      return error.toString();
    });
  }

  Future<String> _recoverPassword(String name) async {
    print('Name: $name');
    await Future.delayed(Duration(seconds: 1)).then((_) {
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Stock Alarm',
      //logo: 'assets/images/ecorp-lightblue.png',
      onLogin: _authUser,
      onSignup: _registerUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
