import 'dart:async';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bangla_gk_quiz/data/easyData.dart';
import 'package:bangla_gk_quiz/data/hardData.dart';
import 'package:bangla_gk_quiz/data/mediumData.dart';
import 'package:bangla_gk_quiz/database/admob_service.dart';
import 'package:bangla_gk_quiz/database/score_database_helper.dart';
import 'package:bangla_gk_quiz/model/score.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'congrats.dart';
import 'audiencePoll.dart';
import 'home_page.dart';

class StartGame extends StatefulWidget {
  String name;

  StartGame({this.name});

  @override
  _StartGameState createState() => _StartGameState();
}

class _StartGameState extends State<StartGame> with WidgetsBindingObserver{
  AdmobBannerSize bannerSize;
  AdmobReward rewardAd;
  AdMobService adMobService = AdMobService();
  static AudioPlayer audioPlayer = new AudioPlayer();
  AudioCache audioCache = new AudioCache(fixedPlayer: audioPlayer);
  static AudioCache musicCache;
  static AudioPlayer audioSound;
  bool _isConnected = true;

  void playLoopedSound() async {
    musicCache = AudioCache(prefix: "assets/");
    audioSound = await musicCache.loop("audio/sound.mp3");
  }

  void stopMusic() {
    if (audioSound != null) {
      audioSound.stop();
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      audioSound.pause();
    }else{
      setState(() { toggle=false;});
      //audioSound.resume();
    }
  }

  void _playCorrectFile() async {
    audioPlayer = await audioCache.play('correct.mp3'); // assign player here
  }

  void _playWrongFile() async {
    audioPlayer = await audioCache.play('wrong.mp3'); // assign player here
  }

  void _stopFile() {
    audioPlayer?.stop(); // stop the file
  }

  ScoreDatabaseHelper scoreDatabaseHelper = ScoreDatabaseHelper();
  Score tScore = Score('', '', 0);
  String _questionText;
  String _answerTextA;
  String _answerTextB;
  String _answerTextC;
  String _answerTextD;
  int _counter = 0;
  bool toggle = true;
  bool pressed = false;
  int _currentIndex = 0;
  String _currentScore;
  int _chooseOption = 0;
  int _currentIncome = 0;
  EasyData easyData = EasyData();
  MediumData mediumData = MediumData();
  HardData hardData = HardData();
  int timer = 30;
  String showtimer = "30";
  bool canceltimer = false;


  void starttimer() {
    const onesec = Duration(seconds: 1);
    Timer.periodic(onesec, (Timer t) {

      setState(() {
        if (timer <= 1) {
          stopMusic();
          t.cancel();
          _showTimeUpDialog();
          setState(() {
            tScore.name = widget.name;
            tScore.score = _currentScore;
            tScore.income = _currentIncome;
          });
          _save();
        } else if (canceltimer == true) {
          t.cancel();
        } else {
          timer = timer - 1;
        }
        showtimer = timer.toString();
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
  void _checkConnectivity() async {
    var result = await (Connectivity().checkConnectivity());
    if (result == ConnectivityResult.none) {
      setState(() => _isConnected = false);
    } else if (result == ConnectivityResult.mobile) {
      setState(() => _isConnected = true);
    } else if (result == ConnectivityResult.wifi) {
      setState(() => _isConnected = true);
    }
  }
  @override
  void initState() {
    super.initState();
    _initializeAd();
    _checkConnectivity();
    FirebaseAdMob.instance.initialize(appId: adMobService.getRewardBasedVideoAdUnitId());
    _initRewardedVideoAdListener();
    easyData.questionBank.shuffle();
    mediumData.questionBank.shuffle();
    hardData.questionBank.shuffle();
    pressed=false;
    WidgetsBinding.instance.addObserver(this);
  }
  // @override
  // void dispose() {
  //   interstitialAd.dispose();
  //   rewardAd.dispose();
  //   super.dispose();
  // }


  void _initRewardedVideoAdListener() {
    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("RewardedVideoAd event is $event");
      if (event == RewardedVideoAdEvent.loaded)
        RewardedVideoAd.instance.show();
      else if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          _nextQuestion();
          //_rewardPoints += rewardAmount;
        });
      }
    };
  }
  void _showRewardedAd() {
    RewardedVideoAd.instance.load(adUnitId: adMobService.getRewardBasedVideoAdUnitId()); //TODO: replace it with your own Admob Rewarded ID
  }


  void _initializeAd(){
    bannerSize = AdmobBannerSize.BANNER;
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      if (_counter == 0) {
        setState(() {
          _counter++;
        });
        _showDialog();
      }
    });
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/quizBackground.png"),
                fit: BoxFit.cover)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: MediaQuery.of(context).size.width * .02,),
                        Container(
                          width: MediaQuery.of(context).size.width * .065,
                          height: MediaQuery.of(context).size.width * .065,
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(60),
                                  bottomRight: Radius.circular(60),
                                  topLeft: Radius.circular(60),
                                  bottomLeft: Radius.circular(60))),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * .02,
                                  MediaQuery.of(context).size.width * .02),
                            ),
                            child: Icon(
                              Icons.home,
                              size: MediaQuery.of(context).size.width * .040,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              stopMusic();
                              if(_currentIndex==0) {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()),
                                        (Route<dynamic> route) => false);
                              }else{
                                _showConfirmDialog();
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 15),
                        Container(
                          width: MediaQuery.of(context).size.width * .065,
                          height: MediaQuery.of(context).size.width * .065,
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(60),
                                  bottomRight: Radius.circular(60),
                                  topLeft: Radius.circular(60),
                                  bottomLeft: Radius.circular(60))),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * .04,
                                  MediaQuery.of(context).size.width * .05),
                            ),
                            child: toggle
                                ? Icon(
                              Icons.volume_up,
                              size: MediaQuery.of(context).size.width * .040,
                              color: Colors.white,
                            )
                                : Icon(
                              Icons.volume_off,
                              size: MediaQuery.of(context).size.width * .040,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                toggle = !toggle;
                              });
                              if (toggle == false) {
                                setState(() {
                                  stopMusic();
                                  _stopFile();
                                });
                              }else{
                                playLoopedSound();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  AdmobBanner(
                    adUnitId: adMobService.getBannerAdUnitId(),
                    adSize: bannerSize,
                    listener: (AdmobAdEvent event, Map<String, dynamic> args) {},
                    onBannerCreated:
                        (AdmobBannerController controller) {
                      // Dispose is called automatically for you when Flutter removes the banner from the widget tree.
                      // Normally you don't need to worry about disposing this yourself, it's handled.
                      // If you need direct access to dispose, this is your guy!
                      // controller.dispose();
                    },
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width * .06,
                    width: MediaQuery.of(context).size.width * .24,
                    child: Center(
                        child: Text(
                          'স্কোর কার্ড',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width * .025,
                              decoration: TextDecoration.none),
                        )),
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        border: Border.all(color: Colors.orange, width: 2),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0))),
                  )
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * .01,
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .040,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .625,
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width: MediaQuery.of(context).size.width * .08,
                                  height: MediaQuery.of(context).size.width * .08,
                                  decoration: BoxDecoration(
                                    color: pressed==false?Colors.blue[800]:Colors.grey,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(60),
                                        bottomRight: Radius.circular(60),
                                        topLeft: Radius.circular(60),
                                        bottomLeft: Radius.circular(60)),
                                    border:
                                    Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      minimumSize: Size(
                                          MediaQuery.of(context).size.width * .02,
                                          MediaQuery.of(context).size.width *
                                              .02),
                                    ),
                                    child: Text(
                                      '৫০ঃ৫০',
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width * .015,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    onPressed: () {
                                      if(pressed == false){
                                        if (_chooseOption == 1) {
                                          if (easyData.questionBank[_currentIndex].ans == 'ক'||easyData.questionBank[_currentIndex].ans == 'খ') {
                                            setState(() {
                                              easyData.questionBank[_currentIndex].c='';
                                              easyData.questionBank[_currentIndex].d='';
                                            });
                                          }else if (easyData.questionBank[_currentIndex].ans == 'গ'||easyData.questionBank[_currentIndex].ans == 'ঘ') {
                                            setState(() {
                                              easyData.questionBank[_currentIndex].a='';
                                              easyData.questionBank[_currentIndex].b='';
                                            });
                                          }
                                        }else if (_chooseOption == 2) {
                                          if (mediumData.questionBank[_currentIndex].ans == 'ক'||mediumData.questionBank[_currentIndex].ans == 'খ') {
                                            setState(() {
                                              mediumData.questionBank[_currentIndex].c='';
                                              mediumData.questionBank[_currentIndex].d='';
                                            });
                                          }else if (mediumData.questionBank[_currentIndex].ans == 'গ'||mediumData.questionBank[_currentIndex].ans == 'ঘ') {
                                            setState(() {
                                              mediumData.questionBank[_currentIndex].a='';
                                              mediumData.questionBank[_currentIndex].b='';
                                            });
                                          }
                                        }else if (_chooseOption == 3) {
                                          if (hardData.questionBank[_currentIndex].ans == 'ক'||hardData.questionBank[_currentIndex].ans == 'খ') {
                                            setState(() {
                                              hardData.questionBank[_currentIndex].c='';
                                              hardData.questionBank[_currentIndex].d='';
                                            });
                                          }else if (mediumData.questionBank[_currentIndex].ans == 'গ'||mediumData.questionBank[_currentIndex].ans == 'ঘ') {
                                            setState(() {
                                              hardData.questionBank[_currentIndex].a='';
                                              hardData.questionBank[_currentIndex].b='';
                                            });
                                          }
                                        }
                                        setState(() {
                                          pressed=true;
                                        });
                                      }
                                    },
                                  )),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .030,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .1,
                                height: MediaQuery.of(context).size.width * .1,
                                decoration: BoxDecoration(
                                  color: Colors.yellow[200],
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(60),
                                      bottomRight: Radius.circular(60),
                                      topLeft: Radius.circular(60),
                                      bottomLeft: Radius.circular(60)),
                                  border: Border.all(
                                      color: Colors.blue[800], width: 5),
                                ),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width * .02,
                                        MediaQuery.of(context).size.width * .02),
                                  ),
                                  child: Text(
                                    showtimer,
                                    style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * .020,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800]),
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .030,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .08,
                                height: MediaQuery.of(context).size.width * .08,
                                decoration: BoxDecoration(
                                  color: pressed==false?Colors.blue[800]:Colors.grey,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(60),
                                      bottomRight: Radius.circular(60),
                                      topLeft: Radius.circular(60),
                                      bottomLeft: Radius.circular(60)),
                                  border:
                                  Border.all(color: Colors.white, width: 2),
                                ),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width * .02,
                                        MediaQuery.of(context).size.width * .02),
                                  ),
                                  child: Icon(
                                    Icons.people_alt,
                                    size: MediaQuery.of(context).size.width * .040,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if(pressed == false){
                                      if(_chooseOption==1){
                                        _audiencePollEasy();
                                      }else if(_chooseOption==2){
                                        _audiencePollMedium();
                                      }else if(_chooseOption==3){
                                        _audiencePollHard();
                                      }
                                      setState(() {
                                        pressed=true;
                                      });
                                    }
                                  },
                                ),
                              )
                            ]),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * .020,
                        ),
                        _questionContainer(),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * .020,
                        ),
                        Container(
                          child: Row(
                            children: [
                              _optionContainerA(),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .060,
                              ),
                              _optionContainerB(),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * .020,
                        ),
                        Container(
                          child: Row(
                            children: [
                              _optionContainerC(),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .060,
                              ),
                              _optionContainerD(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .099,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width * .50,
                    width: MediaQuery.of(context).size.width * .23,
                    decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(10.0))),
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('১৪  ৭ কোটি',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('১৩  ৩ কোটি',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('১২  ১ কোটি',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('১১  ৫০ লক্ষ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('১০  ২৫ লক্ষ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('৯  ১২ লক্ষ ৫০ হাজার',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('৮  ৬ লক্ষ ৪০ হাজার',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('৭  ৩ লক্ষ ২০ হাজার',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('৬  ১ লক্ষ ৬০ হাজার',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('৫  ৮০ হাজার',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('৪  ৪০ হাজার',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('৩  ২০ হাজার',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('২  ১০ হাজার',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('১  ৫ হাজার',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.width * .020,
                                  decoration: TextDecoration.none)),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<bool> _onBackPressed() async {
    _showConfirmDialog();
  }

  _showConfirmDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              backgroundColor: Colors.blueAccent,
              scrollable: true,
              contentPadding: EdgeInsets.all(20),
              title: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "খেলা বন্ধ করতে চান?\n আপনার বর্তমান আয় ${_currentScore??0} টাকা",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                  ),
                  SizedBox(height: 40,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () async{
                            stopMusic();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Congrats(score: _currentScore,)),
                                    (Route<dynamic> route) => false);
                          },
                          child: Container(
                            width: 100,
                            height: 30,
                            child: Center(
                                child: Text(
                                  'হ্যাঁ',
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.bold),
                                )),
                            decoration: BoxDecoration(
                                color: Colors.yellow[800],
                                borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                          )),
                      SizedBox(width: 20,),
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 100,
                            height: 30,
                            child: Center(
                                child: Text(
                                  'না',
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.bold),
                                )),
                            decoration: BoxDecoration(
                                color: Colors.yellow[800],
                                borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
  _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              backgroundColor: Colors.blueAccent,
              scrollable: true,
              contentPadding: EdgeInsets.all(20),
              title: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * .06,
                          height: MediaQuery.of(context).size.width * .06,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(60),
                                  bottomRight: Radius.circular(60),
                                  topLeft: Radius.circular(60),
                                  bottomLeft: Radius.circular(60))),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * .04,
                                  MediaQuery.of(context).size.width * .05),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              size: MediaQuery.of(context).size.width * .040,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()),
                                      (Route<dynamic> route) => false);
                            },
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .17,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow[800]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .030,
                  ),
                  Text(
                    "আপনাকে ৩০ সেকেন্ডের মধ্যে উত্তর দিতে হবে।\n আপনি কি প্রস্তুত?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .040,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              toggle=true;
                              _chooseOption = 1;
                              starttimer();
                              playLoopedSound();
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .17,
                            height: MediaQuery.of(context).size.width * .05,
                            child: Center(
                                child: Text(
                                  'Easy',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * .030, fontWeight: FontWeight.bold),
                                )),
                            decoration: BoxDecoration(
                                color: Colors.yellow[800],
                                borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                          )),
                      SizedBox(width: MediaQuery.of(context).size.width * .05),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              toggle=true;
                              _chooseOption = 2;
                              starttimer();
                              playLoopedSound();
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .17,
                            height: MediaQuery.of(context).size.width * .05,
                            child: Center(
                                child: Text(
                                  'Medium',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * .030, fontWeight: FontWeight.bold),
                                )),
                            decoration: BoxDecoration(
                                color: Colors.yellow[800],
                                borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                          )),
                      SizedBox(width: MediaQuery.of(context).size.width * .05),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              toggle=true;
                              _chooseOption = 3;
                              starttimer();
                              playLoopedSound();
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .17,
                            height: MediaQuery.of(context).size.width * .05,
                            child: Center(
                                child: Text(
                                  'Hard',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * .030, fontWeight: FontWeight.bold),
                                )),
                            decoration: BoxDecoration(
                                color: Colors.yellow[800],
                                borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                          )),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  _checkAns(String userChoice) {
    stopMusic();
    if (_chooseOption == 1) {
      if (easyData.questionBank[_currentIndex].ans == userChoice) {
        if(_currentScore !='৩ কোটি'){
          setState(() {
            canceltimer = true;
          });
          print(tScore.score);
          Timer(Duration(seconds: 0), _showCorrectDialog);
        }else{
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => Congrats(score: _currentScore,)),
                  (Route<dynamic> route) => false);
        }
      } else {
        stopMusic();
        _playWrongFile();
        _showWrongDialog('1');
        setState(() {
          canceltimer = true;
          tScore.name = widget.name;
          tScore.score = _currentScore;
          tScore.income = _currentIncome;
        });
        if (_currentIndex != 0 && _currentIndex > 5 && _currentIndex < 11) {
          setState(() {
            _currentIndex = 4;
          });
          _income();
        }
        _save();
        print(tScore.score);
      }
    } else if (_chooseOption == 2) {
      if (mediumData.questionBank[_currentIndex].ans == userChoice) {
        if(_currentScore!='৩ কোটি'){
          setState(() {
            canceltimer = true;
          });
          Timer(Duration(seconds: 0), _showCorrectDialog);
        }else{
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => Congrats(score: _currentScore,)),
                  (Route<dynamic> route) => false);
        }

      } else {
        stopMusic();
        _playWrongFile();
        _showWrongDialog('2');
        setState(() {
          canceltimer = true;
          tScore.name = widget.name;
          tScore.score = _currentScore;
          tScore.income = _currentIncome;
        });
        if (_currentIndex != 0 && _currentIndex > 5 && _currentIndex < 11) {
          setState(() {
            _currentIndex = 4;
          });
          _income();
        }
        _save();
      }
    } else if (_chooseOption == 3) {
      if (hardData.questionBank[_currentIndex].ans == userChoice) {
        if(_currentScore!='৩ কোটি'){
          setState(() {
            canceltimer = true;
          });
          Timer(Duration(seconds: 0), _showCorrectDialog);
        }else{
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => Congrats(score: _currentScore,)),
                  (Route<dynamic> route) => false);
        }

      } else {
        stopMusic();
        _playWrongFile();
        _showWrongDialog('3');
        setState(() {
          canceltimer = true;
          tScore.name = widget.name;
          tScore.score = _currentScore??'0';
          tScore.income = _currentIncome;
        });
        if (_currentIndex != 0 && _currentIndex > 5 && _currentIndex < 11) {
          setState(() {
            _currentIndex = 4;
          });
          _income();
        }
        _save();
        print(tScore.name);

      }
    }
  }

  _nextQuestion() {
    timer = 30;
    setState(() {
      _currentIndex = (_currentIndex + 1) % mediumData.questionBank.length;
    });
    _income();
    canceltimer = false;
    pressed=false;
    starttimer();
  }

  _income() {
    if (_currentIndex == 0) {
      setState(() {
        _currentScore = '0';
        _currentIncome = 0;
      });
    } else if (_currentIndex == 1) {
      setState(() {
        _currentScore = '৫ হাজার';
        _currentIncome = 5000;
      });
    } else if (_currentIndex == 2) {
      setState(() {
        _currentScore = '10 হাজার';
        _currentIncome = 10000;
      });
    } else if (_currentIndex == 3) {
      setState(() {
        _currentScore = '20 হাজার';
        _currentIncome = 20000;
      });
    } else if (_currentIndex == 4) {
      setState(() {
        _currentScore = '40 হাজার';
        _currentIncome = 40000;
      });
    } else if (_currentIndex == 5) {
      setState(() {
        _currentScore = '৮0 হাজার';
        _currentIncome = 80000;
      });
    } else if (_currentIndex == 6) {
      setState(() {
        _currentScore = '১ লক্ষ ৬০ হাজার';
        _currentIncome = 160000;
      });
    } else if (_currentIndex == 7) {
      setState(() {
        _currentScore = '৩ লক্ষ ২০ হাজার';
        _currentIncome = 320000;
      });
    } else if (_currentIndex == 8) {
      setState(() {
        _currentScore = '৬ লক্ষ ৪০ হাজার';
        _currentIncome = 640000;
      });
    } else if (_currentIndex == 9) {
      setState(() {
        _currentScore = '১২ লক্ষ ৫০ হাজার';
        _currentIncome = 1250000;
      });
    } else if (_currentIndex == 10) {
      setState(() {
        _currentScore = '২৫ লক্ষ';
        _currentIncome = 2500000;
      });
    } else if (_currentIndex == 11) {
      setState(() {
        _currentScore = '৫০ লক্ষ';
        _currentIncome = 5000000;
      });
    } else if (_currentIndex == 12) {
      setState(() {
        _currentScore = '১ কোটি';
        _currentIncome = 10000000;
      });
    } else if (_currentIndex == 13) {
      setState(() {
        _currentScore = '৩ কোটি';
        _currentIncome = 30000000;
      });
    } else {
      setState(() {
        _currentScore = '৭ কোটি';
        _currentIncome = 7000000;
      });
    }
  }

  void _save() async {
    await scoreDatabaseHelper.insertScore(tScore);
  }

  _questionContainer() {
    if (_chooseOption == 1) {
      setState(() {
        _questionText = '${easyData.questionBank[_currentIndex].questionText}';
      });
    } else if (_chooseOption == 2) {
      setState(() {
        _questionText =
        '${mediumData.questionBank[_currentIndex].questionText}';
      });
    } else if (_chooseOption == 3) {
      setState(() {
        _questionText = '${hardData.questionBank[_currentIndex].questionText}';
      });
    }
    return Container(
      height: MediaQuery.of(context).size.width * .13,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(60),
              bottomRight: Radius.circular(60),
              topLeft: Radius.circular(60),
              bottomLeft: Radius.circular(60)),
          color: Colors.blue[800]),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: ListView(
            children: [
              Text(
                _questionText ?? '',
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * .025,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _optionContainerA() {
    if (_chooseOption == 1) {
      setState(() {
        _answerTextA = '${'A.  ' + easyData.questionBank[_currentIndex].a}';
      });
    } else if (_chooseOption == 2) {
      setState(() {
        _answerTextA = '${'A.  ' + mediumData.questionBank[_currentIndex].a}';
      });
    } else if (_chooseOption == 3) {
      setState(() {
        _answerTextA = '${'A.  ' + hardData.questionBank[_currentIndex].a}';
      });
    }
    return GestureDetector(
      onTap: () {
        _checkAns('ক');
      },
      child: Container(
        height: MediaQuery.of(context).size.width * .1,
        width: MediaQuery.of(context).size.width * .28,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(60),
                bottomRight: Radius.circular(60),
                topLeft: Radius.circular(60),
                bottomLeft: Radius.circular(60)),
            color: Colors.blue[800]),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Text(
              _answerTextA ?? '',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * .025,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  _optionContainerB() {
    if (_chooseOption == 1) {
      setState(() {
        _answerTextB = '${'B.  ' + easyData.questionBank[_currentIndex].b}';
      });
    } else if (_chooseOption == 2) {
      setState(() {
        _answerTextB = '${'B.  ' + mediumData.questionBank[_currentIndex].b}';
      });
    } else if (_chooseOption == 3) {
      setState(() {
        _answerTextB = '${'B.  ' + hardData.questionBank[_currentIndex].b}';
      });
    }
    return GestureDetector(
      onTap: () {
        _checkAns('খ');
      },
      child: Container(
        height: MediaQuery.of(context).size.width * .1,
        width: MediaQuery.of(context).size.width * .28,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(60),
                bottomRight: Radius.circular(60),
                topLeft: Radius.circular(60),
                bottomLeft: Radius.circular(60)),
            color: Colors.blue[800]),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Text(
              _answerTextB ?? '',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * .025,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  _optionContainerC() {
    if (_chooseOption == 1) {
      setState(() {
        _answerTextC = '${'C.  ' + easyData.questionBank[_currentIndex].c}';
      });
    } else if (_chooseOption == 2) {
      setState(() {
        _answerTextC = '${'C.  ' + mediumData.questionBank[_currentIndex].c}';
      });
    } else if (_chooseOption == 3) {
      setState(() {
        _answerTextC = '${'C.  ' + hardData.questionBank[_currentIndex].c}';
      });
    }
    return GestureDetector(
      onTap: () {
        _checkAns('গ');
      },
      child: Container(
        height: MediaQuery.of(context).size.width * .1,
        width: MediaQuery.of(context).size.width * .28,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(60),
                bottomRight: Radius.circular(60),
                topLeft: Radius.circular(60),
                bottomLeft: Radius.circular(60)),
            color: Colors.blue[800]),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Text(
              _answerTextC ?? '',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * .025,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  _optionContainerD() {
    if (_chooseOption == 1) {
      setState(() {
        _answerTextD = '${'D.  ' + easyData.questionBank[_currentIndex].d}';
      });
    } else if (_chooseOption == 2) {
      setState(() {
        _answerTextD = '${'D.  ' + mediumData.questionBank[_currentIndex].d}';
      });
    } else if (_chooseOption == 3) {
      setState(() {
        _answerTextD = '${'D.  ' + hardData.questionBank[_currentIndex].d}';
      });
    }
    return GestureDetector(
      onTap: () {
        _checkAns('ঘ');
      },
      child: Container(
        height: MediaQuery.of(context).size.width * .1,
        width: MediaQuery.of(context).size.width * .28,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(60),
                bottomRight: Radius.circular(60),
                topLeft: Radius.circular(60),
                bottomLeft: Radius.circular(60)),
            color: Colors.blue[800]),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Text(
              _answerTextD ?? '',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * .025,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  void _audiencePollEasy(){
    showDialog(context: context,
        builder: (BuildContext context){
          return AudiencePoll(ans: easyData.questionBank[_currentIndex].ans);
        }
    );
  }
  void _audiencePollMedium(){
    showDialog(context: context,
        builder: (BuildContext context){
          return AudiencePoll(ans: mediumData.questionBank[_currentIndex].ans);
        }
    );
  }
  void _audiencePollHard(){
    showDialog(context: context,
        builder: (BuildContext context){
          return AudiencePoll(ans: hardData.questionBank[_currentIndex].ans);
        }
    );
  }

  _showCorrectDialog() {
    stopMusic();
    _playCorrectFile();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              backgroundColor: Colors.blueAccent,
              scrollable: true,
              contentPadding: EdgeInsets.all(20),
              title: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .035,
                  ),
                  Text(
                    "সঠিক উত্তর!\n আপনি এই রাউন্ড জিতেছেন।",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .035,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _stopFile();
                          playLoopedSound();
                          _nextQuestion();
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * .17,
                        height: MediaQuery.of(context).size.width * .05,
                        child: Center(
                            child: Text(
                              'পরবর্তী কুইজ',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * .020, fontWeight: FontWeight.bold),
                            )),
                        decoration: BoxDecoration(
                            color: Colors.yellow[800],
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                      )),
                ],
              ),
            ),
          );
        });
  }

  _showWrongDialog(String option) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          // Future.delayed(Duration(seconds: 2), () {
          //   Navigator.pushAndRemoveUntil(
          //       context,
          //       MaterialPageRoute(builder: (context) => Congrats(score: _currentScore,)),
          //           (Route<dynamic> route) => false);
          // });
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              backgroundColor: Colors.blueAccent,
              scrollable: true,
              contentPadding: EdgeInsets.all(20),
              title: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .035,
                  ),
                  Text(
                    "ভুল উত্তর!\n সঠিক উত্তর ${option=='1'?easyData.questionBank[_currentIndex].ans:option=='2'?mediumData.questionBank[_currentIndex].ans:hardData.questionBank[_currentIndex].ans}\n"
                        "আপনার আয় ${_currentScore??0} টাকা\n পরবর্তী রাউন্ডে যেতে হলে ভিডিও দেখতে হবে",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .035,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () async{
                           _checkConnectivity();
                           if(_isConnected){
                             _showRewardedAd();
                             Navigator.of(context).pop();
                           }
                           else{
                             _showNoInternetDialog();
                           }
                          },
                          child: Container(
                            width: 100,
                            height: 30,
                            child: Center(
                                child: Text(
                                  'নিশ্চিত',
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.bold),
                                )),
                            decoration: BoxDecoration(
                                color: Colors.yellow[800],
                                borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                          )),
                      SizedBox(width: 20,),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Congrats(score: _currentScore,)),
                                    (Route<dynamic> route) => false);
                          },
                          child: Container(
                            width: 100,
                            height: 30,
                            child: Center(
                                child: Text(
                                  'বাদ দিন',
                                  style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.bold),
                                )),
                            decoration: BoxDecoration(
                                color: Colors.yellow[800],
                                borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  _showTimeUpDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Congrats(score: _currentScore,)),
                    (Route<dynamic> route) => false);
          });
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              backgroundColor: Colors.blueAccent,
              scrollable: true,
              contentPadding: EdgeInsets.all(20),
              title: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .030,
                  ),
                  Text(
                    "সময় শেষ!\n আপনি নির্দিষ্ট সময়ের মধ্যে উত্তর দিতে পারেন নি।",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .050,
                  ),
                ],
              ),
            ),
          );
        });
  }

  _showNoInternetDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Congrats(score: _currentScore,)),
                    (Route<dynamic> route) => false);
          });
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              backgroundColor: Colors.blueGrey,
              scrollable: true,
              contentPadding: EdgeInsets.all(20),
              title: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .030,
                  ),
                  Text(
                    "আপনার ইন্টারনেট সংযোগ নেই",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * .050,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
