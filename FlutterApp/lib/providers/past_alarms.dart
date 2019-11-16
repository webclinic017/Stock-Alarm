import 'package:flutter/foundation.dart';
import 'package:trading_alarm/models/alarm.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PastAlarms with ChangeNotifier {
  List<Alarm> _items = [];
  FirebaseUser user;

  void resetUser() {
    user = null;
    _items = [];
  }

  void connectToFirebase() async {
    _items = [];
    user = await FirebaseAuth.instance.currentUser();

    FirebaseDatabase.instance
        .reference()
        .child("Users")
        .child(user.uid)
        .child("PastAlarms")
        .once()
        .then((snap) {
      // TODO check if snap empty
      var it = snap.value.values.iterator;
      while (it.moveNext()) {
        var alarm = Alarm.fromMap(it.current);
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

  void removeLocalAlarmById(String alarmId) {
    _items.removeWhere((element) => element.id == alarmId);
    notifyListeners();
  }

  void removeAlarm(Alarm alarm) {
    FirebaseDatabase.instance
        .reference()
        .child('Users')
        .child(user.uid)
        .child("PastAlarms")
        .child(alarm.id)
        .remove();

    _items.removeWhere((element) => element.id == alarm.id);
    notifyListeners();
  }

  void addAlarm(alarm) async {
    _items.add(alarm); //and update ui after success
    notifyListeners();
  }
}
