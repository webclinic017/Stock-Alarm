import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User with ChangeNotifier {
  String id;
  String email;

  Future init() async {
    print("user init");
    var fbUser= await FirebaseAuth.instance.currentUser();
    this.id=fbUser.uid;
    this.email=fbUser.email;
    print("user init done");
  }
}