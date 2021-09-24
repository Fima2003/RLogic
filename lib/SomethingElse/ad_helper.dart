import 'dart:io';

class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5032968874937889/2660864615';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5032968874937889/4875964417';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if(Platform.isAndroid) {
      return 'ca-app-pub-5032968874937889/7372891979';
    }else if(Platform.isIOS){
      return 'ca-app-pub-5032968874937889/4563923475';
    }else{
      throw new UnsupportedError('Unsupported platform');
    }
  }
}