import 'package:intl/intl.dart';

class Alarm {
  String symbol;
  double level;
  String id;
  DateTime creationDate;
  DateTime triggerDate;

  Alarm(symbol, level) {
    this.symbol = symbol;
    this.level = level;
    this.creationDate = DateTime.now();
  }

  void setId(String id) {
    this.id = id;
  }

  Alarm.fromMap(Map snapshot) {
    id = snapshot['id'] ?? '';
    symbol = snapshot['symbol'] ?? '';
    level = snapshot['level'].toDouble() ?? '';
    creationDate =
        DateTime.fromMillisecondsSinceEpoch(snapshot['creationDate']) ?? '';
    if (snapshot["triggerDate"] != null) {
      triggerDate = DateTime.fromMillisecondsSinceEpoch(snapshot[
          "triggerDate"]); //TODO send triggerdate with push message and display it in log screen
    }
  }

  String toString() {
    return "Alarm of Symbol $symbol at Level ${level.toString()} created at ${DateFormat("dd-MM-yy").add_j().format(creationDate)}";
  }

  toJson() {
    return {
      "symbol": symbol,
      "level": level,
      "id": id,
      "creationDate": creationDate.millisecondsSinceEpoch,
    };
  }
}
