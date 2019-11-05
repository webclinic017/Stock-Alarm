class Alarm {
  String symbol;
  double level;
  String id = DateTime.now().toString();

  Alarm(this.symbol, this.level);

  Alarm.fromMap(Map snapshot, String id)
      : id = id ?? '',
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
