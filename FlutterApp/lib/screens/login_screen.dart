import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import 'package:trading_alarm/providers/alarms.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final alarms = Provider.of<Alarms>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: FlatButton(
          onPressed: () {
            FirebaseAuth.instance.signInWithEmailAndPassword(
                email: "lol@fefe.de", password: "1234567");

            alarms
                .connectToFirebase(); // <- turn this into a future and put navigator .push in then teil

            Navigator.pushNamed(context, HomeScreen.routeName);
          },
          child: Text("Login"),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
