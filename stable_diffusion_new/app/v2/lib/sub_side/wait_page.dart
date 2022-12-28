import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class WaitPageSide extends StatefulWidget {
  const WaitPageSide({Key? key}) : super(key: key);

  @override
  _WaitPageState createState() => _WaitPageState();
}

class _WaitPageState extends State<WaitPageSide> {
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    final prompt = arguments["prompt"];

    const List<Color> _Colors = const [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];



    return Scaffold(
      appBar: AppBar(
        title: Text("Wait Page"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 50,),
              Text("generating '"+prompt+"' based on your drawing"),

            SizedBox(height: 50,),
            Container(
              child: LoadingIndicator(
                  indicatorType: Indicator.lineScalePulseOut, /// Required, The loading type of the widget
                  colors: _Colors,       /// Optional, The color collections
                  strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                  backgroundColor: Colors.white,      /// Optional, Background of the widget
                  pathBackgroundColor: Colors.black   /// Optional, the stroke backgroundColor
              ),
              width: MediaQuery.of(context).size.width/2,
            )
          ],
        ),
      ),
    );
  }
}
