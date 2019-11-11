import 'package:flutter/foundation.dart';
import 'package:trading_alarm/models/alarm.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Alarms with ChangeNotifier {
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

  void removeAlarm(Alarm alarm) {
    FirebaseDatabase.instance
        .reference()
        .child('Alarms')
        .child(alarm.symbol)
        .child(alarm.id)
        .remove();
    FirebaseDatabase.instance
        .reference()
        .child('Users')
        .child(user.uid)
        .child("Alarms")
        .child(alarm.id)
        .remove();

    _items.removeWhere((element) => element.id == alarm.id);
    notifyListeners();
  }

  void addAlarm(symbol, level) async {
    var alarm = Alarm(symbol, level);

    var ref = FirebaseDatabase.instance
        .reference()
        .child('Alarms')
        .child(alarm.symbol)
        .push();

    await ref.set({"owner": user.uid});

    var id = ref.key;
    alarm.setId(id);
    var future1 = ref.update(alarm.toJson()); //auch .then

    var future2 = FirebaseDatabase.instance
        .reference()
        .child("Users")
        .child(user.uid)
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
