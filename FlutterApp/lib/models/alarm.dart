import 'package:uuid/uuid.dart';

class Alarm {
  String symbol;
  double level;
  String id;

  Alarm(symbol, level) {
    this.symbol = symbol;
    this.level = level;
  }

  void setId(String id) {
    this.id = id;
  }

  Alarm.fromMap(Map snapshot)
      : id = snapshot['id'] ?? '',
        symbol = snapshot['symbol'] ?? '',
        level = snapshot['level'].toDouble() ?? '';

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
