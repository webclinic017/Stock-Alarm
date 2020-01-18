import 'package:flutter/foundation.dart';
import 'package:trading_alarm/models/alarm.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'user.dart';

class Alarms with ChangeNotifier {
  List<Alarm> _items = [];


  void resetUser() {
    _items = [];
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

  void update(User user) async {
    //TODO see if i can pass the user provider to this class in constructor and then always use it
    _items = [];

    await FirebaseDatabase.instance
        .reference()
        .child("Users")
        .child(user.id)
        .child("Alarms")
        .once()
        .then((snap) {
      var it = snap.value.values.iterator;
      while (it.moveNext()) {
        var alarm = Alarm.fromMap(it.current);
        print(alarm);
        _items.add(alarm);
        notifyListeners();
      }
    });
  }

  void removeAlarm(Alarm alarm,User user) {
    FirebaseDatabase.instance
        .reference()
        .child('Alarms')
        .child(alarm.symbol)
        .child(alarm.id)
        .remove();
    FirebaseDatabase.instance
        .reference()
        .child('Users')
        .child(user.id)
        .child("Alarms")
        .child(alarm.id)
        .remove();

    _items.removeWhere((element) => element.id == alarm.id);
    notifyListeners();
  }

  Future addAlarm(symbol, level, User user) async {
    var alarm = Alarm(symbol, level);

    var ref = FirebaseDatabase.instance
        .reference()
        .child('Alarms')
        .child(alarm.symbol)
        .push();

    await ref.set({"owner": user.id});

    var id = ref.key;
    alarm.setId(id);
    var future1 = ref.update(alarm.toJson()); //auch .then

    var future2 = FirebaseDatabase.instance
        .reference()
        .child("Users")
        .child(user.id)
        .child("Alarms")
        .child(alarm.id)
        .set(alarm.toJson());
    Future.wait([future1, future2]).then((_) {
      //wait for all database operation to finish successfully
      _items.add(alarm); //and update ui after success
      notifyListeners();
    }).catchError((error) {
      print("Add Alarm Error" + error);
    }); //TODO show error popup to user
  }
}
