import 'package:shared_preferences/shared_preferences.dart';

class UserData{
  static late SharedPreferences _preferences;

  static const themeKey = "Theme";

  static const bullsCowsHidden = "Bulls & Cows Hidden number";
  static const bullsCowsAttempts = "Bulls & Cows Attempts";
  static const bullsCowsRepeatedGame = "Bulls & Cows repeated Game";
  static const bullsCowsHighScoreOfTries = "Highest Score in Bulls and Cows";
  static const bullsCowsTries = "Tries in current game";

  static const digitsNumber = "4 Digits";

  static const ssSets = "SkyScrapers' Settings";
  static const ssRestartedTimes = "SkyScrapers' times game was repeated";
  static const ssFastestTime4 = "SkyScrapers' highest time for 4x4 field";
  static const ssFastestTime5 = "SkyScrapers' highest time for 5x5 field";
  static const ssFastestTime6 = "SkyScrapers' highest time for 6x6 field";

  static const signedInStatus = "Signed In";

  static const adSubscription = "Purchased \"Remove Ads\"";

  static Future setAdSubscription(bool subscribed) async =>
      await _preferences.setBool(adSubscription, subscribed);

  static getAdSubscription() => _preferences.getBool(adSubscription);

  static Future setSignInStatus(bool theme) async =>
      await _preferences.setBool(signedInStatus, theme);

  static getSignInStatus() => _preferences.getBool(signedInStatus);

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setTheme(String theme) async =>
    await _preferences.setString(themeKey, theme);

  static getTheme() => _preferences.getString(themeKey);


  // SharedPreferences for Bulls and Cows
  static Future setHiddenNumber(int number) async =>
      await _preferences.setInt(bullsCowsHidden, number);

  static getHiddenNumber() => _preferences.getInt(bullsCowsHidden);

  static Future setAttempts(List<String> atmps) async =>
      await _preferences.setStringList(bullsCowsAttempts, atmps);

  static getAttempts() => _preferences.getStringList(bullsCowsAttempts);

  static Future setBullsCowsRepeatedGame(int repeats) async =>
      await _preferences.setInt(bullsCowsRepeatedGame, repeats);

  static getBullsCowsRepeatedGame() => _preferences.getInt(bullsCowsRepeatedGame);

  static Future setBullsCowsHighScore(int tries) async =>
      await _preferences.setInt(bullsCowsHighScoreOfTries, tries);

  static getBullsCowsHighScore() => _preferences.getInt(bullsCowsHighScoreOfTries);


  // SharedPreferences for 4Digits
  static Future setDigits(String numbers) async =>
      await _preferences.setString(digitsNumber, numbers);

  static getDigits() => _preferences.get(digitsNumber);


  // SharedPreferences for SkyScrapers
  static Future setSSSettings(String settings) async =>
      await _preferences.setString(ssSets, settings);

  static String? getSSSettings() => _preferences.getString(ssSets);

  static Future setSSRestarted(int restarted) async =>
      await _preferences.setInt(ssRestartedTimes, restarted);

  static getSSRestarted() => _preferences.getInt(ssRestartedTimes);

  static Future setSSHighestTime4(int time) async =>
      _preferences.setInt(ssFastestTime4, time);

  static getHighestTime4() => _preferences.getInt(ssFastestTime4);

  static Future setSSHighestTime5(int time) async =>
      _preferences.setInt(ssFastestTime5, time);

  static getHighestTime5() => _preferences.getInt(ssFastestTime5);

  static Future setSSHighestTime6(int time) async =>
      _preferences.setInt(ssFastestTime6, time);

  static getHighestTime6() => _preferences.getInt(ssFastestTime6);
}