import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rlogic/UserData.dart';

class SkyScrapersDescription extends StatefulWidget {
  final ScrollController parentScrollController;
  const SkyScrapersDescription(this.parentScrollController);

  @override
  _SkyScrapersDescriptionState createState() => _SkyScrapersDescriptionState();
}

class _SkyScrapersDescriptionState extends State<SkyScrapersDescription> {

  ScrollPhysics physics = ScrollPhysics();
  late ScrollController _listViewScrollController;

  int _currentPage = 0;

  void listViewScrollListener(){
    print("something");
    if(_listViewScrollController.offset >= _listViewScrollController.position.maxScrollExtent &&
        !_listViewScrollController.position.outOfRange){
      // widget.parentScrollController.
      setState((){
        physics = NeverScrollableScrollPhysics();
      });
      print("bottom");
    }
  }

  void mainScrollListener(){
    if(widget.parentScrollController.offset <= widget.parentScrollController.position.minScrollExtent &&
        !widget.parentScrollController.position.outOfRange){
      setState((){
        if(physics is NeverScrollableScrollPhysics){
          physics = ScrollPhysics();
          _listViewScrollController.animateTo(_listViewScrollController.position.maxScrollExtent-50,duration: Duration(milliseconds: 200),curve: Curves.linear);
        }
      });
      print("top");
    }
  }

  @override
  initState(){
    _listViewScrollController = ScrollController();
    // _listViewScrollController.addListener(listViewScrollListener);
    super.initState();
  }

  Widget description(BuildContext context) {

    // widget.parentScrollController.addListener(mainScrollListener);

    Size mq = MediaQuery.of(context).size;

    return Center(
      child: ListView(
        shrinkWrap: true,
        // controller: _listViewScrollController,
        physics: ClampingScrollPhysics(),
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: mq.height*0.01),
              child: Text(
                "Rules",
                style: Theme.of(context).textTheme.headline5!.copyWith(
                  color: Theme.of(context).primaryColor
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: mq.height*0.03),
            padding: EdgeInsets.symmetric(horizontal: mq.width*0.02),
            child: Text(
              "Each puzzle consists of an NxN grid with some clues along its sides. The object is to place a skyscraper in each square, with a height between 1 and N, so that no two skyscrapers in a row or column have the same number of floors. In addition, the number of visible skyscrapers, as viewed from the direction of each clue, is equal to the value of the clue. Note that higher skyscrapers block the view of lower skyscrapers located behind them.",
              style: Theme.of(context).textTheme.headline2!.copyWith(
                fontSize: mq.width * 0.05,
                color: Theme.of(context).primaryColor
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: mq.width*0.3,
                width: mq.width*0.3,
                child: ClipRRect(
                  child: Image.asset(
                    UserData.getTheme() == "Light"
                      ? "assets/images/SkyScrapers/EmptyExample.jpg"
                      : "assets/images/SkyScrapers/EmptyExample-Dark.jpg",
                    fit: BoxFit.contain,
                    scale: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Container(
                child: ClipRRect(
                  child: Image.asset(
                    UserData.getTheme() == "Light"
                    ? "assets/images/SkyScrapers/CompletedExample.jpg"
                    : "assets/images/SkyScrapers/CompletedExample-Dark.jpg",
                    fit: BoxFit.contain,
                    scale: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                width: mq.width*0.3,
                height: mq.width*0.3,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget technique1(BuildContext context){
    Size mq = MediaQuery.of(context).size;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: mq.height*0.01),
              child: Text(
                "Technique 1",
                style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Theme.of(context).primaryColor
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: mq.height*0.03),
                padding: EdgeInsets.symmetric(horizontal: mq.width*0.02),
                child: Text(
                  "Clue 1 means only one skyscraper is visible when viewing the row or column from the direction of the clue. Therefore in the example below, the highest skyscraper with 5 floors must be placed next to the clue 1 to block the view of the remaining buildings.",
                  style: Theme.of(context).textTheme.headline2!.copyWith(
                    fontSize: mq.width * 0.05,
                    color: Theme.of(context).primaryColor
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.all(mq.width*0.03),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    UserData.getTheme() == "Light"
                      ? "assets/images/SkyScrapers/1-Example.jpg"
                      : "assets/images/SkyScrapers/1-Example-Dark.jpg",
                    height: mq.width*0.5,
                    width: mq.width*0.5
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget technique2(BuildContext context){
    Size mq = MediaQuery.of(context).size;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: mq.height*0.01),
              child: Text(
                "Technique 2",
                style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Theme.of(context).primaryColor
                ),
              ),
            ),
            Flexible(
              child: Container(
                child: Text(
                  "Clue N, in an NxN grid, means all skyscrapers are visible when viewing the row or column from the direction of the clue. Therefore in the example below, the five skyscrapers must be placed in ascending order from the clue 5 so no building gets blocked.",
                  style: Theme.of(context).textTheme.headline2!.copyWith(
                      fontSize: mq.width * 0.05,
                      color: Theme.of(context).primaryColor
                  ),
                  textAlign: TextAlign.center,
                ),
                margin: EdgeInsets.symmetric(vertical: mq.height*0.03),
                padding: EdgeInsets.symmetric(horizontal: mq.width*0.02),
              ),
            ),
            Flexible(
              child: Container(
                  margin: EdgeInsets.all(mq.width*0.03),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        UserData.getTheme() == "Light"
                          ? "assets/images/SkyScrapers/4-Example.jpg"
                          : "assets/images/SkyScrapers/4-Example-Dark.jpg",
                        width: mq.width*0.5,
                        height: mq.width*0.5,
                      ),
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget technique3(BuildContext context){
    Size mq = MediaQuery.of(context).size;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: mq.height*0.01),
              child: Text(
                "Technique 3",
                style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Theme.of(context).primaryColor
                ),
              ),
            ),
            Flexible(
              child: Container(
                child: Text(
                  "Whenever the highest skyscraper is at the far opposite side of clue 2, the second highest skyscraper must be placed next to clue 2. In the example below, a 4-floor skyscraper which is the second highest in a 5x5 grid must be placed next to clue 2 in the top square of the left column. Any other skyscraper would cause more than two buildings to be visible when viewing the left column from the direction of this clue.",
                  style: Theme.of(context).textTheme.headline2!.copyWith(
                      fontSize: mq.width * 0.05,
                      color: Theme.of(context).primaryColor
                  ),
                  textAlign: TextAlign.center,
                ),
                margin: EdgeInsets.symmetric(vertical: mq.height*0.03),
                padding: EdgeInsets.symmetric(horizontal: mq.width*0.02),
              ),
            ),
            Flexible(
              child: Container(
                margin: EdgeInsets.all(mq.width*0.03),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    UserData.getTheme() == "Light"
                      ? "assets/images/SkyScrapers/1-2Example.jpg"
                      : "assets/images/SkyScrapers/1-2Example-Dark.jpg",
                    width: mq.width*0.5,
                    height: mq.width*0.5,
                  )
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> pages = [];

  @override
  Widget build(BuildContext context) {

    pages = [description(context), technique1(context), technique2(context), technique3(context)];

    Size mq = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(top: mq.height*0.04),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: CarouselSlider(
              items: pages,
              options: CarouselOptions(
                height: mq.height*0.6,
                viewportFraction: 1,
                enlargeCenterPage: true,
                onPageChanged: (index, _){
                  setState(() {
                    _currentPage = index;
                  });
                }
              )
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: mq.width*0.01),
                width: mq.width*0.06,
                height: mq.width*0.06,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentPage ? Theme.of(context).primaryColor : Colors.transparent,
                  border: Border.all(color: Theme.of(context).primaryColor, width: 2)
                ),
              )),
            ),
          )
        ],
      ),
    );
  }
}
