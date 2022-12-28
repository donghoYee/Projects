import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:open_file/open_file.dart';

class ShowPageSide extends StatefulWidget {
  const ShowPageSide({Key? key}) : super(key: key);

  @override
  _ShowPageState createState() => _ShowPageState();
}

class _ShowPageState extends State<ShowPageSide> {
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    final prompt = arguments["prompt"];
    final img_arr = arguments["img_arr"];
    final generated_image_name = arguments['generated_img_name'];
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Showing Page"),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("OUTPUT: '"+prompt+"'"),
            ),
            Image.network(
                "http://183.107.11.73:2235/generated?"+generated_image_name,
              width: MediaQuery.of(context).size.width/1.4,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("INPUT"),
            ),

            Image.memory(
              img_arr,
              width: MediaQuery.of(context).size.width/1.4,
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.save_alt),
                onPressed: (){
                  var img_url = "http://183.107.11.73:2235/generated?"+generated_image_name;
                  saveImage(img_url);
                },
              ),
            ),
          ],
        )
      ),
        backgroundColor: Color.fromARGB(250, 250, 250, 250)
    );
  }

  void saveImage(String img_url) async {
    var response = await GallerySaver.saveImage(img_url, albumName: "Img2Img");

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
