import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:rlogic/UserData.dart';

class BullsCowsDescription extends StatefulWidget {
  const BullsCowsDescription();

  @override
  _BullsCowsDescriptionState createState() => _BullsCowsDescriptionState();
}

class _BullsCowsDescriptionState extends State<BullsCowsDescription> {

  int _currentPage = 0;

  Widget description(BuildContext context) {

    Size mq = MediaQuery.of(context).size;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              // margin: EdgeInsets.only(bottom: mq.height*0.01),
              child: Text(
                "Rules",
                style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Theme.of(context).primaryColor
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: mq.height*0.03),
                  padding: EdgeInsets.symmetric(horizontal: mq.width*0.02),
                  child: Text(
                    "Each game, the computer thinks of a 4-digit number with all different digits. The task is to guess this number with the least possible amount of tries. A bull represents a correct digit in a correct place. A cow represents a correct digit in a wrong place. When a number has 4 bulls, it means you guessed the number computer was thinking of.",
                    style: Theme.of(context).textTheme.headline2!.copyWith(
                        fontSize: mq.width * 0.05,
                        color: Theme.of(context).primaryColor
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: mq.width*0.5,
                    width: mq.width*0.5,
                    child: ClipRRect(
                      child: Image.asset(
                        UserData.getTheme() == "Light"
                            ? "assets/images/Bulls&Cows/Bulls&Cows-Example.jpg"
                            : "assets/images/Bulls&Cows/Bulls&Cows-Example-Dark.jpg",
                        fit: BoxFit.contain,
                        scale: 0.6,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget technique1(BuildContext context) {

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
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: mq.height*0.03),
                  padding: EdgeInsets.symmetric(horizontal: mq.width*0.02),
                  child: Text(
                    UserData.getTheme() == "Light"
                      ? "A good thing is to approximately understand which numbers have to be in the final answer. For this, divide set of gidits into three groups - {1, 2, 3, 4}, {5, 6, 7, 8}, {9, 0} and check them. For example,"
                      "in the game below, just with three attempts numbers 1 and 2 are eliminated after third attempt. So there must be 3 and 4, one number from {5, 6, 7, 8} and one number from {9, 0}. Then depending on more data, the whole number may be found. These first 2-3 steps greatly reduced the number of possible attempts."
                      : "A good thing is to approximately understand which numbers have to be in the final answer. For this, divide set of gidits into three groups - {1, 2, 3, 4}, {5, 6, 7, 8}, {9, 0} and check them. For example,"
                      "in the game below with first two attempts only digits from 0 to 8 are left. And another attempt gives a hint that either 7 or 8 is in a correct place and either 1 or 2 exists in the number, which greatly reduces the number of possible attempts.",
                    style: Theme.of(context).textTheme.headline2!.copyWith(
                        fontSize: mq.width * 0.05,
                        color: Theme.of(context).primaryColor
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: mq.width*0.5,
                    width: mq.width*0.5,
                    child: ClipRRect(
                      child: Image.asset(
                        UserData.getTheme() == "Light"
                            ? "assets/images/Bulls&Cows/Bulls&Cows-Technique1.jpg"
                            : "assets/images/Bulls&Cows/Bulls&Cows-Technique1-Dark.jpg",
                        fit: BoxFit.contain,
                        scale: 0.6,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> Pages = [];

  @override
  Widget build(BuildContext context) {

    Pages = [description(context), technique1(context)];

    Size mq = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(top: mq.height*0.04),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: CarouselSlider(
              items: Pages,
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
              children: List.generate(Pages.length, (index) =>
                Container(
                  margin: EdgeInsets.symmetric(horizontal: mq.width*0.01),
                  width: mq.width*0.06,
                  height: mq.width*0.06,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage ? Theme.of(context).primaryColor : Colors.transparent,
                      border: Border.all(color: Theme.of(context).primaryColor, width: 2)
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
