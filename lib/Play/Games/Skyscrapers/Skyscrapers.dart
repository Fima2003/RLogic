import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:rlogic/Play/Games/Skyscrapers/skyscraper_logic.dart';
import 'package:rlogic/UserData.dart';
import 'package:rlogic/SomethingElse/ad_helper.dart';

class SkyScrapers extends StatefulWidget {
  const SkyScrapers();
  @override
  _SkyScrapersState createState() => _SkyScrapersState();
}

class _SkyScrapersState extends State<SkyScrapers> with WidgetsBindingObserver{

  bool initializedTimer = false;
  Timer? _timer;

  late GameSettings sets;

  bool pencilMode = false;
  bool hintsAvailability = true;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  late int timesRestarted;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    timesRestarted = UserData.getSSRestarted() ?? 0;
    if(UserData.getSSSettings() == null){
      sets = new GameSettings(size: 4, difficulty: "Easy");
      sets.generateNewGame();
    }else{
      sets = strToGS(UserData.getSSSettings()!);
    }
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if(state == AppLifecycleState.paused){
      closed();
    }

    if(state == AppLifecycleState.inactive){
      closed();
    }

    if(state == AppLifecycleState.detached){
      closed();
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose(){
    if(_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  GameSettings strToGS(String jsonString){
    var jd = jsonDecode(jsonString);
    GameSettings gs = new GameSettings(
      size: jd["size"],
      difficulty: jd["difficulty"],
      field: dynamicToListInt(jd["field"]),
      sides: dynamicToListInt(jd["sides"]),
      inserted: dynamicToListString(jd["inserted"]),
      pressed: dynamicToListBool(jd["pressed"]),
      pencilModeActivated: dynamicToListBool(jd["pencilModeActivated"]),
      pencilModeInserted: List.generate(jd["pencilModeInserted"].length, (index) => dynamicToListString(jd["pencilModeInserted"][index])),
      pm: stringListToPML(jd["previousMoves"]),
      hints: jd["hints"],
      checks: jd["checks"],
      hintsAvailability: jd["hintsAvailable"],
      time: jd["time"],
      clickedPosition: List.generate(jd["clickedPosition"].length, (index) => jd["clickedPosition"][index]),
      clickedOnField: jd["clickedOnField"],
    );
    return gs;
  }

  List<List<int>> dynamicToListInt(List<dynamic> dynfi){
    List<List<int>> field = [];
    for(int i = 0; i < dynfi.length; i++){
      List<int> list = [];
      for(int j = 0; j < dynfi[i].length; j++){
        list.add(dynfi[i][j]);
      }
      field.add(list);
    }
    return field;
  }

  List<List<String>> dynamicToListString(List<dynamic> dynfi){
    List<List<String>> field = [];
    for(int i = 0; i < dynfi.length; i++){
      List<String> list = [];
      for(int j = 0; j < dynfi[i].length; j++){
        list.add(dynfi[i][j]);
      }
      field.add(list);
    }
    return field;
  }

  List<String> dynamicToString(List<dynamic> dynfi){
    List<String> values = [];
    print(dynfi.length);
    for(int i = 0; i < dynfi.length; i++){
      values.add(dynfi[i].toString());
    }
    return values;
  }

  List<List<bool>> dynamicToListBool(List<dynamic> dynfi){
    List<List<bool>> field = [];
    for(int i = 0; i < dynfi.length; i++){
      List<bool> list = [];
      for(int j = 0; j < dynfi[i].length; j++){
        list.add(dynfi[i][j]);
      }
      field.add(list);
    }
    return field;
  }

  List<PreviousMove> stringListToPML(List<dynamic> pmString){
    List<PreviousMove> pms = [];
    for(int i = 0; i < pmString.length; i++){
      var values;
      if(pmString[i]["value"] is List<dynamic>){
        print(pmString[i]["value"].runtimeType);
        values = dynamicToString(pmString[i]["value"]);
      }else {
        values = pmString[i]["value"];
      }
      pms.add(new PreviousMove(
          move: pmString[i]["move"],
          row: pmString[i]["row"],
          col: pmString[i]["col"],
          value: values,
          deleteCase: pmString[i]["deleteCase"] ?? ""
      ));
      print("pmString Value: ${pmString[i]["value"].runtimeType}");
    }
    return pms;
  }

  void closed(){
    UserData.setSSSettings(sets.toJsonString());
    UserData.setSSRestarted(timesRestarted);
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

  _startClock(){
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        sets.time++;
      });
    });
  }

  showSettings(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    int? _size;
    String? _difficulty;

    Widget cancelButton = MaterialButton(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Text(
            "Cancel",
            style: Theme.of(context).textTheme.button
        ),
      ),
      color: Theme.of(context).buttonColor,
      onPressed: (){
        Navigator.of(context).pop();
      },
    );

    Widget apply = MaterialButton(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Text(
            "Apply",
            style: Theme.of(context).textTheme.button
        ),
      ),
      color: Theme.of(context).buttonColor,
      onPressed: (){
        if(_size != null) sets.size = _size!;
        if(_difficulty != null) sets.difficulty = _difficulty!;
        restart(sets.size, sets.difficulty);
        Navigator.of(context).pop();
        setState(() {});
      },
    );

    List<String> difficulties = ["Easy", "Medium", "Hard"];

    TextEditingController heightController = TextEditingController();

    Widget settings = Container(
      width: 168,
      child: TextFormField(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          showCupertinoModalPopup(
              context: context,
              builder: (context) {
                return Container(
                  height: 200,
                  color: Colors.grey,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: sets.size-4),
                          itemExtent: 32.0,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              _size = (index + 4);
                              heightController.text =
                              _difficulty != null
                                ? "Size: $_size Difficulty: $_difficulty"
                                : "Size: $_size Difficulty: ${sets.difficulty}";
                            });
                          },
                          children: List.generate(3, (index) {
                            return Center(
                              child: Text(
                                '${index + 4}',
                                style: Theme.of(context).textTheme.headline3!.copyWith(
                                  fontSize: mq.width*0.05,
                                  color: Colors.black
                                )
                              ),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text('Size',
                            style: Theme.of(context).textTheme.headline3!.copyWith(
                              fontSize: mq.width*0.05,
                              color: Colors.black
                            )
                          ),
                        )
                      ),
                      Expanded(
                        flex: 3,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: difficulties.indexOf(sets.difficulty)),
                          itemExtent: 40.0,
                          onSelectedItemChanged: (int index) {
                            setState(() {
                              _difficulty = difficulties[index];
                              heightController.text = _size != null
                                ? "Size: $_size Difficulty: $_difficulty"
                                : "Size: ${sets.size} Difficulty: $_difficulty";
                            });
                          },
                          children: List.generate(3, (index) {
                            return Center(
                              child: Text(
                                '${difficulties[index]}',
                                style: Theme.of(context).textTheme.headline3!.copyWith(
                                  color: Colors.black,
                                  fontSize: mq.width*0.05
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                            child: Text('Difficulty',
                                style: Theme.of(context).textTheme.headline3!.copyWith(
                                  fontSize: mq.width*0.05,
                                  color: Colors.black,
                                ))),
                      )
                    ],
                  ),
                );
              });
        },
        controller: heightController,
        style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: mq.width*0.04),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        readOnly: true,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColorLight,
              width: 2
            )
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFF7401))),
          hintText: "Tap to change Field Settings",
          hintStyle: Theme.of(context).textTheme.headline3!.copyWith(
            fontSize: mq.width*0.04
          )
        ),
      ),
    );

    AlertDialog settingsDialog () {
      return AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Settings",
          style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: mq.width*0.1),
        ),
        elevation: 10,
        content: settings,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          cancelButton,
          apply
        ],
      );
    }

    showDialog(
        context: context,
        builder: (BuildContext context){
          return settingsDialog();
        }
    );
  }

  Widget clock(BuildContext context, int secondCount) {

    Size mq = MediaQuery.of(context).size;

    int kz(int a){
      int aa = a;
      int res = 0;
      while( aa!= 0){
        aa~/=10;
        res++;
      }
      return res;
    }

    String showTime(int seconds){
      int mm = seconds~/60;
      int ss = seconds%60;
      String mts = "", sts = "";
      if(kz(mm) < 2){
        mts = "0" + mm.toString();
      }else{
        mts = mm.toString();
      }
      if(kz(ss) < 2){
        sts = "0" + ss.toString();
      }else{
        sts = ss.toString();
      }
      return "$mts:$sts";
    }

    return RichText(
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: Theme.of(context).textTheme.headline6!.copyWith(fontSize: mq.height*0.056),
        children: [
          WidgetSpan(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: mq.width*0.03),
              child: Icon(
                FontAwesomeIcons.trophy,
                size: mq.width*0.12,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
            alignment: PlaceholderAlignment.middle
          ),
          TextSpan(
            text: sets.size == 4 ? "${showTime(UserData.getHighestTime4() ?? 0)}"
                : sets.size == 5 ? "${showTime(UserData.getHighestTime5() ?? 0)}"
                : "${showTime(UserData.getHighestTime6() ?? 0)}",
          ),
          WidgetSpan(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: mq.width*0.02),
              child: Icon(
                FontAwesomeIcons.clock,
                size: mq.width*0.12,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
            alignment: PlaceholderAlignment.middle
          ),
          TextSpan(text: showTime(secondCount))
        ]
      ),
    );
  }

  Widget fieldWidget(Size mq, int size, double height) {

    double width = mq.width/(size+2);

    Widget cell(int index) {
      int row = index ~/ size,
          col = index % size;
      clear() {
        for (int i = 0; i < sets.pressed.length; i++) {
          for (int j = 0; j < sets.pressed[i].length; j++) {
            sets.pressed[i][j] = false;
          }
        }
      }

      return Container(
        margin: EdgeInsets.all(mq.width*0.003),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: sets.pressed[row][col]
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).buttonColor,
          border: Border.all(color: Theme.of(context).primaryColorLight, width: 2),
          borderRadius: BorderRadius.circular(3),
        ),
        child: MaterialButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            setState(() {
              clear();
              sets.pressed[row][col] = true;
              sets.clickedPosition = [row, col];
              sets.clickedOnField = true;
            });
          },
          child: !sets.pencilModeActivated[row][col]
            ? Text(
              "${sets.inserted[row][col]}",
              style: UserData.getTheme() == "Light"
              ? Theme.of(context).textTheme.headline5
                !.copyWith(color: Theme.of(context).primaryColor,)
              : Theme.of(context).textTheme.headline5
                  !.copyWith(color: sets.pressed[row][col]
                   ? Theme.of(context).primaryColor
                   : Theme.of(context).primaryColorLight,),
            )
            : Container(
              width: width,
              height: height,
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                children: List.generate(
                  size,
                  (index) {
                    return Container(
                      child: sets.pencilModeInserted[row][col].contains((index+1).toString())
                        ? Center(
                          child:
                            Text(
                              (index+1).toString(),
                              style: UserData.getTheme() == "Light"
                                ? Theme.of(context).textTheme.headline1
                                !.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: width/4,
                                  fontWeight: FontWeight.w700
                                )
                                : Theme.of(context).textTheme.headline1
                                !.copyWith(
                                  color: sets.pressed[row][col]
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).primaryColorLight,
                                  fontSize: mq.width*0.05,
                                  fontWeight: FontWeight.w700
                                ),
                            )
                          )
                        : Center(child: Text(""))
                    );
                  }
                ),
              ),
            )
        ),
      );
    }

    Container hint(String number) => Container(
      margin: EdgeInsets.all(mq.width*0.003),
      height: height*2,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          number,
          style: Theme.of(context).textTheme.headline5!.copyWith(color: Theme.of(context).primaryColorLight),
        ),
      ),
    );

    Widget center = Container(
      height: height*size,
      width: width*size,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: size,
        children: List.generate(size * size, (index) => cell(index)),
      ),
    );

    Widget top = Container(
      height: height,
      width: width*size,

      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: size,
        shrinkWrap: true,
        children: List.generate(size, (index) =>
        sets.sides[1][index] == 0 ? hint("") : hint(sets.sides[1][index].toString())),
      ),
    );

    Widget bottom = Container(
      height: height,
      width: width*size,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: size,
        shrinkWrap: true,
        children: List.generate(size, (index) =>
        sets.sides[3][index] == 0 ? hint("") : hint(sets.sides[3][index].toString())),
      ),
    );

    Widget left = Container(
      width: width,
      height: height*(size),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 1,
        shrinkWrap: true,
        children: List.generate(size, (index) =>
        sets.sides[0][index] == 0 ? hint("") : hint(sets.sides[0][index].toString())),
      ),
    );

    Widget right = Container(
      width: width,
      height: height*size,
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 1,
        shrinkWrap: true,
        children: List.generate(size, (index) =>
        sets.sides[2][index] == 0 ? hint("") : hint(sets.sides[2][index].toString())),
      ),
    );

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          top,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              left,
              center,
              right,
            ],
          ),
          bottom,
        ],
      ),
    );
  }

  Widget helpers(Size mq){

    Container check = Container(
      margin: EdgeInsets.symmetric(horizontal: mq.width*0.01),
      width: mq.width * 0.19,
      height: mq.width * 0.19,
      child: Column(
        children: [
          IconButton(
            onPressed: !sets.hintsAvailability ? null : () {
              if(sets.checks == 0 ){
                _snackBar(context, "No more checks");
                return ;
              }
              if(sets.clickedOnField) {
                var zero = sets.clickedPosition[0], one = sets.clickedPosition[1];
                if (int.tryParse(sets.inserted[zero][one]) != null) {
                  sets.checks--;
                  if (int.tryParse(sets.inserted[zero][one]) == sets.field[zero][one]) {
                    _snackBar(context, "This is a correct number");
                  } else {
                    _snackBar(context, "This is a wrong number");
                  }
                } else {
                  _snackBar(context, "The field is empty. Nothing to check(");
                }
              } else {
                _snackBar(context, "Pick the cell to check");
              }
              setState(() {});
            },
            icon: Icon(Icons.check_outlined),
            iconSize: mq.width*0.09,
            splashRadius: mq.width*0.07,
            color: UserData.getTheme() == "Light"
                ? Colors.black45
                : Theme.of(context).accentColor,
            disabledColor: UserData.getTheme() == "Light"
                ? Colors.black12
                : Theme.of(context).accentColor.withOpacity(0.7),
          ),
          Text("${sets.checks} Checks", style: Theme.of(context).textTheme.headline1!.copyWith(
              color: UserData.getTheme() == "Light"
                  ? Colors.black45
                  : Theme.of(context).accentColor,
              fontSize: mq.width*0.047
          ),
          ),
        ],
      ),
    );

    Container hint = Container(
      height: mq.width*0.19,
      width: mq.width*0.19,
      child: Column(
        children: [
          IconButton(
            onPressed: !sets.hintsAvailability ? null : (){
              if(sets.hints == 0){
                _snackBar(context, "Out of hints");
                return ;
              }
              if(sets.clickedOnField)
                setState(() {
                  if(int.tryParse(sets.inserted[sets.clickedPosition[0]][sets.clickedPosition[1]]) !=null){
                    if(int.tryParse(sets.inserted[sets.clickedPosition[0]][sets.clickedPosition[1]]) == sets.field[sets.clickedPosition[0]][sets.clickedPosition[1]]){
                      _snackBar(context, "The number inserted is already correct");
                    }else{
                      sets.inserted[sets.clickedPosition[0]][sets.clickedPosition[1]] = sets.field[sets.clickedPosition[0]][sets.clickedPosition[1]].toString();
                      sets.hints--;
                    }
                  }else{
                    sets.inserted[sets.clickedPosition[0]][sets.clickedPosition[1]] = sets.field[sets.clickedPosition[0]][sets.clickedPosition[1]].toString();
                    sets.hints--;
                  }
                });
              else
                _snackBar(context, "Select a cell for a hint");
            },
            icon: Icon(Icons.lightbulb_outlined),
            iconSize: mq.width*0.09,
            splashRadius: mq.width*0.07,
            color: UserData.getTheme() == "Light"
                ? Colors.black45
                : Theme.of(context).accentColor,
            disabledColor: UserData.getTheme() == "Light"
                ? Colors.black12
                : Theme.of(context).accentColor.withOpacity(0.7),
          ),
          Text("${sets.hints} Hints", style: Theme.of(context).textTheme.headline1!.copyWith(
              color: UserData.getTheme() == "Light"
                  ? Colors.black45
                  : Theme.of(context).accentColor,
              fontSize: mq.width*0.048
          ),
          )
        ],
      ),
    );

    Container pencil = Container(
      margin: EdgeInsets.symmetric(horizontal: mq.width*0.01),
      height: mq.width*0.19,
      width: mq.width*0.19,
      child: Column(
        children: [
          IconButton(
            onPressed: !sets.hintsAvailability ? null : (){
              setState(() {
                pencilMode = !pencilMode;
              });
            },
            icon: Icon(Icons.edit_outlined),
            iconSize: mq.width*0.09,
            splashRadius: mq.width*0.07,
            color: UserData.getTheme() == "Light"
                ? (pencilMode ? Colors.green : Colors.black45)
                : (pencilMode ? Colors.greenAccent : Theme.of(context).accentColor),
            disabledColor: UserData.getTheme() == "Light"
                ? Colors.black12
                : Theme.of(context).accentColor.withOpacity(0.7),
          ),
          Text("Notes", style: Theme.of(context).textTheme.headline1!.copyWith(
              color: UserData.getTheme() == "Light"
                  ? Colors.black45
                  : Theme.of(context).accentColor,
              fontSize: mq.width*0.048
          ),)
        ],
      ),
    );

    Container delete = Container(
      height: mq.width*0.19,
      width: mq.width*0.19,
      child: Column(
        children: [
          IconButton(
            onPressed: !sets.hintsAvailability ? null :(){
              if(sets.clickedOnField) {
                var row = sets.clickedPosition[0], col = sets.clickedPosition[1];
                if(!sets.pencilModeActivated[row][col] && sets.inserted[row][col].isEmpty){
                  return ;
                }
                deleteLogic(sets.pm, sets.pencilModeInserted, sets.inserted,
                    sets.pencilModeActivated, row, col);
                setState(() {
                });
              }
            },
            icon: Icon(Icons.clear_outlined),
            iconSize: mq.width*0.09,
            splashRadius: mq.width*0.07,
            color: Colors.redAccent,
            disabledColor: Colors.redAccent.withOpacity(0.7),
          ),
          Text("Delete", style: Theme.of(context).textTheme.headline1!.copyWith(
              color: UserData.getTheme() == "Light"
                  ? Colors.black45
                  : Theme.of(context).accentColor,
              fontSize: mq.width*0.048
          ),
          )
        ],
      ),
    );

    Container undo = Container(
      height: mq.width*0.19,
      width: mq.width*0.19,
      child: Column(
        children: [
          IconButton(
            onPressed: (sets.pm.isEmpty || !sets.hintsAvailability)
              ? null
              :(){
              undoLogic(sets.pm, sets.pencilModeInserted, sets.inserted, sets.pencilModeActivated);
              setState(() {});
            },
            icon: Icon(Icons.undo_outlined),
            iconSize: mq.width*0.09,
            splashRadius: mq.width*0.07,
            color: UserData.getTheme() == "Light"
                ? Colors.black45
                : Theme.of(context).accentColor,
            disabledColor: UserData.getTheme() == "Light"
                ? Colors.black12
                : Theme.of(context).accentColor.withOpacity(0.7),
          ),
          Text("Undo", style: Theme.of(context).textTheme.headline1!.copyWith(
              color: UserData.getTheme() == "Light"
                  ? Colors.black45
                  : Theme.of(context).accentColor,
              fontSize: mq.width*0.048
          ),
          )
        ],
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        check,
        hint,
        pencil,
        delete,
        undo
      ],
    );
  }

  Widget keyboardWidget(Size mq, int size){

    List<int> disabled = [];

    void findDisabled(var clickedPosition){
      int row = clickedPosition[0];
      int col = clickedPosition[1];
      for(int i = 0; i < size; i++){
        if(sets.inserted[row][i] != ""){
          disabled.add(int.parse(sets.inserted[row][i]));
        }
      }
      for(int i = 0; i < size; i++){
        if(sets.inserted[i][col] != ""){
          disabled.add(int.parse(sets.inserted[i][col]));
        }
      }
    }

    numberCell(int index) {
      if (sets.clickedOnField)
        findDisabled(sets.clickedPosition);
      bool toShow = !disabled.contains(index + 1);
      return Container(
        width: mq.width*0.8/size,
        height: mq.width*0.8/size,
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: toShow
            ? Theme.of(context).buttonColor
            : Theme.of(context).primaryColorLight,
          border: Border.all(color: Theme.of(context).primaryColorLight, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: MaterialButton(
          onPressed: () {
            if(!_isInterstitialAdReady) _loadInterstitialAd();
            if (sets.clickedOnField && toShow) {
              var row = sets.clickedPosition[0], col = sets.clickedPosition[1];

              if(_timer == null) _startClock();
              // Add number to a picked cell
              setState(() {
                if(pencilMode) {
                  if(!sets.pencilModeInserted[row][col].contains( (index+1).toString() ) ) {
                    sets.pencilModeInserted[row][col].add((index + 1).toString());
                    sets.pencilModeActivated[row][col] = true;
                    final PreviousMove pm = new PreviousMove(
                      move: "Pencil",
                      row: row,
                      col: col,
                      value: sets.pencilModeInserted[row][col].last,
                    );
                    sets.pm.add(pm);
                  }
                  sets.inserted[row][col] = "";
                }else{
                  sets.inserted[row][col] = (index + 1).toString();
                  sets.pencilModeActivated[row][col] = false;
                  sets.pm.add(PreviousMove(
                    move: "Full",
                    row: row,
                    col: col,
                    value: sets.inserted[row][col],
                  ));
                  sets.pencilModeInserted[row][col].clear();
                  for(int i = 0; i < size; i++){
                    if(sets.pencilModeInserted[row][i].contains((index+1).toString()))
                      sets.pencilModeInserted[row][i].remove((index + 1).toString());
                  }
                  for(int i = 0; i < size; i++){
                    if(sets.pencilModeInserted[i][col].contains((index+1).toString()))
                      sets.pencilModeInserted[i][col].remove((index + 1).toString());
                  }
                }
              });
            } else {
              _snackBar(context, "Can't do it");
            }
            // If the whole field is filled, then check if it is the correct solution
            if(filled(sets.inserted)){
              if(check(sets.inserted, sets.sides)){
                showWinDialog(context);
                sets.hintsAvailability = false;
                _timer!.cancel();
                _timer = null;
              }else{
                _snackBar(context, "Something's wrong. I can feel it");
              }
            }
          },
          child: Text(
            "${index + 1}",
            style: UserData.getTheme() == "Light"
              ? (pencilMode
                ? Theme.of(context).textTheme.headline5!.copyWith(fontSize: mq.width*0.06)
                : Theme.of(context).textTheme.headline5!.copyWith(fontSize: mq.width*0.09)
                )
              : (pencilMode
                ? Theme.of(context).textTheme.headline5!.copyWith(
                  fontSize: mq.width*0.06,
                  color: toShow
                    ? Theme.of(context).primaryColorLight
                    : Theme.of(context).primaryColor,
                )
                : Theme.of(context).textTheme.headline5!.copyWith(
                  fontSize: mq.width*0.09,
                  color: toShow
                    ? Theme.of(context).primaryColorLight
                    : Theme.of(context).primaryColor,
                )
              )
            ),
          ),
        );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(size, (index) => numberCell(index)),
    );
  }

  @override
  Widget build(BuildContext context){

    Size mq = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        closed();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(elevation: 5,
          iconTheme: Theme.of(context).appBarTheme.iconTheme,
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
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          centerTitle: false,
          title: Text(
            "SkyScrapers",
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          actions: [
            IconButton(
              onPressed: (){
                showSettings(context);
              },
              icon: Icon(
                Icons.settings_outlined
              ),
              iconSize: mq.height*0.038,
              splashRadius: mq.width*0.06,
            ),
            IconButton(
              onPressed: (){
                restart(sets.size, sets.difficulty);
                timesRestarted++;
                if(timesRestarted % 3 == 2 && _isInterstitialAdReady){
                  if (UserData.getAdSubscription() == false) _interstitialAd?.show();
                  _isInterstitialAdReady = false;
                  timesRestarted = 0;
                }
                setState(() {});
              },
              iconSize: mq.height*0.038,
              icon: Icon(
                Icons.restart_alt_outlined
              ),
              splashRadius: mq.width*0.06,
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: mq.height*0.03),
              width: mq.width,
              height: mq.height*0.07,
              child: clock(context, sets.time),
            ),
            Container(
              width: mq.width,
              height: mq.height*(mq.width/mq.height),
              child: fieldWidget(mq, sets.size, mq.width/(sets.size+2)),
            ),
            Container(
              margin: EdgeInsets.only(bottom: mq.height*0.01),
              width: mq.width,
              height: mq.height*0.11,
              child: helpers(mq),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: mq.height*0.01),
              width: mq.width,
              height: mq.height*0.11,
              child: keyboardWidget(mq, sets.size),
            )
          ],
        ),
      ),
    );
  }

  void restart(int size, String difficulty){
    sets.generateNewGame();
    pencilMode = false;
    if(_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
    sets.time = 0;
    setState(() {});
  }

  showWinDialog(BuildContext context) {

    if(sets.size == 4){
      if(sets.time < (UserData.getHighestTime4() ?? 100000)) UserData.setSSHighestTime4(sets.time);
    }else if(sets.size == 5){
      if(sets.time < (UserData.getHighestTime5() ?? 100000)) UserData.setSSHighestTime5(sets.time);
    }else if(sets.size == 6){
      if(sets.time < (UserData.getHighestTime6() ?? 100000)) UserData.setSSHighestTime6(sets.time);
    }

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
        restart(sets.size, sets.difficulty);
        if(_isInterstitialAdReady) {
          if (UserData.getAdSubscription() == false) _interstitialAd?.show();
          _isInterstitialAdReady = false;
        }
        Navigator.of(context).pop();
        setState(() {});
      },
    );

    AlertDialog win (String time) {
      return new AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Congratulations!",
          style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: mq.width*0.07),
        ),
        elevation: 10,
        content: Text(
          "You found the solution in $time!",
          style: UserData.getTheme() == "Light"
              ? Theme.of(context).textTheme.headline2!.copyWith(color: Theme.of(context).primaryColorDark, fontSize: mq.width*0.06)
              : Theme.of(context).textTheme.headline2!.copyWith(fontSize: mq.width*0.06),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          cool,
          again
        ],
      );
    }

    int kz(int a){
      int aa = a;
      int res = 0;
      while( aa!= 0){
        aa~/=10;
        res++;
      }
      return res;
    }

    String showTime(int seconds){
      int mm = seconds~/60;
      int ss = seconds%60;
      String mts = "", sts = "";
      if(kz(mm) < 2){
        mts = "0" + mm.toString();
      }else{
        mts = mm.toString();
      }
      if(kz(ss) < 2){
        sts = "0" + ss.toString();
      }else{
        sts = ss.toString();
      }
      return "$mts:$sts";
    }

    showDialog(
        context: context,
        builder: (BuildContext context){
          return win(showTime(sets.time));
        }
    );
  }

  void _snackBar(BuildContext context, String text){
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
        SnackBar(
          content: Text(
            "$text",
            style: Theme.of(context).textTheme.headline1,
          ),
          elevation: 5,
          duration: Duration(milliseconds: 1000),
        )
    );
  }
}

class GameSettings{

  late int size;
  late String difficulty;
  late int hints, checks;
  late List<List<int>> field, sides;
  late List<List<String>> inserted;
  late List<List<bool>> pressed, pencilModeActivated;
  late List<List<List<String>>> pencilModeInserted;
  late List<PreviousMove> pm;
  late bool hintsAvailability, clickedOnField;
  late int time;
  late List<int> clickedPosition;

  generateNewGame(){
    var game = generateGame(this.size, this.difficulty);
    this.field = game["field"];
    this.sides = game["SideTips"];
    this.inserted = List.generate(this.size, (index) => List.generate(this.size, (index) => ""));
    this.pressed = List.generate(this.size, (index) => List.generate(this.size, (index) => false));
    this.pencilModeInserted = List.generate(this.size, (index) => List.generate(this.size, (index) => List.generate(0, (index) => "")));
    this.pencilModeActivated = List.generate(this.size, (index) => List.generate(this.size, (index) => false));
    this.pm = [];
    this.hints = 3;
    this.checks = 3;
    this.hintsAvailability = true;
    this.time = 0;
    this.clickedPosition = [];
    this.clickedOnField = false;
  }

  String toJsonString(){
    return '{"size": ${this.size}, "difficulty": \"${this.difficulty}", '
      '"field": ${this.field}, "sides": ${this.sides}, '
      '"inserted": ${insertedToString(this.inserted.toString())}, "pressed": ${this.pressed}, '
      '"pencilModeActivated": ${this.pencilModeActivated}, '
      '"pencilModeInserted": ${insertedToString(this.pencilModeInserted.toString())}, '
      '"previousMoves": ${pmListToString(this.pm)}, "hints": ${this.hints}, '
      '"checks": ${this.checks}, "hintsAvailable": ${this.hintsAvailability},'
        '"time": ${this.time}, "clickedPosition": ${this.clickedPosition}, '
        '"clickedOnField": ${this.clickedOnField}}';
  }

  String insertedToString(String example){
    for(int i = 0; i < example.length; i++){
      if(example[i].compareTo(",") == 0){
        if(int.tryParse(example[i - 1]) != null){
          example = example.substring(0, i - 1) + "\"" + example[i-1] + "\"" + example.substring(i);
          i+=2;
        }else if(example[i-1].compareTo("]") != 0){
          example = example.substring(0, i) + "\"\"" + example.substring(i);
          i+=2;
        }
      }else if(example[i].compareTo("]") == 0){
        if(int.tryParse(example[i-1]) != null){
          example = example.substring(0, i - 1) + '\"'+example[i-1] + '\"' + example.substring(i);
          i+=2;
        }else if(example[i-1].compareTo(" ") == 0){
          example = example.substring(0, i) + '\"\"' + example.substring(i);
          i+=2;
        }
      }
    }
    return example;
  }

  String pmToString(PreviousMove pm){
    return '{"move": \"${pm.move}\", "row": ${pm.row}, "col": ${pm.col},'
        '"value": ${pm.value}, "deleteCase": \"${pm.deleteCase}\"}';
  }

  List<String> pmListToString(List<PreviousMove> pm){
    List<String> pmsString = [];
    for(int i = 0; i < pm.length; i++){
      pmsString.add(pmToString(pm[i]));
    }
    return pmsString;
  }

  GameSettings({size, difficulty, field, sides,
                inserted, pressed, pencilModeActivated,
                pencilModeInserted, pm, hints, checks,
                hintsAvailability, time, clickedPosition, clickedOnField}) {
    this.size = size;
    this.difficulty = difficulty;
    if(field != null){
      this.field = field;
      this.sides = sides;
      this.inserted = inserted;
      this.pressed = pressed;
      this.pencilModeInserted = pencilModeInserted;
      this.pencilModeActivated = pencilModeActivated;
      this.pm = pm;
      this.hints = hints;
      this.checks = checks;
      this.hintsAvailability = hintsAvailability;
      this.time = time;
      this.clickedPosition = List.generate(clickedPosition.length, (index) => clickedPosition[index]);
      this.clickedOnField = clickedOnField;
    }
  }
}