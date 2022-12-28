import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../source/image_painter.dart';


import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'en_text_delegate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'prompt_page.dart';


class DrawPageSide extends StatefulWidget {
  @override
  _DrawPageState createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPageSide> {
  var _imageKey = GlobalKey<ImagePainterState>();
  var _key = GlobalKey<ScaffoldState>();
  ImagePicker _picker = ImagePicker();
  int init_time = 0;

  ImagePainter _imgPainter = ImagePainter.asset(
    "assets/white.png",
    key: GlobalKey<ImagePainterState>(),
    scalable: true,
    initialStrokeWidth: 2,
    textDelegate: DutchTextDelegate(),
    initialColor: Colors.blue,
    initialPaintMode: PaintMode.freeStyle,
    controlsAtTop: true,
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
    await GallerySaver.saveImage(fullPath, albumName: "Img2Img");
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
            initialStrokeWidth: 2,
            textDelegate: DutchTextDelegate(),
            initialColor: Colors.blue,
            initialPaintMode: PaintMode.freeStyle,
            controlsAtTop: true,
          );
          init_time += 1;
        });
      }



    return Scaffold(
      key: _key,
      //appBar: AppBar(
      //  title: const Text("Drawing Page"),
      //),
      body: Column(
        children: [
        Container(
          child: _imgPainter,
          height: MediaQuery.of(context).size.width+50,
        ),
        SizedBox(height: 10,),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.save_alt, size: 40,),
                onPressed: saveImage,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.upload_file,size: 40,),
                onPressed: () {
                    pick_image().then((value) {
                      if(value == null){
                        print("value is null");
                        return;
                      }
                      if(value.path == null){
                        print("path is null");
                        return;
                      }
                      Future<CroppedFile?> croppedFile = crop_image(value.path);
                      croppedFile.then((value) {
                        if(value == null){
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
                              initialStrokeWidth: 2,
                              textDelegate: DutchTextDelegate(),
                              initialColor: Colors.blue,
                              initialPaintMode: PaintMode.freeStyle,
                              controlsAtTop: true,
                            );
                          });
                        });

                      });
                    });
                }

              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
              icon: const Icon(Icons.restart_alt,size: 40,),
              onPressed: () {
               setState(() {
                 _imageKey = GlobalKey<ImagePainterState>();
                 _key = GlobalKey<ScaffoldState>();
                  _imgPainter  = ImagePainter.asset(
                  "assets/white.png",
                    key: _imageKey,
                  scalable: true,
                  initialStrokeWidth: 2,
                  textDelegate: DutchTextDelegate(),
                    initialColor: Colors.blue,
                  initialPaintMode: PaintMode.freeStyle,
                  controlsAtTop: true,
                );
               });
              }

              ),
            ),

          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )

      ]
      ),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.check),
      onPressed: (){
          get_image_arr().then((value) {
            if(value == null){
              print("value is null");
              return;
            }
            //print(value.length);
            Navigator.pushNamed(context, '/prompt',
                arguments: {'arr': value}
            );
          });
      },
    ),
      backgroundColor: Color.fromARGB(250, 250, 250, 250),
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
}
