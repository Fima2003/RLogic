import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:rlogic/Play/Games/4Digits/digits.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:rlogic/UserData.dart';
import 'package:rlogic/SomethingElse/ad_helper.dart';

class Digits extends StatefulWidget {
  const Digits();

  @override
  _DigitsState createState() => _DigitsState();
}

class _DigitsState extends State<Digits>  with WidgetsBindingObserver{

  late List<int> numerals;

  String expression = "";

  String expressionToShow = "";

  String expressionToCheck = "";

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  int timesRestarted = 0;

  List<bool> pressed = [false, false, false, false];

  List<String> operators = ["+", "-", "/", "*", "\u221a", "^", "(", "=", ")"];

  List<String> superScriptsPf = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];

  bool superscript = false, openedParentheses = false;

  dynamic to(int index){
    String number = UserData.getDigits();
    return int.tryParse(number[index]);
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    numerals = (UserData.getDigits() == null)
      ? generateRandom()
      : List.generate(4, (index) => to(index));
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if(state == AppLifecycleState.paused){
      closed();
      print("paused");
    }

    if(state == AppLifecycleState.inactive){
      closed();
      print("inactive");
    }

    if(state == AppLifecycleState.detached){
      print("detached");
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    print("disposed");
    super.dispose();
  }

  void closed(){
    String number = "";
    for(final numeral in numerals){
      number += numeral.toString();
    }
    UserData.setDigits(number);
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          this._interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              // Navigator.of(context).popAndPushNamed("Play/Bulls&Cows");
            },
          );
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _snackBar(BuildContext context, String text){
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
        SnackBar(
          content: Text(text, style: Theme.of(context).textTheme.headline1),
          elevation: 5,
          duration: Duration(milliseconds: 1000),
        )
    );
  }

  showWinDialog(BuildContext context){

    Size mq = MediaQuery.of(context).size;

    Widget cool = MaterialButton(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Text("Cool!", style: Theme.of(context).textTheme.button)
      ),
      color: Theme.of(context).buttonColor,
      onPressed: (){
        Navigator.of(context).pop();
      },
    );

    Widget again = MaterialButton(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Text("Play Again", style: Theme.of(context).textTheme.button)
      ),
      color: Theme.of(context).buttonColor,
      onPressed: (){
        if(_isInterstitialAdReady){
          if (UserData.getAdSubscription() == false) _interstitialAd?.show();
          _isInterstitialAdReady = false;
        }
        for(int i = 0; i < pressed.length; i++){
          pressed[i] = false;
        }
        numerals = generateRandom();
        expression = "";
        expressionToShow = "";
        Navigator.of(context).pop();
        setState(() {});
      },
    );

    AlertDialog win () {
      return new AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Great!",
          style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: mq.width*0.07),
        ),
        content: Text(
          "Your equality is correct!",
          style: UserData.getTheme() == "Light"
              ? Theme.of(context).textTheme.headline2!.copyWith(color: Theme.of(context).primaryColorDark, fontSize: mq.width*0.06)
              : Theme.of(context).textTheme.headline2!.copyWith(fontSize: mq.width*0.06),
        ),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          cool,
          again
        ],
      );
    }

    showDialog(
        context: context,
        builder: (BuildContext context){
          return win();
        }
    );
  }

  void addToExpr(String element, BuildContext context){
    if(int.tryParse(element) != null){
      if(superscript){
        int num = int.parse(element);
        expressionToShow+=superScriptsPf[num];
        superscript = false;
      }else{
        expressionToShow+=element;
      }
      expression+=element;
      return ;
    }

    if(superscript) {
      _snackBar(context, "Can't use this element in power mode");
      return ;
    }

    if(element == "^"){
      if(expression.length == 0){
        _snackBar(context, "You can't power emptiness;)");
        return ;
      }
      superscript = true;
    }
    if(element != "^") expressionToShow+=element;
    expression+=element;
  }

  ClipRRect numberCard(BuildContext context, Size size, int index){

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: size.height*0.2,
        width: size.width*0.45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: pressed[index] ? Theme.of(context).primaryColorLight : Theme.of(context).buttonColor,
          border: Border.all(
            color: Theme.of(context).primaryColorLight,
            width: 5,
          ),
        ),
        child: MaterialButton(
          disabledColor: Theme.of(context).primaryColorLight,
          onPressed: pressed[index] ? () {
            _snackBar(context, "You have already pressed this button");
          } : (){
            if(!_isInterstitialAdReady){
              _loadInterstitialAd();
            }
            pressed[index] = true;
            addToExpr(numerals[index].toString(), context);
            setState(() {});
          },
          child: Center(
            child: superscript
            ? EasyRichText(
              numerals[index].toString(),
              patternList: [
                EasyRichTextPattern(
                  targetString: numerals[index].toString(),
                  superScript: true,
                  style: !pressed[index]
                    ? Theme.of(context).textTheme.headline6!.copyWith(
                        color: Theme.of(context).textTheme.button!.color,
                        fontSize: size.width*0.2,
                      )
                    : UserData.getTheme() == "Dark"
                      ? Theme.of(context).textTheme.headline6!.copyWith(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: size.width*0.2
                      )
                      : Theme.of(context).textTheme.headline6!.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontSize: size.width*0.2
                        ),
                )
              ],
            )
            : Text(
                "${numerals[index]}",
              style: !pressed[index]
                ? Theme.of(context).textTheme.headline6!.copyWith(
                    color: Theme.of(context).textTheme.button!.color,
                    fontSize: size.width*0.3
                  )
                : UserData.getTheme() == "Dark"
                  ? Theme.of(context).textTheme.headline6!.copyWith(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: size.width*0.3
                    )
                  : Theme.of(context).textTheme.headline6!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: size.width*0.3
                    ),
            ),
          ),
        ),
      ),
    );
  }

  ClipRRect operatorCard(BuildContext context, Size size, int index){

    Size mq = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: size.width*0.25,
        height: size.height*0.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).primaryColorLight, width: 5.0),
          color: Theme.of(context).buttonColor,
        ),
        child: MaterialButton(
          child: Center(
            child: Text(
              operators[index],
              style: Theme.of(context).textTheme.headline5!.copyWith(fontSize: mq.width*0.1),
            ),
          ),
          onPressed: (){
            addToExpr(operators[index], context);
            setState(() {});
          },
        ),
      ),
    );
  }

  bool passed(String expression, BuildContext context){
    for(int i = 0; i < pressed.length; i++){
      if(!pressed[i]) {
        _snackBar(context, "You have to use every given number");
        return false;
      }
    }
    bool equalitySign = false;
    for(int i = 0; i < expression.length; i++){
      if(expression[i] == '=') equalitySign = true;
    }
    if(!equalitySign){
      _snackBar(context, "There must be an equal sign in your expression.");
      return false;
    }
    return true;
  }

  Widget textToShow(BuildContext context, String expression){

    Size mq = MediaQuery.of(context).size;

    List<int> powers = [];
    for(int i = 0; i < expression.length; i++){
      if(expression[i] == '^' && i + 1 < expression.length){
        powers.add(i+1);
      }
    }

    int pos = 0;

    var r = RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: mq.width*0.08),
        children: List.generate(
            expression.length,
            (index) {
              if(expression[index] == '^') return TextSpan(text: "");
              if(powers.isNotEmpty && pos < powers.length && index == powers[pos]){
                pos++;
                return WidgetSpan(
                  child: Transform.translate(
                    offset: const Offset(0.0, -20.0),
                    child: Text(
                      expression[index],
                      style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: mq.width*0.05),
                    ),
                  ),
                );
              }else{
                return TextSpan(
                  text: expression[index]
                );
              }
            }
        ),
      ),
    );
    return r;
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        closed();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              closed();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).appBarTheme.iconTheme!.color,
            iconSize: Theme.of(context).appBarTheme.iconTheme!.size!,
            splashRadius: mq.width*0.06,
          ),
          actions: [
            IconButton(
              padding: EdgeInsets.all(0),
              iconSize: mq.height*0.038,
              splashRadius: mq.width*0.06,
              onPressed: (){
                timesRestarted++;
                if(timesRestarted % 3 == 2 && _isInterstitialAdReady){
                  if (UserData.getAdSubscription() == false) _interstitialAd?.show();
                  _isInterstitialAdReady = false;
                }
                for(int i = 0; i < pressed.length; i++){
                  pressed[i] = false;
                }
                numerals = generateRandom();
                expression = "";
                expressionToShow = "";
                setState(() {});
              },
              icon: Icon(Icons.restart_alt_sharp),
              color: Theme.of(context).appBarTheme.iconTheme!.color,
            ),
          ],
          centerTitle: false,
          title: Text(
            "4 Digits",
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
        body: Column(
          children: [
            Container(
              height: mq.height*0.44,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      numberCard(context, mq, 0),
                      numberCard(context, mq, 1),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      numberCard(context, mq, 2),
                      numberCard(context, mq, 3),
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: mq.width*0.025),
              height: mq.height*0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: mq.height*0.09,
                    width: mq.width*0.65,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Theme.of(context).primaryColorLight,
                        width: 5.0
                      )
                    ),
                    child: Center(
                      child: textToShow(context, expression),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if(expression.length == 0) return ;
                      if(int.tryParse(expression[expression.length - 1]) != null){
                        int n = int.parse(expression[expression.length - 1]);
                        for(int i = 0; i < numerals.length; i++){
                          if(n == numerals[i] && pressed[i] == true){
                            pressed[i] = false;
                            break;
                          }
                        }
                      }
                      if(expression[expression.length - 1] == '^'){
                        expression = expression.substring(0, expression.length - 1);
                        superscript = false;
                      }else if(expression.length > 1 && expression[expression.length - 2] == '^'){
                        expression = expression.substring(0, expression.length - 2);
                      }else{
                        expression = expression.substring(0, expression.length - 1);
                      }
                      setState(() {});
                    },
                    icon: Icon(Icons.backspace_rounded),
                    iconSize: mq.width*0.1,
                    color: UserData.getTheme() == "Light" ? Color(0xff800000) : Colors.redAccent,
                    splashRadius: mq.width*0.06,
                  ),
                  IconButton(
                    onPressed: () {
                      if(passed(expression, context)) {
                        try{
                          if (check(expression)) {
                            showWinDialog(context);
                          } else {
                            _snackBar(context, "This is incorrect");
                          }
                        }catch(e){
                          _snackBar(context, "Bad expression");
                        }
                      }
                    },
                    icon: Icon(Icons.done),
                    iconSize: mq.width*0.1,
                    color: UserData.getTheme() == "Light" ? Color(0xff1A5653) : Colors.greenAccent,
                    splashRadius: mq.width*0.06,
                  )
                ],
              ),
            ),
            Container(
              height: mq.height*0.34,
              padding: EdgeInsets.symmetric(horizontal: mq.width*0.025),
              child: GridView.builder(
                padding: EdgeInsets.symmetric(vertical: mq.height*0.01),
                physics: NeverScrollableScrollPhysics(),
                itemCount: operators.length,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: mq.height*0.1,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                ),
                itemBuilder: (context, index) => operatorCard(context, mq, index),
              )
            ),
          ],
        ),
      ),
    );
  }
}