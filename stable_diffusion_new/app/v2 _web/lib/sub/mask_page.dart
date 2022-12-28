import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../source/image_painter.dart';
import 'package:dio/dio.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'dart:convert';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class MaskPage extends StatefulWidget {
  const MaskPage({Key? key}) : super(key: key);

  @override
  _MaskPageState createState() => _MaskPageState();
}


class _MaskPageState extends State<MaskPage> {
  var _imageKey = GlobalKey<ImagePainterState>();
  var _key = GlobalKey<ScaffoldState>();
  var exist_mask = false;

  Dio dio = new Dio();
  final _imgPainter = ImagePainter.asset(
    "assets/white.png",
    key: GlobalKey<ScaffoldState>(),
    controlsAtTop: false,
    initialColor: Color.fromARGB(10, 0, 0, 0),
    initialStrokeWidth: 40,
    colors: [],

  );
  @override
  Widget build(BuildContext context) {
    dio.options.baseUrl = 'http://183.107.11.73:2235';
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    final prompt = arguments["prompt"];
    final img_arr = arguments["img_arr"];
    final strength = arguments["strength"];
    final guidence_scale = arguments["guidence_scale"];

    final _imgPainter = ImagePainter.memory(
        img_arr,
      key: _imageKey,
      controlsAtTop: false,
      initialColor: Color.fromARGB(20, 0, 0, 0),

      initialStrokeWidth: 40,
      colors: [],
    );


    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if(isPortrait) {
      return Scaffold(
        appBar: NewGradientAppBar(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          actions: [
            IconButton(onPressed: () {
              if (_imageKey.currentState!.isEdited == false) {
                _showEmptyDialog();
                return;
              }

              _imageKey.currentState!.exportMask().then((value) {
                if (value == null)
                  return;
                var response = send_image(
                    img_arr, value, prompt, strength.toStringAsFixed(2),
                    guidence_scale.toStringAsFixed(2));
                Navigator.pushNamed(context, '/wait',
                    arguments: {'prompt': prompt}
                );
                response.then((value) {
                  if(value == "error")
                  {
                    Navigator.of(context).pop();
                    _showNetworkError();
                    return;
                  }
                  Navigator.pushReplacementNamed(context, '/show',
                      arguments: {
                        'prompt': prompt,
                        'img_arr': img_arr,
                        'generated_img_name': value
                      }
                  );
                });
              });
            },
                icon: Icon(Icons.check_sharp)
            ),
            SizedBox(width: 10,)
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .width + 50,
                child: _imgPainter,

                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      stops: [
                        0.6,
                        0.9,
                      ],
                      colors: [
                        Colors.blueGrey,
                        Colors.teal,
                      ],
                    )
                ),
              ),
            ),
            SizedBox(height: 50,),
            Text("Draw and fill the region of change\n\n"
                "          Darker = More change")
          ],
        ),
        backgroundColor: Color.fromARGB(220, 255, 255, 255),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: (MediaQuery.of(context).size.width - MediaQuery.of(context).size.height)/4,),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                child: _imgPainter,
                width: MediaQuery.of(context).size.height -80,
              ),
            ),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [
                    0.6,
                    0.9,
                  ],
                  colors: [
                    Colors.blueGrey,
                    Colors.teal,
                  ],
                )
            ),
            height: MediaQuery.of(context).size.height ,
          ),
          SizedBox(width: (MediaQuery.of(context).size.width - MediaQuery.of(context).size.height)/4,),

          Column(
            children: [
              SizedBox(height: 100,),
              Text("Draw and fill the region of change\n\n"
                  "       Darker = More change"),

              Spacer(),
              Row(
                children: [

                  IconButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.keyboard_arrow_left_outlined, size: 40,)
                  ),
                  SizedBox(width: 40,),
                  IconButton(
                      icon: Icon(Icons.check_sharp, size: 40,color: Colors.blue,),
                      onPressed: () {
                        if (_imageKey.currentState!.isEdited == false) {
                          _showEmptyDialog();
                          return;
                        }

                        _imageKey.currentState!.exportMask().then((value) {
                          if (value == null)
                            return;
                          var response = send_image(
                              img_arr, value, prompt, strength.toStringAsFixed(2),
                              guidence_scale.toStringAsFixed(2));
                          Navigator.pushNamed(context, '/wait',
                              arguments: {'prompt': prompt}
                          );
                          response.then((value) {
                            if(value == "error")
                            {
                              Navigator.of(context).pop();
                              _showNetworkError();
                              return;
                            }

                            Navigator.pushReplacementNamed(context, '/show',
                                arguments: {
                                  'prompt': prompt,
                                  'img_arr': img_arr,
                                  'generated_img_name': value
                                }
                            );
                          });
                        });

                        }


                  ),
                  SizedBox(width: 30,)
                ],
              ),
              SizedBox(height: 20,),
            ],
          )
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      ),
        backgroundColor: Color.fromARGB(220, 255, 255, 255),
    );
  }


  Future<String> send_image(Uint8List img_array,Uint8List mask_array, String prompt, String strength, String guidence_score) async{
    try {
      final response = await dio.post(
          '/inpaint', queryParameters: {'prompt': prompt, 'strength': strength, 'guidence_score': guidence_score}, data: {"img":img_array, "mask":mask_array});
      return jsonDecode(response.toString())["name"];
    } on DioError catch (e){
      print(e);
    }
    return "error";
  }

  void _showEmptyDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)
          ),
          title: new Text("Mask Empty"),
          content: SingleChildScrollView(
              child: const Text("Please specify the region you want change to happen:\n"
                  "Darker means more change in that region")),
          actions: <Widget>[
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showNetworkError() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)
          ),
          title: new Text("Connection to Server Error"),
          content: SingleChildScrollView(
              child: const Text("Check Your Internet Connection! or It could be server's fault")),
          actions: <Widget>[
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

}

