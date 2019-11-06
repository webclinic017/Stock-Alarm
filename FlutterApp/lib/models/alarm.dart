import 'package:uuid/uuid.dart';

class Alarm {
  String symbol;
  double level;
  var uuid = new Uuid();
  String id;

  Alarm(symbol, level) {
    this.symbol = symbol;
    this.level = level;
    this.id = uuid.v1();
  }

  Alarm.fromMap(Map snapshot)
      : this.id = Uuid().v1() ?? '',
        symbol = snapshot['symbol'] ?? '',
        level = snapshot['level'] ?? '';

  String toString() {
    return "Alarm of Symbol $symbol at Level ${level.toString()}";
  }

  toJson() {
    return {
      "symbol": symbol,
      "level": level,
      "id": id,
    };
  }
}
