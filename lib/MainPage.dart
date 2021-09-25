import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:rlogic/MoreInfo.dart';
import 'package:rlogic/ThemeSwitcher/config.dart';
import 'package:rlogic/UserData.dart';
import 'package:share/share.dart';

import 'FirebaseNotifier.dart';
import 'PurchaseApi.dart';

class MainPage extends StatefulWidget {
  MainPage();

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>{

  late FirebaseNotifier firebaseNotifier;

  String theme = UserData.getTheme() != null
      ? UserData.getTheme() == "Light" ? "Dark" : "Light"
      : "Dark";

  Widget button(String text){

    Size mq = MediaQuery.of(context).size;

    return Container(
      width: mq.width*0.4,
      height: mq.height*0.05,
      margin: EdgeInsets.only(bottom: mq.height*0.06),
      child: MaterialButton(
        onPressed: () async {
          if(text.compareTo("Play") == 0){
            Navigator.pushNamed(context, '/Play');
          }else if(text.compareTo("More Info") == 0){
            showDialog(
              context: context,
              builder: (_) => MoreInfo(),
            );
          }else if(text.compareTo("Remove Ads") == 0){
            print("To be Implemented");
          }else{
            theme = (theme == "Dark" ? "Light" : "Dark");
            UserData.setTheme(theme == "Light" ? "Dark" : "Light");
            currentTheme.switchTheme();
          }
        },
        child: FittedBox(
          fit: BoxFit.fill,
          child: Text(
            text,
            style: Theme.of(context).textTheme.button,
          ),
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
              offset: Offset(0, 4),
              blurRadius: 7,
              spreadRadius: 3,
            ),
          ]
      ),
    );
  }

  login(FirebaseNotifier firebaseNotifier){
    if(!firebaseNotifier.loggedIn) {
      firebaseNotifier.login();
    }
    setState((){});
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) => setState(() {
      try{
        login(firebaseNotifier);
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not Log in"),
          )
        );
      }
        }));
    super.initState();
  }

  Future fetchOffers() async{
    final offerings = await PurchaseApi.fetchOffers();

    if(offerings.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No plans found'),
        )
      );
      return ;
    }

    final offer = offerings.first;
    print('Offer: $offer');

    final packages = offerings.map((offer) => offer.availablePackages).expand((pair) => pair).toList();
    print("Packages: $packages");

    for(final package in packages){
      await PurchaseApi.purchasePackage(package);
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {

    firebaseNotifier = context.watch<FirebaseNotifier>();

    Size mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: null,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            color: UserData.getTheme() == "Dark" ? Theme.of(context).primaryColorLight: Theme.of(context).primaryColorLight,
            onPressed: () => Share.share(
              'Check this cool app out: https://play.google.com/store/apps/details?id=com.rlabs.rlogic',
            ),
            splashRadius: mq.width*0.05,
            iconSize: mq.width*0.08,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            color: firebaseNotifier.loggedIn ? Colors.green : UserData.getTheme() == "Light" ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorLight,
            onPressed: () {
              if(firebaseNotifier.loggedIn) {
                print("Signed out");
                firebaseNotifier.logOut();
                firebaseNotifier.loggedIn = false;
              }else{
                login(firebaseNotifier);
              }
              setState((){});
            },
            splashRadius: mq.width*0.05,
            iconSize: mq.width*0.08,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: mq.height*0.4,
            width: mq.width,
            child: Center(
              child: Text(
                "RLogic",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: mq.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  button("Play"),
                  button(theme),
                  button("More Info"),
                  firebaseNotifier.loggedIn && (UserData.getAdSubscription() != true)
                    ? Container(
                    width: mq.width*0.4,
                    height: mq.height*0.05,
                    margin: EdgeInsets.only(bottom: mq.height*0.06),
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
                            offset: Offset(0, 4),
                            blurRadius: 7,
                            spreadRadius: 3,
                          ),
                        ]
                    ),
                    child: MaterialButton(
                      onPressed: fetchOffers,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "Remove Ads",
                          style: Theme.of(context).textTheme.button,
                        ),
                      ),
                    ),
                  )
                    : SizedBox.shrink()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}