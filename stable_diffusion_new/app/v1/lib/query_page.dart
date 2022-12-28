import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'painter.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'waiting_page.dart';
import 'showing_page.dart';


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PainterWidget _painterWidget = new PainterWidget();
  TextEditingController _promptController = TextEditingController();
  Dio dio = new Dio();



  @override
  Widget build(BuildContext context) {
    dio.options.baseUrl = 'http://183.107.11.73:2235';
    //dio.options.
    //dio.options.connectTimeout = 5000; //5s
    //dio.options.receiveTimeout = 3000;

    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Image enhance"),
              backgroundColor: Colors.grey,
            ),
            body: Column(
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: _promptController,
                    ),
                  ),
                  color: Colors.white30,
                ),

                Container(
                  child: _painterWidget,
                  height: MediaQuery.of(context).size.width+100,
                ),
                Text("Demo Ver"),

                ElevatedButton(
                    onPressed: (){
                      Future<Uint8List> img_arr = _painterWidget.get_current_painter_state.get_memory_img;
                      img_arr.then((value){

                        //Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) {
                        //  return new Scaffold(
                        //    body: Image.memory(value),
                        //  );}));

                        Navigator.of(context).push(new MaterialPageRoute(builder: (context) => waitpage()),
                         //   arguments: {'text': _promptController.value.text}
                        );

                        Future<String> response = send_image(value, _promptController.value.text);

                        response.then((value)  {

                          var img_url = "http://183.107.11.73:2235/generated?"+value;
                          Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(
                                title: Text("showing page"),
                              ),
                              body: Column(
                                children: [
                                  Image.network(img_url),
                                  Text(value),
                                  ElevatedButton(onPressed: (){
                                    _painterWidget.get_current_painter_state.reload_controller();
                                    Navigator.of(context).pop();
                                  },
                                      child: Text("new")),

                                  ElevatedButton(onPressed: (){
                                    _painterWidget.get_current_painter_state.load_prev_controller();
                                    Navigator.of(context).pop();
                                  },
                                      child: Text("prev")),
                              ],
                              )
                            );
                          }));
                        });



                      }).catchError((error){
                        print(error);
                      });
                      //_painterWidget.get_current_painter_state.reload_controller();
                    },
                    child: Text("finish"),
                ),
              ],
            ),
            backgroundColor: Colors.grey,
          );
        }
      ),
    );
  }

  Future<String> send_image(Uint8List img_array, String prompt) async{
    try {
      final response = await dio.post(
        '/enhance', queryParameters: {'prompt': prompt}, data: (img_array),);
      return jsonDecode(response.toString())["name"];
    } on DioError catch (e){
      print(e);
    }
    return "error";
  }


  void test_send_image(Uint8List img_array, String prompt) async{
    try {
      final response = await dio.post(
          '/test', queryParameters: {'prompt': prompt}, data: (img_array),);
      print(response);
    } on DioError catch (e){
      print(e);
    }
  }

}
