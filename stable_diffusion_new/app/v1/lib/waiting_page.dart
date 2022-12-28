import 'package:flutter/material.dart';

class waitpage extends StatefulWidget {
  const waitpage({Key? key}) : super(key: key);

  @override
  _waitpageState createState() => _waitpageState();
}

class _waitpageState extends State<waitpage> {
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    final text = arguments["text"];

    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text("waiting page"),
            ),
            body: Text("waiting page"),
          );
        }
      ),
    );
  }
}
