import 'package:admob_flutter/admob_flutter.dart';
import 'package:bangla_gk_quiz/database/admob_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'highest_score.dart';
import 'home_page.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class Congrats extends StatefulWidget {
  String score;

  Congrats({this.score});

  @override
  _CongratsState createState() => _CongratsState();
}

class _CongratsState extends State<Congrats> {
  AdmobInterstitial interstitialAd;
  AdMobService adMobService = AdMobService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeAd();
    interstitialAd.load();
  }
  void _showAd()async{
    interstitialAd.show();
  }
  void _initializeAd(){
    interstitialAd = AdmobInterstitial(
      adUnitId: adMobService.getInterstitialAdUnitId(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        _showAd();
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/congrats.png"),
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => HighestScore()));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width*.16,
                        height: MediaQuery.of(context).size.width*.06,
                        child: Center(child: Text('সর্বোচ্চ স্কোর',style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.width* .02,decoration: TextDecoration.none,fontWeight: FontWeight.w700),)),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          border: Border.all(color: Colors.white,width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Congratulations',style: TextStyle(color: Colors.yellow,fontWeight: FontWeight.bold,fontSize: MediaQuery.of(context).size.width* .07,decoration: TextDecoration.none)),
                  SizedBox(height: 40,),
                  Text('আপনি জিতেছেন ${widget.score??0} টাকা',style: TextStyle(color: Colors.white,fontSize: MediaQuery.of(context).size.width* .04,decoration: TextDecoration.none)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RawMaterialButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                              (Route<dynamic> route) => false);
                    },
                    elevation: 2.0,
                    fillColor: Colors.red,
                    child: Icon(Icons.home,size: MediaQuery.of(context).size.width * .040, color: Colors.white,
                    ),
                    padding: EdgeInsets.all(10.0),
                    shape: CircleBorder(),
                  ),
                  RawMaterialButton(
                    onPressed: () async {
                        try {
                          launch("market://details?id=" +
                              'com.quiz.bangla_gk_quiz');
                        } on PlatformException catch (e) {
                          launch(
                              "https://play.google.com/store/apps/details?id=" +
                                  "com.quiz.bangla_gk_quiz");
                        } finally {
                          launch(
                              "https://play.google.com/store/apps/details?id=" +
                                  "com.quiz.bangla_gk_quiz");
                        }
                    },
                    elevation: 2.0,

                    fillColor: Colors.orange,
                    child: Icon(
                      Icons.star,
                      size: MediaQuery.of(context).size.width * .040,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(10.0),
                    shape: CircleBorder(),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      WcFlutterShare.share(
                          sharePopupTitle: 'Share',
                          subject: '',
                          text: 'Type: Quiz game\nDownload App:\n'
                              'https://play.google.com/store/apps/details?id=' + 'com.quiz.bangla_gk_quiz',
                          mimeType: 'text/plain');
                    },
                    elevation: 2.0,
                    fillColor: Colors.blue,
                    child: Icon(
                      Icons.share,
                      size: MediaQuery.of(context).size.width * .040,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(10.0),
                    shape: CircleBorder(),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<bool> _onBackPressed() async {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false);
  }
}
