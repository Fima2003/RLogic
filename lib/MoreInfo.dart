import 'package:flutter/material.dart';
import 'package:rlogic/SomethingElse/app_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreInfo extends StatefulWidget {
  const MoreInfo();

  @override
  _MoreInfoState createState() => _MoreInfoState();
}

class _MoreInfoState extends State<MoreInfo> with SingleTickerProviderStateMixin{

  late AnimationController _controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    _controller.addListener(() {
      setState(() {});
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String patreonUrl = "https://www.patreon.com/fima__rubin";

  _launchInsta() async{
    const InstaUrl = "https://www.instagram.com/fima__rubin/";
    if(await canLaunch(InstaUrl)){
      await launch(InstaUrl,
          // forceWebView: true,
          // forceSafariVC: true
      );
    }else{
      throw 'could not launch url';
    }
  }

  _launchTwitter() async{
    const TwitterUrl = "https://twitter.com/EfimRubin1";
    if(await canLaunch(TwitterUrl)){
      await launch(TwitterUrl,
        // forceWebView: true,
        // forceSafariVC: true
      );
    }else{
      throw 'could not launch url';
    }
  }

  _launchPatreon() async{
    const PatreonUrl = "https://www.patreon.com/fima__rubin";
    if(await canLaunch(PatreonUrl)){
      await launch(PatreonUrl,
        // forceWebView: true,
        // forceSafariVC: true
      );
    }else{
      throw 'could not launch url';
    }
  }

  @override
  Widget build(BuildContext context) {

    Size mq = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            padding: EdgeInsets.all(mq.width*0.05),
            height: mq.height*0.7,
            width: mq.width*0.8,
            decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0))),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: mq.height*0.5,
                    width: mq.width*0.7,
                    child: Text(
                      "HELLO! I am Fima. This is the first step of my big project. \n\n"
                      "If you want to follow and help me create it "
                      "faster, support me on Patreon!\n\n"
                      "If you have any proposals, dm me on twitter or instagram!😉\n\n"
                      "Enjoy!\n",
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(AppIcons.icons8_instagram_logo),
                        onPressed: _launchInsta,
                        color: Color.fromRGBO(121, 67, 174, 1),
                        iconSize: mq.width*0.1,
                      ),
                      IconButton(
                        icon: Icon(AppIcons.icons8_twitter),
                        onPressed: _launchTwitter,
                        color: Color.fromRGBO(73, 161, 235, 1),
                        iconSize: mq.width*0.1,
                      ),
                      IconButton(
                        icon: Icon(AppIcons.icons8_patreon),
                        onPressed: _launchPatreon,
                        color: Color.fromRGBO(231, 112, 91, 1),
                        iconSize: mq.width*0.1,
                      )
                    ],
                  ),
                ],
              ),
            )
          ),
        ),
      ),
    );
  }
}