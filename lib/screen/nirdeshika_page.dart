import 'package:admob_flutter/admob_flutter.dart';
import 'package:bangla_gk_quiz/data/nirdeshika_data.dart';
import 'package:bangla_gk_quiz/database/admob_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

class NirdeshikaPage extends StatefulWidget {
  @override
  _NirdeshikaPageState createState() => _NirdeshikaPageState();
}

class _NirdeshikaPageState extends State<NirdeshikaPage> {
  AdmobBannerSize bannerSize;
  AdmobInterstitial interstitialAd;
  AdMobService adMobService = AdMobService();
  NirdeshikaData nirdeshikaData = NirdeshikaData();

  @override
  void initState() {
    super.initState();
    _initializeAd();
    interstitialAd.load();
  }

  @override
  void dispose() {
    interstitialAd.dispose();
    super.dispose();
  }
  void _showAd()async{
    interstitialAd.show();
  }

  void _initializeAd(){
    bannerSize = AdmobBannerSize.FULL_BANNER;

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
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Stack(
          children:[
            Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/quizBackground.png"),
                      fit: BoxFit.cover)
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SafeArea(
                      child: Container(
                        height: size.height*.6,
                        width: size.width*.9,
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Text(nirdeshikaData.getNirdeshika(),style: TextStyle(
                                  fontSize: 20.0,decoration: TextDecoration.none,color: Colors.white,fontWeight: FontWeight.w500
                              ),),
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Visibility(
                      visible: nirdeshikaData.PreviousButtonShouldNotBeVisible(),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            nirdeshikaData.nextNirdeshika(2);
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 110,
                          child: Center(child: Text('<< Previous',style: TextStyle(color: Colors.white,fontSize: 15,decoration: TextDecoration.none),)),
                          color: Colors.orange,

                        ),
                      ),
                    ),
                    Visibility(
                      visible: nirdeshikaData.NextButtonShouldNotBeVisible(),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            nirdeshikaData.nextNirdeshika(1);
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 110,
                          child: Center(child: Text('Next >>',style: TextStyle(color: Colors.white,fontSize: 15,decoration: TextDecoration.none),)),
                          color: Colors.orange,

                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RawMaterialButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()),
                                (Route<dynamic> route) => false);
                      },
                      elevation: 2.0,
                      fillColor: Colors.red,
                      child: Icon(
                        Icons.home,
                        size: 25.0,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(10.0),
                      shape: CircleBorder(),
                    )
                  ],
                )
              ],
            )
          ]
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
}
