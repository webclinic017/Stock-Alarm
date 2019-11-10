import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import 'package:trading_alarm/providers/alarms.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
                      .connectToFirebase(); // <- turn this into a future and put navigator .push in then teil

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
                  alarms
                      .connectToFirebase(); //<- to get the user ready in alarms.dart

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
                  initialValue: "dud@dud.de",
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
