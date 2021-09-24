import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rlogic/Play/Games/BullsCows/Attempt.dart';
import 'package:rlogic/Play/Games/BullsCows/attemptBox.dart';
import 'package:rlogic/Play/Games/BullsCows/bc.dart';
import 'package:rlogic/ThemeSwitcher/config.dart';
import 'package:rlogic/UserData.dart';
import 'package:rlogic/SomethingElse/ad_helper.dart';

class BullCow extends StatefulWidget {

  const BullCow();

  @override
  _BullCowState createState() => _BullCowState();
}

class _BullCowState extends State<BullCow>  with WidgetsBindingObserver{

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  late int timesRestarted;

  BullsCows bc = new BullsCows();
  late int hidden;
  int tries = (UserData.getAttempts() ?? []).length;
  TextEditingController _controller = TextEditingController();
  final _lvcontroller = ScrollController();
  late List<Attempt> atmps;

  @override
  void initState() {
    print(tries);
    WidgetsBinding.instance!.addObserver(this);
    hidden = UserData.getHiddenNumber() ?? bc.generateHidden();
    atmps = lostloa(UserData.getAttempts()) ?? [];
    timesRestarted = UserData.getBullsCowsRepeatedGame() ?? 0;
    super.initState();
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
          content: Text(
              text,
              style: Theme.of(context).textTheme.headline1
          ),
          elevation: 5,
          duration: Duration(milliseconds: 1000),
        )
    );
  }

  void repeatedAtmp(BuildContext context, int number){
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(
          "You have already tried $number",
          style: Theme.of(context).textTheme.headline1,
        ),
        elevation: 5,
        duration: Duration(milliseconds: 1000),
      )
    );
  }

  showWinDialog(BuildContext context, int number, int tries){

    Size mq = MediaQuery.of(context).size;

    Widget cool = MaterialButton(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Text(
          "Cool!",
          style: Theme.of(context).textTheme.button
        ),
      ),
      color: Theme.of(context).buttonColor,
      onPressed: (){
        Navigator.of(context).pop();
      },
    );

    Widget again = MaterialButton(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Text(
          "Play Again",
          style: Theme.of(context).textTheme.button
          ),
      ),
      color: Theme.of(context).buttonColor,
      onPressed: (){
        hidden = bc.generateHidden();
        atmps.clear();
        _controller.clear();
        Navigator.of(context).pop();
        if(_isInterstitialAdReady) {
          _isInterstitialAdReady = false;
          if (UserData.getAdSubscription() == false) _interstitialAd?.show();
        }
        setState(() {});
      },
    );

    AlertDialog win (int number) {
      return new AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "You guessed it with $tries attempts!\nCongratulations!",
          style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: mq.width*0.07),
        ),
        content: Text(
          "The number is $number",
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
        return win(number);
      }
    );
  }

  bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  void onSubmitted (){

    if(!_isInterstitialAdReady) {
      _loadInterstitialAd();
    }

    String s = _controller.text;

    if(!isNumeric(s)){
      _snackBar(context, "The number should be integer");
    }

    for(int i = 0; i < s.length; i++){
      for(int j = 0; j < s.length; j++){
        if(s[i] == s[j] && i!=j){
          _snackBar(context, "Number has duplicate numerals");
          _controller.clear();
          return ;
        }
      }
    }

    if(_controller.text.length < 4 || _controller.text.length > 4 || _controller.text[0] == '0'){
      _snackBar(context, "Not a 4-digit number or starts with 0");
      _controller.clear();
      return ;
    }

    int guess = int.tryParse(_controller.text)!;
    Pair p = bc.check(guess, hidden);
    if(p.bulls == 4){
      bool contains = false;
      for(int i = 0; i < atmps.length; i++){
        if(atmps[i].number == int.parse(_controller.text)){
          contains = true;
          break;
        }
      }
      if(!contains)
        atmps.add(new Attempt(guess, p.bulls, p.cows));
      setState(() {});
      if(tries < (UserData.getBullsCowsHighScore() ?? 1000)) {
        UserData.setBullsCowsHighScore(tries);
      }
      UserData.setAttempts([]);
      showWinDialog(context, hidden, tries);
    }else{
      bool contains = false;
      for(int i = 0; i < atmps.length; i++){
        if(atmps[i].number == int.parse(_controller.text)){
          contains = true;
          break;
        }
      }
      if(contains) repeatedAtmp(context, guess);
      else {
        tries++;
        atmps.add(new Attempt(guess, p.bulls, p.cows));
      }
      _controller.clear();
      setState(() {});
    }
  }

  String toJSON(Attempt atmp){
    return '{"number": ${atmp.number}, "bulls": ${atmp.bulls}, "cows": ${atmp.cows}}';
  }

  Attempt toAttempt(String jsonString){
    var jsAttempt = jsonDecode(jsonString);
    Attempt atmp = new Attempt(jsAttempt["number"], jsAttempt["bulls"], jsAttempt["cows"]);
    return atmp;
  }

  List<Attempt>? lostloa(List<String>? attemptString){
    if(attemptString == null) return null;
    List<Attempt> atmps = [];
    for(int i = 0; i < attemptString.length; i++){
      atmps.add(toAttempt(attemptString[i]));
    }
    return atmps;
  }

  List<String> loatlos(List<Attempt> atmps){
    List<String> attemptsInJson = [];
    for(int i = 0; i < atmps.length; i++){
      attemptsInJson.add(toJSON(atmps[i]));
    }
    return attemptsInJson;
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
    _controller.dispose();
    if(_isInterstitialAdReady) _interstitialAd?.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    print("disposed");
    super.dispose();
  }

  void closed(){
    UserData.setHiddenNumber(hidden);
    UserData.setAttempts(loatlos(atmps));
    UserData.setBullsCowsRepeatedGame(timesRestarted);
  }

  GlobalKey _toolTipKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    if(atmps.length != 0)
      Timer(
      Duration(milliseconds: 1),
          () => _lvcontroller.jumpTo(_lvcontroller.position.maxScrollExtent),
    );

    var mq = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        closed();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: false,
          elevation: 5,
          leading: IconButton(
            onPressed: () {
              closed();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).appBarTheme.iconTheme!.color,
            iconSize: mq.height*0.038,
            splashRadius: mq.width*0.06,
          ),
          title: Text(
            "Bulls&Cows",
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          actions: [
            UserData.getBullsCowsHighScore() != null
              ? Center(
                child: Container(
                  margin: EdgeInsets.only(right: mq.width*0.03),
                  child: GestureDetector(
                    onTap: (){
                      final dynamic tooltip = _toolTipKey.currentState;
                      tooltip.ensureTooltipVisible();
                    },
                    child: Tooltip(
                      key: _toolTipKey,
                      message: 'Your High Score',
                      showDuration: Duration(milliseconds: 400),
                      child: Text(
                        "HS: ${UserData.getBullsCowsHighScore().toString()}",
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                    ),
                  ),
                ),
              )
              : Text(""),
            IconButton(
              padding: EdgeInsets.all(0),
              iconSize: mq.height*0.038,
              splashRadius: mq.width*0.06,
              onPressed: (){
                hidden = bc.generateHidden();
                atmps.clear();
                _controller.clear();
                timesRestarted++;
                if(timesRestarted % 3 == 2 && _isInterstitialAdReady) {
                  if (UserData.getAdSubscription() == false) _interstitialAd?.show();
                  _isInterstitialAdReady = false;
                  timesRestarted = 0;
                }
                setState(() {});
              },
              icon: Icon(Icons.restart_alt_sharp),
              color: Theme.of(context).appBarTheme.iconTheme!.color,
            ),
          ]
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                      Container(
                        height: mq.height*0.2,
                        width: mq.width*0.95,
                        margin: EdgeInsets.all(mq.width*0.025),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).buttonColor,
                          border: Border.all(color: Theme.of(context).primaryColorLight, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.4),
                              offset: Offset(0, 5),
                              blurRadius: 7,
                              spreadRadius: 2,
                            )
                          ]
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Text(
                              "I am thinking about...",
                              style: Theme.of(context).textTheme.headline5!.copyWith(
                                color: Theme.of(context).textTheme.button!.color,
                                fontSize: mq.width*0.087
                              ),
                            ),
                          ),
                        ),
                      ),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: mq.height*0.02),
                          height: mq.height*0.05,
                          width: mq.width*0.9,
                          child: Row(
                            children: [
                              Text("   number", style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: mq.width*0.06)),
                              Text("bulls      cows", style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: mq.width*0.06)),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.symmetric(horizontal: BorderSide(width: 2, color: Theme.of(context).accentColor))
                            ),
                            width: mq.width*0.9,
                            height: mq.height*0.4,
                            child: atmps.length == 0 ?
                            Center(child: Text("No tries yet", style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: mq.width*0.08))) :
                            ListView.separated(
                              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                              controller: _lvcontroller,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext context, int index){
                                return AttemptBox(atmps[index]);
                              },
                              separatorBuilder: (BuildContext context, int index) => const Divider(),
                              itemCount: atmps.length,
                            )
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              width: mq.width*0.4,
                              child: TextField(
                                controller: _controller,
                                textInputAction: TextInputAction.done,
                                cursorColor: Theme.of(context).primaryColorLight,
                                onSubmitted: (String val) {
                                  onSubmitted();
                                },
                                style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: mq.width*0.065),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColorLight
                                    )
                                  ),
                                  labelText: "4-digit number",
                                  labelStyle: Theme.of(context).textTheme.headline2!.copyWith(fontSize: mq.width*0.065)
                                ),
                              ),
                            ),
                            Container(
                              child: MaterialButton(
                                onPressed: () {
                                  onSubmitted();
                                },
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: Text("Submit", style: Theme.of(context).textTheme.button,)
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).buttonColor,
                                  border: Border.all(
                                    color: Theme.of(context).primaryColorLight,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.25),
                                      offset: Offset(0, 5),
                                      blurRadius: 7,
                                      spreadRadius: 3,
                                    ),
                                  ]
                              ),
                              width: mq.width*0.3,
                              height: mq.height*0.05,
                              // margin: EdgeInsets.all(mq.width*0.05),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}
