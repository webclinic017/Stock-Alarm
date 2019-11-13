import 'package:flutter/material.dart';

class LogScreen extends StatelessWidget {
  static const routeName = "/log-screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Past Activity"),
      ),
      body: Container(
        child: Center(child: Text("Past Alarm")),
      ),
    );
  }
}
