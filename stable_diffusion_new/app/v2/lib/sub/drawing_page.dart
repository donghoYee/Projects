import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../source/image_painter.dart';


import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'en_text_delegate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'prompt_page.dart';


class DrawPage extends StatefulWidget {
  @override
  _DrawPageState createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  bool from_png = false;

  var _imageKey = GlobalKey<ImagePainterState>();
  var _key = GlobalKey<ScaffoldState>();
  ImagePicker _picker = ImagePicker();
  int init_time = 0;

  ImagePainter _imgPainter = ImagePainter.asset(
    "assets/white.png",
    key: GlobalKey<ImagePainterState>(),
    scalable: true,
    initialStrokeWidth: 15,
    textDelegate: DutchTextDelegate(),
    initialColor: Colors.black,
    initialPaintMode: PaintMode.freeStyle,
    controlsAtTop: false,
  );

  void saveImage() async {
    final image = await _imageKey.currentState!.exportImage();
    //print(image.runtimeType);
    final directory = (await getApplicationDocumentsDirectory()).path;
    await Directory('$directory/sample').create(recursive: true);
    final fullPath =
        '$directory/sample/${DateTime.now().millisecondsSinceEpoch}.png';
    final imgFile = File('$fullPath');
    imgFile.writeAsBytesSync(image!.cast());
    await GallerySaver.saveImage(fullPath, albumName: "ADesign");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[700],
        padding: const EdgeInsets.only(left: 10),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Image Exported successfully.",
                style: TextStyle(color: Colors.white)),
            TextButton(
              onPressed: () => OpenFile.open("$fullPath"),
              child: Text(
                "Open",
                style: TextStyle(
                  color: Colors.blue[200],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> get_image_arr() async{
    return await _imageKey.currentState!.exportImage();
  }

  @override
  Widget build(BuildContext context) {
    if(init_time == 0)
      {
        setState(() {
          _imageKey = GlobalKey<ImagePainterState>();
          _key = GlobalKey<ScaffoldState>();
          _imgPainter = ImagePainter.asset(
            "assets/white.png",
            key: _imageKey,
            scalable: true,
            initialStrokeWidth: 15,
            textDelegate: DutchTextDelegate(),
            initialColor: Colors.black,
            initialPaintMode: PaintMode.freeStyle,
            controlsAtTop: false,

          );
          init_time += 1;
        });
      }

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if(isPortrait) {
      return Scaffold(
        key: _key,
        appBar: NewGradientAppBar(
          title: Text('ADesign'),
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          actions: [

            IconButton(
              icon: const Icon(Icons.save_alt,color: Colors.white,),
              onPressed: saveImage,
            ),

            IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _imageKey = GlobalKey<ImagePainterState>();
                    _key = GlobalKey<ScaffoldState>();
                    _imgPainter = ImagePainter.asset(
                      "assets/white.png",
                      key: _imageKey,
                      scalable: true,
                      initialStrokeWidth: 15,
                      textDelegate: DutchTextDelegate(),
                      initialColor: Colors.black,
                      initialPaintMode: PaintMode.freeStyle,
                      controlsAtTop: false,
                      
                    );
                    from_png = false;
                  });
                }
            ),


            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                get_image_arr().then((value) {
                  if (value == null) {
                    print("value is null");
                    return;
                  }
                  //print(value.length);
                  Navigator.pushNamed(context, '/prompt',
                      arguments: {'arr': value, 'from_png':from_png}
                  );
                });
              },
            ),

            SizedBox(width: 10,),
          ],
        ),
        body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  child: _imgPainter,
                  height: MediaQuery.of(context).size.width + 50,
                  //color: Colors.grey,
                  decoration: BoxDecoration(
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
              SizedBox(height: 20,),
              Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.upload, size: 40,color: Colors.white,),
                      onPressed: () {
                        pick_image().then((value) {
                          if (value == null) {
                            print("value is null");
                            return;
                          }
                          if (value.path == null) {
                            print("path is null");
                            return;
                          }
                          Future<CroppedFile?> croppedFile = crop_image(value
                              .path);
                          croppedFile.then((value) {
                            if (value == null) {
                              return;
                            }
                            value.readAsBytes().then((value) {
                              setState(() {
                                _imageKey = GlobalKey<ImagePainterState>();
                                _key = GlobalKey<ScaffoldState>();
                                _imgPainter = ImagePainter.memory(
                                  value,
                                  key: _imageKey,
                                  
                                  scalable: true,
                                  initialStrokeWidth: 15,
                                  textDelegate: DutchTextDelegate(),
                                  initialColor: Colors.black,
                                  initialPaintMode: PaintMode.freeStyle,
                                  controlsAtTop: false,
                                  
                                );
                                from_png = true;
                              });
                            });
                          });
                        });
                      }

                  ),

                  IconButton(
                    icon: const Icon(Icons.camera_alt, size: 40,color: Colors.white,),
                      onPressed: () {
                        pick_image_camera().then((value) {
                          if (value == null) {
                            print("value is null");
                            return;
                          }
                          if (value.path == null) {
                            print("path is null");
                            return;
                          }
                          Future<CroppedFile?> croppedFile = crop_image(value
                              .path);
                          croppedFile.then((value) {
                            if (value == null) {
                              return;
                            }
                            value.readAsBytes().then((value) {
                              setState(() {
                                _imageKey = GlobalKey<ImagePainterState>();
                                _key = GlobalKey<ScaffoldState>();
                                _imgPainter = ImagePainter.memory(
                                  value,
                                  key: _imageKey,
                                  scalable: true,
                                  initialStrokeWidth: 15,
                                  textDelegate: DutchTextDelegate(),
                                  initialColor: Colors.black,
                                  initialPaintMode: PaintMode.freeStyle,
                                  controlsAtTop: false,
                                );
                                from_png = true;
                              });
                            });
                          });
                        });
                      },
                  ),
                  //Spacer(),
                  //SizedBox(width: 30,),

                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              )

            ]
        ),

        backgroundColor: Color.fromARGB(200, 250, 250, 250),
      );
    }

    return Scaffold( //Landscape mode
      key: _key,
      //appBar: AppBar(
      //  title: const Text("Drawing Page"),
      //),
      body: Row(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width-MediaQuery.of(context).size.height)/2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                      icon: const Icon(Icons.save_alt, size: 40,color: Colors.white,),
                      onPressed: saveImage,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                        icon: const Icon(Icons.upload, size: 40,color: Colors.white,),
                        onPressed: () {
                          pick_image().then((value) {
                            if (value == null) {
                              print("value is null");
                              return;
                            }
                            if (value.path == null) {
                              print("path is null");
                              return;
                            }
                            Future<CroppedFile?> croppedFile = crop_image(value
                                .path);
                            croppedFile.then((value) {
                              if (value == null) {
                                return;
                              }
                              value.readAsBytes().then((value) {
                                setState(() {
                                  _imageKey = GlobalKey<ImagePainterState>();
                                  _key = GlobalKey<ScaffoldState>();
                                  _imgPainter = ImagePainter.memory(
                                    value,
                                    key: _imageKey,
                                    scalable: true,
                                    initialStrokeWidth: 15,
                                    textDelegate: DutchTextDelegate(),
                                    initialColor: Colors.black,
                                    initialPaintMode: PaintMode.freeStyle,
                                    controlsAtTop: false,
                                  );
                                  from_png = true;
                                });
                              });
                            });
                          });
                        }

                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 40,color: Colors.white,),
                      onPressed: () {
                        pick_image_camera().then((value) {
                          if (value == null) {
                            print("value is null");
                            return;
                          }
                          if (value.path == null) {
                            print("path is null");
                            return;
                          }
                          Future<CroppedFile?> croppedFile = crop_image(value
                              .path);
                          croppedFile.then((value) {
                            if (value == null) {
                              return;
                            }
                            value.readAsBytes().then((value) {
                              setState(() {
                                _imageKey = GlobalKey<ImagePainterState>();
                                _key = GlobalKey<ScaffoldState>();
                                _imgPainter = ImagePainter.memory(
                                  value,
                                  key: _imageKey,
                                  scalable: true,
                                  initialStrokeWidth: 15,
                                  textDelegate: DutchTextDelegate(),
                                  initialColor: Colors.black,
                                  initialPaintMode: PaintMode.freeStyle,
                                  controlsAtTop: false,
                                );
                                from_png = true;
                              });
                            });
                          });
                        });
                      },
                    ),
                  ),

                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                        icon: const Icon(Icons.delete, size: 40,),
                        onPressed: () {
                          setState(() {
                            _imageKey = GlobalKey<ImagePainterState>();
                            _key = GlobalKey<ScaffoldState>();
                            _imgPainter = ImagePainter.asset(
                              "assets/white.png",
                              key: _imageKey,
                              scalable: true,
                              initialStrokeWidth: 15,
                              textDelegate: DutchTextDelegate(),
                              initialColor: Colors.black,
                              initialPaintMode: PaintMode.freeStyle,
                              controlsAtTop: false,
                            );
                            from_png = false;
                          });
                        }

                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: IconButton(
                      icon: const Icon(Icons.check_sharp, size: 40,color: Colors.blueGrey,),
                      onPressed: () {
                        get_image_arr().then((value) {
                          if (value == null) {
                            print("value is null");
                            return;
                          }
                          //print(value.length);
                          Navigator.pushNamed(context, '/prompt',
                              arguments: {'arr': value, 'from_png':from_png}
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,0),
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    child: _imgPainter,
                    width: MediaQuery.of(context).size.height -80,
                    //color: Colors.grey,
                  ),
                ),
                decoration: BoxDecoration(
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


          ]
      ),
      backgroundColor: Color.fromARGB(200, 250, 250, 250),
    );



  }
  Future<XFile?> pick_image() async{
    //print("crossed here");
    return  await _picker.pickImage(source: ImageSource.gallery);
  }

  Future<CroppedFile?> crop_image (String path) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop your Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
        IOSUiSettings(
          title: 'Crop your Image',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
  }

  Future<XFile?> pick_image_camera() async{
    //print("crossed here");
    return  await _picker.pickImage(source: ImageSource.camera);
  }

}