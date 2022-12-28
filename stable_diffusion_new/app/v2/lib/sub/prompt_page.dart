import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';

class PromptWidget extends StatefulWidget {
  const PromptWidget({Key? key}) : super(key: key);

  @override
  _PromptWidgetState createState() => _PromptWidgetState();
}

class _PromptWidgetState extends State<PromptWidget> {
  TextEditingController _promptController = TextEditingController();
  double _strength = 0.8;
  double _guidence_scale = 15;
  Dio dio = new Dio();


  @override
  Widget build(BuildContext context) {
    dio.options.baseUrl = 'http://183.107.11.73:2235';
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    final img_arr = arguments["arr"];
    final from_png = arguments["from_png"];
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    var generated_mask = false;

    if(isPortrait) {
      return Scaffold(
          appBar: NewGradientAppBar(
              //title: Text('RDesign'),
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

            actions: [
              IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    String prompt = _promptController.value.text;
                    if(prompt==""){
                      _showEmptyDialog();
                      return;
                    }


                    if(from_png == false) {
                      Future<String> response = send_image(
                          img_arr, _promptController.value.text,
                          _strength.toStringAsFixed(2),
                          _guidence_scale.toStringAsFixed(2));

                      Navigator.pushNamed(context, '/wait',
                          arguments: {'prompt': _promptController.value.text}
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
                              'prompt': _promptController.value.text,
                              'img_arr': img_arr,
                              'generated_img_name': value
                            }
                        );
                      });
                    }

                    else {
                      Navigator.pushNamed(context, '/mask',
                          arguments: {
                            'prompt': _promptController.value.text,
                            'strength':_strength,
                            'guidence_scale':_guidence_scale,
                            'img_arr': img_arr
                          }
                      );
                    }
                  }
              ),
              SizedBox(width: 15,)
            ],
          ),
          body: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.memory(
                        img_arr,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width / 2,
                        fit: BoxFit.contain,
                      ),
                    ),
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          stops: [
                            // 0.1,
                            // 0.4,
                            0.6,
                            0.9,
                          ],
                          colors: [
                            //Colors.yellow,
                            //Colors.red,
                            Colors.blueGrey,
                            Colors.teal,
                          ],
                        )
                    ),
                  ),
                ),

                SizedBox(height: 50,),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: _showPromptDialog,
                          icon: Icon(Icons.question_mark_rounded),
                      ),
                      //hintText: 'Hint Text',
                      labelText: 'Prompt',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    controller: _promptController,
                  ),
                ),


                SizedBox(height: 50,),
                Text("Strength: how much the painting would change"),
                Slider(
                  value: _strength,
                  max: 1.0,
                  min: 0.3,
                  divisions: 30,
                  label: ((_strength-0.3)*100/(1.0-0.3)).toStringAsFixed(2),
                  onChanged: (double value) {
                    setState(() {
                      _strength = value;
                    });
                  },
                  activeColor: Colors.blueGrey,
                  inactiveColor: Colors.blue,
                ),


                SizedBox(height: 50,),
                Text("Guidence: how much the prompt would matter"),
                Slider(
                  value: _guidence_scale,
                  max: 20,
                  min: 5,
                  divisions: 30,
                  label: ((_guidence_scale-5)*(100/(20-5))).round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _guidence_scale = value;
                    });
                  },
                  activeColor: Colors.blueGrey,
                  inactiveColor: Colors.blue,
                ),

              ],
            ),
          ),
        backgroundColor: Color.fromARGB(230, 255, 255, 255),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 8,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(
                  img_arr,
                  height: MediaQuery.of(context).size.height -8,
                  fit: BoxFit.contain,
                ),
              ),
              decoration: const BoxDecoration(
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
          SizedBox(width: 8,),
          SizedBox(
            child: Column(
              children: [
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: _showPromptDialog,
                        icon: Icon(Icons.question_mark_rounded),
                      ),
                      //hintText: 'Hint Text',
                      labelText: 'Prompt',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    controller: _promptController,
                  ),
                ),
                Text("Strength: how much the painting would change"),
                Slider(
                  value: _strength,
                  max: 1.0,
                  min: 0.3,
                  divisions: 30,
                  label: ((_strength-0.3)*100/(1.0-0.3)).toStringAsFixed(2),
                  onChanged: (double value) {
                    setState(() {
                      _strength = value;
                    });
                  },
                  activeColor: Colors.blueGrey,
                  inactiveColor: Colors.blue,
                ),


                SizedBox(height: 20,),
                Text("Guidence: how much the prompt would matter"),
                Slider(
                  value: _guidence_scale,
                  max: 20,
                  min: 5,
                  divisions: 30,
                  label: ((_guidence_scale-5)*(100/(20-5))).round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _guidence_scale = value;
                    });
                  },
                  activeColor: Colors.blueGrey,
                  inactiveColor: Colors.blue,
                ),
                Spacer(),
                Row(
                  children: [
                    Spacer(),
                    IconButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.keyboard_arrow_left_outlined, size: 40,)
                    ),
                    SizedBox(width: 20,),
                    IconButton(
                        icon: Icon(Icons.check_sharp, size: 40,color: Colors.blue,),
                        onPressed: () {
                          String prompt = _promptController.value.text;
                          if(prompt==""){
                            _showEmptyDialog();
                            return;
                          }

                          if(from_png == false) {
                            Future<String> response = send_image(
                                img_arr, _promptController.value.text,
                                _strength.toStringAsFixed(2),
                                _guidence_scale.toStringAsFixed(2));

                            Navigator.pushNamed(context, '/wait',
                                arguments: {'prompt': _promptController.value.text}
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
                                    'prompt': _promptController.value.text,
                                    'img_arr': img_arr,
                                    'generated_img_name': value
                                  }
                              );
                            });
                          }

                          else {
                            Navigator.pushNamed(context, '/mask',
                                arguments: {
                                  'prompt': _promptController.value.text,
                                  'strength':_strength,
                                  'guidence_scale':_guidence_scale,
                                  'img_arr': img_arr
                                }
                            );
                          }

                        }
                    ),
                    SizedBox(width: 30,)
                  ],
                ),
                SizedBox(height: 10,),

              ],
            ),
            width: MediaQuery.of(context).size.width-MediaQuery.of(context).size.height-20,
          )
        ],
      ),
      backgroundColor: Color.fromARGB(230, 255, 255, 255),
    );

  }

  Future<String> send_image(Uint8List img_array, String prompt, String strength, String guidence_score) async{
    try {
      final response = await dio.post(
        '/enhance', queryParameters: {'prompt': prompt, 'strength': strength, 'guidence_score': guidence_score}, data: (img_array));
      return jsonDecode(response.toString())["name"];
    } on DioError catch (e){
      print(e);
    }
    return "error";
  }


  void _showPromptDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)
          ),
          title: new Text("Prompt"),
          content: SingleChildScrollView(child: const Text(
              "Enter description of your image\nEx) fantasy painting of a landscape")),
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
    void _showEmptyDialog() {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)
            ),
            title: new Text("Empty"),
            content: SingleChildScrollView(
                child: const Text("Your prompt is empty")),
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

