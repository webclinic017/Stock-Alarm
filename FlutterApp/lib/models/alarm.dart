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

  Alarm.fromMap(Map snapshot, String id)
      : this.id = id ?? '',
        symbol = snapshot['symbol'] ?? '',
        level = snapshot['name'] ?? '';

  toJson() {
    return {
      "symbol": symbol,
      "level": level,
      "id": id,
    };
  }
}
