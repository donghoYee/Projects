import 'package:flutter/material.dart';
import 'query_page.dart';
import 'waiting_page.dart';
import 'showing_page.dart';

//import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //MobileAds.instance.initialize();
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
        title: "Image enhance",
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        initialRoute: '/query',
        routes: {
          '/query': (context) => MyApp(),
          '/wait': (context) => waitpage(),
          //'/show': (context) => ShowPage(),
        }
    );
  }
}