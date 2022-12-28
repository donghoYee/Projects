import 'package:flutter/material.dart';
import 'sub/drawing_page.dart';
import 'sub/prompt_page.dart';
import 'sub/wait_page.dart';
import 'sub/show_page.dart';
import 'sub/mask_page.dart';

//import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  runApp(MainPage());
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();


}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "img2img",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/draw',

        routes: {
          '/draw': (context) => DrawPage(),
          "/prompt": (context) => PromptWidget(),
          '/wait': (context) => WaitPage(),
          '/show': (context) => ShowPage(),
          '/mask': (context) => MaskPage(),
        }
    );
  }
}



