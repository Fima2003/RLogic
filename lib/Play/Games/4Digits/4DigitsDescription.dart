import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:rlogic/UserData.dart';

class DigitsDescription extends StatefulWidget {
  const DigitsDescription();

  @override
  _DigitsDescriptionState createState() => _DigitsDescriptionState();
}

class _DigitsDescriptionState extends State<DigitsDescription> {

  Widget description(BuildContext context) {

    Size mq = MediaQuery.of(context).size;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
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
            Flexible(
              flex: 1,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: mq.height*0.03),
                  padding: EdgeInsets.symmetric(horizontal: mq.width*0.02),
                  child: Text(
                    "The task is using 4 given digits make an equality. Every digit can be used only once. There has to be an equality sign. You may merge digits. You may not use more than one digit when powering.",
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
                    width: mq.width*0.4,
                    height: mq.width*0.51,
                    child: ClipRRect(
                      child: Image.asset(
                        UserData.getTheme() == "Light"
                            ? "assets/images/4Digits/Digits-Empty.jpg"
                            : "assets/images/4Digits/Digits-Empty-Dark.jpg",
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    width: mq.width*0.4,
                    height: mq.width*0.51,
                    child: ClipRRect(
                      child: Image.asset(
                        UserData.getTheme() == "Light"
                            ? "assets/images/4Digits/Digits-Full.jpg"
                            : "assets/images/4Digits/Digits-Full-Dark.jpg",
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> pages = [];

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {

    pages = [description(context)];

    Size mq = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(top: mq.height*0.04),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: CarouselSlider(
              items: pages,
              options: CarouselOptions(
                enlargeCenterPage: true,
                onPageChanged: (index, _){
                  setState(() {
                    _currentPage = index;
                  });
                },
                height: mq.height*0.6,
                viewportFraction: 1,
              )
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) =>
                Container(
                  margin: EdgeInsets.symmetric(horizontal: mq.width*0.01),
                  width: mq.width*0.06,
                  height: mq.width*0.06,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentPage ? Theme.of(context).primaryColor : Colors.transparent,
                      border: Border.all(color: Theme.of(context).primaryColor, width: 2)
                  ),
                )
              ),
            ),
          )
        ],
      ),
    );
  }
}
