import 'package:admob_flutter/admob_flutter.dart';
import 'package:bangla_gk_quiz/screen/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize without device test ids
  Admob.initialize();
  //Admob.initialize(testDeviceIds: ['1DDF06E033A23C8D4D527F1ED987C851']);


  runApp(MyApp());
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'বাংলা কুইজ কুইজ ২০২১',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: SplashScreen(),
    );
  }
}