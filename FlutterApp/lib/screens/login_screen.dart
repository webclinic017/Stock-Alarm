import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import 'package:trading_alarm/providers/active_alarms.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers/past_alarms.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import '../providers/user.dart';
import 'package:async_loader/async_loader.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  var token;
  var email;
  var password;
  User user;
  var _form = GlobalKey<FormState>();

  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
  new GlobalKey<AsyncLoaderState>();
  FirebaseAuth auth = FirebaseAuth.instance;

  String loginText = "";
  FirebaseUser fbUser;
  var ref = FirebaseDatabase.instance.reference();

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  void checkToken() async {
    token = await FirebaseMessaging().getToken();

    await ref
        .child("Users")
        .child(user.id)
        .child("token")
        .once()
        .then((snapshot) {
      if (snapshot.value != token) {
        ref.child("Users").child(user.id).set({"token": token});
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
          Provider.of<Alarms>(context, listen: false).update(user);
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
    token = await FirebaseMessaging().getToken();
    await ref.child("Users").child(user.id).set({
      "token": token,
      "email": user.email,
    });
  }

  Future<AuthResult> register() {
    _form.currentState.save();
    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  Future checkUser(){
    return getUser().then((fbUser2) async{
      if (fbUser2 != null) {
        await user.init();
        initApp();
        return true;
      }
      else {return false;}
    });
  }

  Future initApp() async{
    final alarms = Provider.of<Alarms>(context, listen: false);
    final pastAlarms = Provider.of<PastAlarms>(context, listen: false);

    await user.init();
    checkToken();
    alarms
        .update(user); // <- turn this into a future and put navigator .push in then teil
    pastAlarms.connectToFirebase(user);
    //handleAppLifecycleState();
  }


  Future<FirebaseUser> getUser() async {
    return await auth.currentUser();
  }

  @override
  void initState() {
    Future.delayed(Duration(microseconds: 0)).then((_){user=Provider.of<User>(context);});
    checkUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final alarms = Provider.of<Alarms>(context, listen: false);
    user=Provider.of<User>(context);
    var loginScreen=Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        children: <Widget>[
          Center(
            child: FlatButton(
              onPressed: () {
                login().then((_) async {
                   await initApp();
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
                _handleSignIn().then((_){
                  Navigator.pushReplacementNamed(context, HomeScreen.routeName);
                }).catchError((error)=> print(error));
                //handleAppLifecycleState();
              },
              child: Text("Google Login"),
              color: Theme.of(context).primaryColor,
            ),
          ),
          Center(
            child: FlatButton(
              onPressed: () {
                register().then((_) async{
                  user.init();
                  writeUserToDatabase();
                  alarms.update(user); //<- to get the user ready in alarms.dart

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

      var _asyncLoader = new AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await checkUser(),
        renderLoad: () => Scaffold(body: Center(child: CircularProgressIndicator()),appBar: AppBar(),) ,
        renderError: ([error]) =>
        new Text('Sorry, there was an error loading your joke'),
        renderSuccess: ({data}) => data ? HomeScreen():loginScreen,
      );

    return _asyncLoader;


  }
}
