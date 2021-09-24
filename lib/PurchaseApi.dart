import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rlogic/UserData.dart';

import 'constants.dart';

class PurchaseApi with ChangeNotifier{

  static Future<String> loginResult() async {
    return await Purchases.appUserID;
  }

  static Future init() async {
    try {
      await Purchases.setDebugLogsEnabled(true);
      await Purchases.setup(revenueCatApiKey);
    } catch (e) {
      print("Error occurred during PurchaseApi.init(): $e");
    }
  }

  static Future login(String appUserID) async {
    try {
      LogInResult _logInResult = await Purchases.logIn(appUserID);
      UserData.setAdSubscription(_logInResult.purchaserInfo.entitlements.active.isNotEmpty);
    } catch(e) {
      print("Error occurred during PurchaseApi.login(): $e");
    }
  }

  static Future logout() async {
    await Purchases.logOut();
    UserData.setAdSubscription(false);
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      return current == null ? [] : [current];
    } on PlatformException catch(e) {
      print("Error occurred during PurchaseApi.fetchOffers(): $e");
      return [];
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      UserData.setAdSubscription(true);
      return true;
    } catch(e) {
      print("Error occurred during PurchaseApi.purchasePackage(): $e");
      return false;
    }
  }
}