import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class WaitPage extends StatefulWidget {
  const WaitPage({Key? key}) : super(key: key);

  @override
  _WaitPageState createState() => _WaitPageState();
}

class _WaitPageState extends State<WaitPage> {
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


    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if(isPortrait) {
      return Scaffold(

        body: Center(
          child: Column(
            children: [
              SizedBox(height: 250,),
              Text("Generating '" + prompt + "' based on your drawing"),

              SizedBox(height: 50,),
              Container(
                child: LoadingIndicator(
                    indicatorType: Indicator.lineScalePulseOut,

                    /// Required, The loading type of the widget
                    colors: _Colors,

                    /// Optional, The color collections
                    strokeWidth: 2,

                    /// Optional, The stroke of the line, only applicable to widget which contains line
                    //backgroundColor: Colors.white,

                    /// Optional, Background of the widget
                    pathBackgroundColor: Colors.black

                  /// Optional, the stroke backgroundColor
                ),
                width: MediaQuery
                    .of(context)
                    .size
                    .width / 2,
              )
            ],
          ),
        ),
        backgroundColor: Color.fromARGB(220, 255, 255, 255),
      );
    }

    return Scaffold( //landscape mode
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 50,),
            Text("Generating '" + prompt + "' based on your drawing"),

            SizedBox(height: 50,),
            Container(
              child: LoadingIndicator(
                  indicatorType: Indicator.lineScalePulseOut,

                  /// Required, The loading type of the widget
                  colors: _Colors,

                  /// Optional, The color collections
                  strokeWidth: 2,

                  /// Optional, The stroke of the line, only applicable to widget which contains line
                 // backgroundColor: Color.fromARGB(0, 255, 255, 255),

                  /// Optional, Background of the widget
                  pathBackgroundColor: Colors.black

                /// Optional, the stroke backgroundColor
              ),
              width: MediaQuery.of(context).size.height / 2,
            )
          ],
        ),
      ),
        backgroundColor: Color.fromARGB(220, 255, 255, 255)
    );
  }
}
