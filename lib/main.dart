import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:provider/provider.dart';

import 'package:rlogic/MainPage.dart';
import 'package:rlogic/Play/Games/4Digits/4Digits.dart';
import 'package:rlogic/Play/PlayPage.dart';
import 'package:rlogic/Play/Games/BullsCows/Bulls_Cows.dart';
import 'package:rlogic/Play/Games/Skyscrapers/Skyscrapers.dart';
import 'package:rlogic/ThemeSwitcher/config.dart';
import 'package:rlogic/UserData.dart';

import 'FirebaseNotifier.dart';
import 'PurchaseApi.dart';
List<String> testDeviceIds = ['AADC099711B235E9D06E260CFF4F5B29'];
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  RequestConfiguration requestConfiguration = RequestConfiguration(testDeviceIds: testDeviceIds);
  MobileAds.instance.updateRequestConfiguration(requestConfiguration);

  await PurchaseApi.init();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await UserData.init();

  UserData.setTheme(UserData.getTheme() ?? "Light");

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    UserData.setSignInStatus(false);
    currentTheme.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child: MaterialApp(
        title: 'RLogic',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xffF1E3CB),
          primaryColorDark: const Color(0xff581C0C),
          primaryColorLight: const Color(0xffCA5116),
          accentColor: const Color(0xffF9B384),
          buttonColor: const Color(0xff581C0C),
          scaffoldBackgroundColor: const Color(0xffF1E3CB),
          textTheme: TextTheme(
            headline1: TextStyle(
              color: const Color(0xffAEB8C4),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 20,
              fontWeight: FontWeight.w300,
            ),
            headline2: TextStyle(
              color: const Color(0xffCA5116),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 25,
              fontWeight: FontWeight.w500,
            ),
            headline3: TextStyle(
              color: const Color(0xff581C0C),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
            headline4: TextStyle(
              color: const Color(0xff581C0C),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 25,
              fontWeight: FontWeight.w500,
            ),
            headline5: TextStyle(
              color: const Color(0xffF1E3CB),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
            headline6: TextStyle(
              color: const Color(0xffCA5116),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 80,
              fontWeight: FontWeight.w900,
            ),
            button: TextStyle(
              color: const Color(0xffF1E3CB),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.normal,
              fontSize: 28,
            ),
            caption: TextStyle(
              color: const Color(0xff581C0C),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 25
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xff581C0C),
            iconTheme: IconThemeData(
              color: const Color(0xffF1E3CB),
              size: 30.0,
              opacity: 1.0
            ),
            titleTextStyle: TextStyle(
              color: const Color(0xffF1E3CB),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            )
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColorLight: const Color(0xff9CA6B8),
          primaryColor: const Color(0xff05263b),
          primaryColorDark: const Color(0xff163B50),
          accentColor: const Color(0xffAEB8C4),
          scaffoldBackgroundColor: const Color(0xff05263b),
          buttonColor: const Color(0xff163B50),
          textTheme: TextTheme(
            headline1: TextStyle(
              color: const Color(0xff05263b),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
            headline2: TextStyle(
              color: const Color(0xffAEB8C4),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 25,
              fontWeight: FontWeight.w500,
            ),
            headline3: TextStyle(
              color: const Color(0xffAEB8C4),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
            headline4: TextStyle(
              color: const Color(0xffAEB8C4),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 25,
              fontWeight: FontWeight.w500,
            ),
            headline5: TextStyle(
              color: const Color(0xff9CA6B8),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
            headline6: TextStyle(
              color: const Color(0xffAEB8C4),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 80,
              fontWeight: FontWeight.w900,
            ),
            button: TextStyle(
              color: const Color(0xffAEB8C4),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.normal,
              fontSize: 28,
            ),
            caption: TextStyle(
              color: const Color(0xff163B50),
              fontSize: 25,
              fontFamily: "Lato",
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xff163B50),
            iconTheme: IconThemeData(
              color: const Color(0xffAEB8C4),
              size: 30.0,
              opacity: 1
            ),
            titleTextStyle: TextStyle(
              color: const Color(0xffAEB8C4),
              fontFamily: 'Lato',
              fontStyle: FontStyle.normal,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            )
          ),
        ),
        themeMode: UserData.getTheme()  == null
            ? ThemeMode.light
            : UserData.getTheme() == "Light" ? ThemeMode.light : ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => MultiProvider(
              providers: [
                ChangeNotifierProvider<FirebaseNotifier>(
                  create: (_) => FirebaseNotifier(),
                ),
              ],
              child:MainPage()),
          '/Play': (context) => PlayPage(),
          '/Play/Bulls&Cows': (context) => BullCow(),
          '/Play/4 Digits': (context) => Digits(),
          '/Play/SkyScrapers': (context) => SkyScrapers(),
        },
      ),
    );
  }
}
