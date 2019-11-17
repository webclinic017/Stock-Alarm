import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import 'package:trading_alarm/providers/active_alarms.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers/past_alarms.dart';

import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var token;
  var email;
  var password;
  var _form = GlobalKey<FormState>();

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

  handleAppLifecycleState() {
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

  Future<AuthResult> login() {
    _form.currentState.save();
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  void writeUserToDatabase() async {
    user = await FirebaseAuth.instance.currentUser();
    token = await FirebaseMessaging().getToken();
    await ref.child("Users").child(user.uid).set({
      "token": token,
      "email": user.email,
    });
  }

  Future<AuthResult> register() {
    _form.currentState.save();
    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final alarms = Provider.of<Alarms>(context, listen: false);
    final pastAlarms = Provider.of<PastAlarms>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        children: <Widget>[
          Center(
            child: FlatButton(
              onPressed: () {
                login().then((_) {
                  checkToken();
                  alarms
                      .update(); // <- turn this into a future and put navigator .push in then teil
                  pastAlarms.connectToFirebase();
                  //handleAppLifecycleState();
                  Navigator.pushReplacementNamed(context, HomeScreen.routeName);
                }).catchError((_) {
                  setState(() {
                    loginText = "User does not exist";
                  });
                });
              },
              child: Text("Login"),
              color: Theme.of(context).primaryColor,
            ),
          ),
          Center(
            child: FlatButton(
              onPressed: () {
                register().then((_) {
                  writeUserToDatabase();
                  alarms.update(); //<- to get the user ready in alarms.dart

                  Navigator.pushReplacementNamed(context, HomeScreen.routeName);
                }).catchError((error) {
                  setState(() {
                    loginText = "Registering failed";
                  });
                });
              },
              child: Text("Register"),
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(loginText),
          Form(
            key: _form,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: "email"),
                  initialValue: "dud2@dud.de",
                  onSaved: (value) {
                    email = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Password"),
                  initialValue: "duddud",
                  onSaved: (value) {
                    password = value;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
