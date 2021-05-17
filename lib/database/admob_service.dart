import 'dart:io';

class AdMobService{

  String getBannerAdUnitId() {
    // if (Platform.isIOS) {
    //   return 'ca-app-pub-3940256099942544/2934735716';
    // }
    if (Platform.isAndroid) {
      return 'ca-app-pub-3385686622811384/2896530346';
    }else
    return null;
  }

  String getInterstitialAdUnitId() {
    // if (Platform.isIOS) {
    //   return 'ca-app-pub-3940256099942544/4411468910';
    // }
    if (Platform.isAndroid) {
      return 'ca-app-pub-3385686622811384/9230946352';
    }else
    return null;
  }

  String getRewardBasedVideoAdUnitId() {
    // if (Platform.isIOS) {
    //   return 'ca-app-pub-3940256099942544/1712485313';
    // }
    if (Platform.isAndroid) {
      return 'ca-app-pub-3385686622811384/6385291168';
    }else
    return null;
  }
}