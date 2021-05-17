import 'dart:io';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bangla_gk_quiz/database/admob_service.dart';
import 'package:bangla_gk_quiz/screen/loadingScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../model/account.dart';
import 'highest_score.dart';
import 'package:url_launcher/url_launcher.dart';
import 'nirdeshika_page.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;
  static AudioCache musicCache;
  static AudioPlayer instance;
  final _formKey = GlobalKey<FormState>();
  AdMobService adMobService = AdMobService();
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Account> accountList;
  Account account = Account('');
  int count = 0;
  bool toggle = true;
  String name = 'default';

  void playLoopedMusic() async {
    musicCache = AudioCache(prefix: "assets/");
    instance = await musicCache.loop("audio/loopSound.mp3");
  }

  void stopMusic() {
    if (instance != null) {
      instance.stop();
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      instance.pause();
    }else{
      setState(() {
        //toggle=false;
      });
      //instance.resume();
    }
  }
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    toggle==true? playLoopedMusic():stopMusic();
    WidgetsBinding.instance.addObserver(this);
    _initializeAd();
  }
  @override
  void dispose() {
    interstitialAd.dispose();
    super.dispose();
  }
  void _initializeAd(){
    bannerSize = AdmobBannerSize.BANNER;

    interstitialAd = AdmobInterstitial(
      adUnitId: adMobService.getInterstitialAdUnitId(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
      },
    );

    interstitialAd.load();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (accountList == null) {
      accountList = List<Account>();
      updateListView();
    }
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/quizBackground.png"),
                fit: BoxFit.cover)),
        child: Container(
          margin: EdgeInsets.only(top: size.width * .01),
          height: size.width * .1,
          child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: AdmobBanner(
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
                    ),
                    Column(
                      children: [
                        RawMaterialButton(
                          onPressed: () {
                            _showDialog();
                          },
                          elevation: 2.0,
                          fillColor: Colors.blueAccent,
                          child: Icon(
                            Icons.person_rounded,
                            size: size.width * .05,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(10.0),
                          shape: CircleBorder(),
                        ),
                        Text(
                          name,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * .02,
                              decoration: TextDecoration.none),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: size.width * .05, right: size.width * .09),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      //margin: EdgeInsets.only(top: size.width*.15),
                      child: Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    setState(() {
                                      toggle=true;
                                    });
                                    stopMusic();
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NirdeshikaPage()));
                                },
                                child: Container(
                                  width: size.width * .25,
                                  height: size.width * .06,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Icon(
                                          Icons.menu_book,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'নির্দেশিকা',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * .03,
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        width: size.width*.01,
                                      )
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.orange,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                ),
                              ),
                            ),
                            SizedBox(height: size.width * .023,),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: GestureDetector(
                                onTap: () {
                                  // setState(() {
                                  //   toggle=true;
                                  // });
                                  stopMusic();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoadingScreen(
                                            name: name,
                                          )));
                                },
                                child: Container(
                                  width: size.width * .25,
                                  height: size.width * .06,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Icon(
                                          Icons.not_started,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'খেলা শুরু',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * .03,
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        width: size.width * .01,
                                      )
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    border:
                                    Border.all(color: Colors.white, width: 2),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: size.width * .023),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: GestureDetector(
                                onTap: () async{
                                  setState(() {
                                    toggle=true;
                                    stopMusic();
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HighestScore()));
                                },
                                child: Container(
                                  width: size.width * .25,
                                  height: size.width * .06,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Icon(
                                          Icons.assignment,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'সর্বোচ্চ স্কোর',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: size.width * .03,
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                          width: size.width * .01
                                      )
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    border:
                                    Border.all(color: Colors.white, width: 2),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          //margin: EdgeInsets.only(top: size.width*.10),
                          height: size.width * .30,
                          width: size.width * .25,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage("assets/logo.png"),
                                  fit: BoxFit.cover)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RawMaterialButton(
                              onPressed: () {
                                setState(() {
                                  toggle = !toggle;
                                });
                                if (toggle == false) {
                                  setState(() {
                                    stopMusic();
                                  });
                                }else{
                                  playLoopedMusic();
                                }
                              },
                              elevation: 2.0,
                              fillColor: Colors.orange,
                              child: toggle
                                  ? Icon(
                                Icons.volume_up,
                                size: size.width * .040,
                                color: Colors.white,
                              )
                                  : Icon(
                                Icons.volume_off,
                                size: size.width * .040,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.all(10.0),
                              shape: CircleBorder(),
                            ),
                            RawMaterialButton(
                              onPressed: () {
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
                                size: size.width * .040,
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
                                        'https://play.google.com/store/apps/details?id=' +
                                        'com.quiz.bangla_gk_quiz',
                                    mimeType: 'text/plain');
                              },
                              elevation: 2.0,
                              fillColor: Colors.blue,
                              child: Icon(
                                Icons.share,
                                size: size.width * .040,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.all(10.0),
                              shape: CircleBorder(),
                            )
                          ],
                        ),
                        SizedBox(height: size.width * .01,)
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    _showConfirmDialog();
  }
  _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.blue,
            scrollable: true,
            contentPadding: EdgeInsets.all(20),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "খেলোয়ার লিস্ট",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                SizedBox(
                  width: 45,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      _addPlayer();
                    },
                    child: Icon(
                      Icons.person_add,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.width * .05,
                    ))
              ],
            ),
            content: _accountListShow(),
          );
        });
  }

  _addPlayer() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.blue,
            scrollable: true,
            contentPadding: EdgeInsets.all(20),
            title: Text(
              "খেলোয়ার নিবন্ধন",
              textAlign: TextAlign.center,
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
            ),
            content: Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    TextFormField(
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          hintText: 'আপনার নাম লিখুন',
                          hintStyle: TextStyle(fontWeight: FontWeight.w400)),
                      onChanged: (val) {
                        setState(() {
                          account.name = val;
                        });
                      },
                      validator: (val) =>
                      val.isEmpty ? 'আপনার নাম লিখুন' : null,
                    ),
                    SizedBox(height: 10),
                    RaisedButton(
                      color: Colors.amber,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _save();
                        }
                      },
                      child: Text(
                        "নিবন্ধন",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _accountListShow() {
    return Container(
      height: 70,
      width: 20,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: count,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              name = accountList[index].name;
                              Navigator.pop(context);
                            });
                          },
                          child: Text(accountList[index].name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                _showUpdateDialog(accountList[index].name,
                                    accountList[index].id);
                              },
                              child: Icon(
                                Icons.edit,
                                color: Colors.green,
                              )),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * .02),
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                _showAlertDialogue(this.accountList[index]);
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ))
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  )
                ],
              ),
            );
          }),
    );
  }

  void _showAlertDialogue(Account account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Widget okButton = FlatButton(
          child: Text("হ্যাঁ"),
          onPressed: () {
            _deleteAccount(account);
          },
        );
        Widget noButton = FlatButton(
          child: Text("না"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        );
        AlertDialog alert = AlertDialog(
          title: Text("আপনি কি খেলোয়াড়টিকে ডিলিট করতে চান?"),
          actions: [okButton, noButton],
        );
        return alert;
      },
    );
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Account>> accountListFuture = databaseHelper.getAccountList();
      accountListFuture.then((accountList) {
        setState(() {
          this.accountList = accountList;
          this.count = accountList.length;
        });
      });
    });
  }

  void _deleteAccount(Account account) async {
    await databaseHelper.deleteAccount(account.id);
    Navigator.of(context).pop();
    updateListView();
    //_showDialog();
  }

  void _save() async {
    await databaseHelper.insertAccount(account);
    Navigator.of(context).pop();
    updateListView();
    //_showDialog();
  }

  void _update(int id) async {
    await databaseHelper.updateAccount(account, id);
    Navigator.of(context).pop();
    updateListView();
    //_showDialog();
  }

  _showUpdateDialog(String name, int id) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.blue,
            scrollable: true,
            contentPadding: EdgeInsets.all(20),
            title: Text(
              "খেলোয়ার সংস্করণ",
              textAlign: TextAlign.center,
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
            ),
            content: Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: name,
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          hintText: 'আপনার নাম লিখুন',
                          hintStyle: TextStyle(fontWeight: FontWeight.w400)),
                      onChanged: (val) {
                        setState(() {
                          account.name = val;
                        });
                      },
                      validator: (val) =>
                      val.isEmpty ? 'আপনার নাম লিখুন' : null,
                    ),
                    SizedBox(height: 10),
                    RaisedButton(
                      color: Colors.amber,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _update(id);
                        }
                      },
                      child: Text(
                        "নিবন্ধন",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
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
                    "গেইম থেকে বেরিয়ে যেতে চান?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.white),
                  ),
                  SizedBox(height: 40,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
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
                          child: Container(
                            width: 100,
                            height: 30,
                            child: Center(
                                child: Text(
                                  'রেটিং দিন',
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
                            setState(() {
                              stopMusic();
                            });
                            exit(0);

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

}
