import 'dart:async';

import 'package:bangla_gk_quiz/screen/start_game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  String name;

  LoadingScreen({this.name});
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 1),
            () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => StartGame(name: widget.name,))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Container(
        constraints: BoxConstraints.expand(),
    decoration: BoxDecoration(
    image: DecorationImage(
    image: AssetImage("assets/quizBackground.png"),
    fit: BoxFit.cover)),
    child: Container(
      height: MediaQuery.of(context).size.width*.1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            //margin: EdgeInsets.only(top: size.width*.10),
            height: MediaQuery.of(context).size.width*.35,
            width: MediaQuery.of(context).size.width*.30,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/logo.png"),
                    fit: BoxFit.cover)),),

          Container(
            height: 20,
            width: MediaQuery.of(context).size.width*.90,
            color: Colors.orangeAccent,
            child: Center(child: Text('loading....',style: TextStyle(fontWeight: FontWeight.bold),)),
          )
        ],
      ),
    ))
    );
  }
}
