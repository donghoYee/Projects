import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:open_file/open_file.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';


class ShowPage extends StatefulWidget {
  const ShowPage({Key? key}) : super(key: key);

  @override
  _ShowPageState createState() => _ShowPageState();
}

class _ShowPageState extends State<ShowPage> {
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    final prompt = arguments["prompt"];
    final img_arr = arguments["img_arr"];
    final generated_image_name = arguments['generated_img_name'];


    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

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
                icon: const Icon(Icons.save_alt),
                onPressed: () {
                  var img_url = "http://183.107.11.73:2235/generated?" +
                      generated_image_name;
                  saveImage(img_url);
                },
              ),
              SizedBox(width: 15,)
            ],
          ),
          body: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.memory( //input
                        img_arr,
                        width: MediaQuery.of(context).size.width / 2.0,
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
                            Colors.grey,
                          ],
                        )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_downward_rounded, size: 40,color: Colors.white,),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network( //output
                        "http://183.107.11.73:2235/generated?" +
                            generated_image_name,
                        width: MediaQuery.of(context).size.width -32,
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
                            Colors.lightBlueAccent,
                            Colors.blue,
                          ],
                        )
                    ),
                  ),

                ],
              )
          ),
          backgroundColor: Color.fromARGB(220, 250, 250, 250)
      );
    }


    return Scaffold( //landscape
        body: Center(
            child: Row(
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.memory( //drawn
                      img_arr,
                      width: MediaQuery.of(context).size.width / 2.0 - 64,
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
                          Colors.grey,
                        ],
                      )
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height/2-20,),
                    Icon(Icons.arrow_right, size: 40, color: Colors.white,),
                    Spacer(),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_left, size: 40, color: Colors.black,),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.save_alt, size: 40, color: Colors.black,),
                      onPressed: () {
                        var img_url = "http://183.107.11.73:2235/generated?" +
                            generated_image_name;
                        saveImage(img_url);
                      },
                    ),
                    SizedBox(height: 15,),

                  ],
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network( //generated
                      "http://183.107.11.73:2235/generated?" +
                          generated_image_name,
                        width: MediaQuery.of(context).size.width / 2.0 - 64,
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
                          Colors.blue,
                          Colors.lightBlueAccent,
                        ],
                      )
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            )
        ),
        backgroundColor: Color.fromARGB(220, 250, 250, 250)
    );
  }

  void saveImage(String img_url) async {
    var response = await GallerySaver.saveImage(img_url, albumName: "ADesign");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[700],
        padding: const EdgeInsets.only(left: 10),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text("Image Exported successfully on Album Img2Img.",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

}
