import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class PromptWidgetSide extends StatefulWidget {
  const PromptWidgetSide({Key? key}) : super(key: key);

  @override
  _PromptWidgetState createState() => _PromptWidgetState();
}

class _PromptWidgetState extends State<PromptWidgetSide> {
  TextEditingController _promptController = TextEditingController();
  double _strength = 0.8;
  double _guidence_scale = 15;
  Dio dio = new Dio();


  @override
  Widget build(BuildContext context) {
    dio.options.baseUrl = 'http://183.107.11.73:2235';
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    final img_arr = arguments["arr"];

    return Scaffold(
      appBar: AppBar(
        title: Text("Prompt Page"),
      ),
        body: Center(
          child: Column(
            children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.memory(
                      img_arr,
                      width: MediaQuery.of(context).size.width/2,
                  ),
                ),

              SizedBox(height: 50,),
              Text("Prompt: the discription of the image"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _promptController,
                    ),
                  ),
                  color: Color.fromARGB(100, 200, 200, 200),
                ),
              ),

              SizedBox(height: 50,),
              Text("Strength: how much the painting would change"),
              Slider(
                value: _strength,
                max: 1.0,
                min: 0.3,
                divisions: 30,
                label: _strength.toStringAsFixed(2),
                onChanged: (double value) {
                  setState(() {
                    _strength = value;
                  });
                },
              ),


              SizedBox(height: 50,),
              Text("Guidence: how much the prompt would matter"),
              Slider(
                value: _guidence_scale,
                max: 30,
                min: 5,
                divisions: 30,
                label: _guidence_scale.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _guidence_scale = value;
                  });
                },
              )





            ],
          ),
        ),


      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: (){
          Future<String> response = send_image(img_arr, _promptController.value.text, _strength.toStringAsFixed(2), _guidence_scale.toStringAsFixed(2));

          Navigator.pushNamed(context, '/wait',
              arguments: {'prompt': _promptController.value.text}
          );
          response.then((value) {
            Navigator.pushReplacementNamed(context, '/show',
                arguments: {'prompt': _promptController.value.text, 'img_arr':img_arr, 'generated_img_name':value}
            );
          });

        }
      )
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
}
