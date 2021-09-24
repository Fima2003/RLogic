import 'package:flutter/material.dart';
import 'package:rlogic/Play/DescriptionContainer.dart';
import 'package:rlogic/Play/Games/4Digits/4DigitsDescription.dart';
import 'package:rlogic/Play/Games/BullsCows/BullsCowsDescription.dart';
import 'package:rlogic/Play/Games/Skyscrapers/SkyScrapersDescription.dart';

class PlayPage extends StatefulWidget {
  const PlayPage();

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {

  ScrollController _mainScrollController = ScrollController();

  @override
  initState(){
    descriptions = [SkyScrapersDescription(_mainScrollController), BullsCowsDescription(), DigitsDescription()];
    super.initState();
  }

  late List<Widget> descriptions;
  List<String> names = ["SkyScrapers", "Bulls&Cows", "4 Digits"];

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 5,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        leading: IconButton(
          onPressed: ()=>Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_outlined),
          color: Theme.of(context).appBarTheme.iconTheme!.color,
          iconSize: Theme.of(context).appBarTheme.iconTheme!.size!,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: false,
        title: Text(
          "Game Center",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: ListView.separated(
        controller: _mainScrollController,
        padding: EdgeInsets.symmetric(horizontal: mq.width*0.05, vertical: mq.height*0.02),
        itemBuilder: (BuildContext context, int index){
          return DescriptionContainer(
            gameName: names[index],
            description: descriptions[index],
            controller: _mainScrollController,
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(
          thickness: 0.5,
        ),
        itemCount: names.length,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
