import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';

import 'modules/get_img.dart';
import 'modules/book_checker_pytorch.dart';
import 'modules/book_checker_tflite.dart';

void main() {
  getPermission();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

 release();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //final res = load_mobilenet();
    final res = load_ssd();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Module Test Page', res: res),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.res}) : super(key: key);
  final String title;
  final res;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget image = Text("nothing to show");
  int len_id = 0;
  int count = 0;
  String current_id = "";
  bool is_img = false;
  String found = "";
  List<int> img_ids = [];




  @override
  Widget build(BuildContext context) {
    getAllImgIds().then((data){
      img_ids = data;
      len_id = data.length;
      }
    );

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Text(current_id),

            image,

            is_img? ElevatedButton(
              child: Text("inference"),
                onPressed: (){
                  print("Inference Mode");
                  widget.res.then((result){
                      //print(data.runtimeType);
                    if (result==null) {
                      setState(() {
                        found = "1";
                      });
                      return;
                    }
                    getResizedImgArrFromId(img_ids[count], 224,224).then((data) {
                      if (data==null) {
                        setState(() {
                          found = "2";
                        });
                        return;
                      }
                      /*
                      run_yolov2_by_binary(data).then((returned){
                        if (returned==null) {
                          setState(() {
                            found = "4";
                          });
                          return;
                        }
                        setState(() {
                          //image = Image.file(file);
                          found = returned.toString();
                          print(returned);
                        });

                      });

                       */

                      get_temp_file(Uint8List.fromList(data)).then((file){
                        if (file==null) {
                          setState(() {
                            found = "3";
                          });
                          return;
                        }

                        run_yolov2_by_path(file.path).then((returned){
                          if (returned==null) {
                            setState(() {
                              found = "4";
                            });
                            return;
                          }
                          setState(() {
                            //image = Image.file(file);
                            found = returned.toString();
                            print(returned);
                          });

                        });

                      });

                    });

                  });
                }
            ):SizedBox(),
            Text(found),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text("next"),
        onPressed: (){
          setState(() {
            found = "";
            count ++;
            count %= len_id;
            current_id = img_ids[count].toString();
          });
          //print(img_ids);
          //print(img_ids[count]);
          getImgArrFromId(img_ids[count]).then((data){
            if (data==null){
              setState(() {
                is_img=false;
              });
              image = Text("not image");
              return;
            }
            setState(() {
             is_img=true;
              //print(data.length);
              image = Image.memory(data);

              //print(data);
            });
          });
        },
      ),
    );
  }
}

Future<File> get_temp_file(Uint8List data) async{
  final tempDir = await getTemporaryDirectory();
  File file = await File('${tempDir.path}/image.png').create();
  file.writeAsBytesSync(data);
  return file;
}



