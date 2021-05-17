import 'package:admob_flutter/admob_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bangla_gk_quiz/database/admob_service.dart';
import 'package:bangla_gk_quiz/model/score.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bangla_gk_quiz/database/score_database_helper.dart';

import 'home_page.dart';
class HighestScore extends StatefulWidget {
  @override
  _HighestScoreState createState() => _HighestScoreState();
}

class _HighestScoreState extends State<HighestScore> {
  ScoreDatabaseHelper scoreDatabaseHelper = ScoreDatabaseHelper();
  AdmobInterstitial interstitialAd;
  AdMobService adMobService = AdMobService();
  List<Score> scoreList;
  int count = 0;

  @override
  void initState(){
    super.initState();
    _initializeAd();
    interstitialAd.load();
  }
  void _showAd()async{
    interstitialAd.show();
  }

  @override
  void dispose() {
    interstitialAd.dispose();
    super.dispose();
    _showAd();
  }
  void _initializeAd(){
    interstitialAd = AdmobInterstitial(
      adUnitId: adMobService.getInterstitialAdUnitId(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        print('loaded');
        _showAd();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (scoreList == null) {
      scoreList = List<Score>();
      updateListView();
    }
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/quizBackground.png"),
                    fit: BoxFit.cover)),
            child: ListView(
              children: [

                Container(
                  margin: const EdgeInsets.only(left: 40,right: 40),
                  height: size.width * .06,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * .90,
                  decoration: BoxDecoration(
                      color: Colors.yellow[200],
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(60),
                          bottomRight: Radius.circular(60),
                          topLeft: Radius.circular(60),
                          bottomLeft: Radius.circular(60))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40,right: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('র‌্যাঙ্ক', style: TextStyle(color: Colors.black,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                            fontSize: size.width * .04)),
                        Text('খেলোয়ারের নাম', style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                            fontSize: size.width * .04)),
                        Text('আয়', style: TextStyle(color: Colors.black,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                            fontSize: size.width * .04)),
                      ],
                    ),
                  ),
                ),

                ///ListViewBuilder
                ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: count,
                    itemBuilder: (_, index) {
                      return Container(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 80,right: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${index + 1}', style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                                fontSize: size.width * .04,)),
                              Text(scoreList[index].name??'', style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                                fontSize: size.width * .04,)),
                              Text(scoreList[index].score??'', style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                                fontSize: size.width * .04,)),
                            ],
                          ),
                        ),
                      );
                    }),

                Container(
                  padding:  EdgeInsets.only(right: size.width*.2,left: size.width*.2),
                  child: Container(
                    width: 50,
                    child: FlatButton(
                        onPressed: () {
                          print(scoreList.length);
                          _deleteScores();
                        },
                        color: Colors.red,
                        child: Text('Clear', style: TextStyle(color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 18),)
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<bool> _onBackPressed() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage()),
            (Route<dynamic> route) => false);
  }

  void updateListView() {
    final Future<Database> dbFuture = scoreDatabaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Score>> scoreListFuture = scoreDatabaseHelper.getScoreList();
      scoreListFuture.then((scoreList) {
        setState(() {
          this.scoreList = scoreList;
          this.count = scoreList.length;
        });
      });
    });
  }
  void _deleteScores() async{
    await scoreDatabaseHelper.deleteScores();
    updateListView();
    //_showDialog();
  }
}