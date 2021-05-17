import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class AudiencePoll extends StatefulWidget {
  final String ans;
  AudiencePoll({this.ans});

  @override
  _AudiencePollState createState() => _AudiencePollState(ans: ans);
}

class _AudiencePollState extends State<AudiencePoll> {
  final String ans;
  _AudiencePollState({this.ans});



  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.blueGrey[200],
      title: Text("Audience Poll"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          widget.ans=='ক'?Bar(70*0.01, "A",70):widget.ans=='খ'?Bar(30*0.01, "A",30):widget.ans=='গ'?Bar(45*0.01, "A",45):Bar(25*0.01, "A",25),
          widget.ans=='ক'?Bar(50*0.01, "B",50):widget.ans=='খ'?Bar(80*0.01, "B",80):widget.ans=='গ'?Bar(60*0.01, "B",60):Bar(40*0.01, "B",40),
          widget.ans=='ক'?Bar(50*0.01, "C",50):widget.ans=='খ'?Bar(80*0.01, "C",70):widget.ans=='গ'?Bar(60*0.01, "C",60):Bar(40*0.01, "C",40),
          widget.ans=='ক'?Bar(50*0.01, "D",50):widget.ans=='খ'?Bar(40*0.01, "D",40):widget.ans=='গ'?Bar(55*0.01, "D",55):Bar(70*0.01, "D",70),
        ],
      ),
      actions: <Widget>[
        FlatButton(child: Text("Ok"),
        onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}



class Bar extends StatelessWidget {
  final double height;
  final String label;
  final int bOp;

  final int _baseDurationMs = 1000;
  final double _maxElementHeight = 100;

  Bar(this.height, this.label,this.bOp);

  @override
  Widget build(BuildContext context) {
    return PlayAnimation<double>(
      duration: Duration(milliseconds: (height * _baseDurationMs).round()),
      tween: Tween(begin: 0.0, end: height),
      builder: (context, child, value) {
        return Column(
          children: <Widget>[
            Text("$bOp"+"%"),
            Container(
              height: (1 - value) * _maxElementHeight,
            ),
            Container(
              width: 20,
              height: value * _maxElementHeight,
              color: Colors.blue,
            ),
            Text(label)
          ],
        );
      },
    );
  }
}