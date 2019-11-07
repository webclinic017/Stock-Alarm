import 'package:flutter/foundation.dart';
import 'package:trading_alarm/models/alarm.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Alarms with ChangeNotifier {
  List<Alarm> _items = [];
  String userId;

  void connectToFirebase() {
    FirebaseAuth.instance.currentUser().then((user) {
      userId = user.uid;
    });

    //TODO load from database into alarms provider
    FirebaseDatabase.instance
        .reference()
        .child("Users")
        .child(userId)
        .child("Alarms")
        .once()
        .then((snap) {
      var a = snap.value.values.iterator;
      while (a.moveNext()) {
        var alarm = Alarm.fromMap(a.current);
        print(alarm);
        _items.add(alarm);
        notifyListeners();
      }
    });

    // <- put this into then so that the ui is updating after loading finished
    //or for the case of a lot of alarms: keep notify listeners in the loop so that the list of alarms build slowly
    //=> requires that the list is in consumer and not whole ui updating
  }

  List<Alarm> get items {
    return [..._items];
  }

  Alarm findById(String id) {
    return _items.firstWhere((alarm) => alarm.id == id);
  }

  void addAlarm(symbol, level) {
    var alarm = Alarm(symbol, level);

    FirebaseDatabase.instance
        .reference()
        .child('Alarms')
        .child(alarm.symbol)
        .child(alarm.id)
        .set(alarm.toJson()); //auch .then

    FirebaseDatabase.instance
        .reference()
        .child('Alarms')
        .child(alarm.symbol)
        .child(alarm.id)
        .set({"owner": userId});

    FirebaseDatabase.instance
        .reference()
        .child("Users")
        .child(userId)
        .child("Alarms")
        .child(alarm.id)
        .set(alarm.toJson())
        .then((_) {
      _items.add(alarm);
      notifyListeners();
    }); //nur items.add und notify ausführen wenn .then von firebase successfull
  }
}
