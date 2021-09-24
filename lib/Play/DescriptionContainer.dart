import 'dart:math';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rlogic/ThemeSwitcher/config.dart';

class DescriptionContainer extends StatefulWidget {
  DescriptionContainer({required this.gameName, required this.description, required this.controller});

  final String gameName;
  final Widget description;
  final ScrollController controller;

  @override
  _DescriptionContainerState createState() => _DescriptionContainerState();
}

class _DescriptionContainerState extends State<DescriptionContainer> with TickerProviderStateMixin{

  late bool _showFront;

  @override
  void initState() {
    super.initState();
    _showFront = true;
  }

  @override
  Widget build(BuildContext context) {

    Size mq = MediaQuery.of(context).size;

    return AnimatedContainer(
      curve: Curves.easeInOutQuint,
      duration: Duration(milliseconds: 500),
      height: _showFront ? mq.height*0.27 : mq.height*0.7,
      child: _showFront
        ? _buildFront(context)
        : _buildRear(context)
    );
  }

  void _switchCard() {
    setState(() {
      _showFront = !_showFront;
    });
  }

  Widget _buildFront(BuildContext context) {

    Size mq = MediaQuery.of(context).size;

    return Container(
      key: ValueKey(true),
      width: mq.width*0.9,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15.0),
        color: Theme.of(context).buttonColor,
        border: Border.all(
          color: Theme.of(context).primaryColorLight,
          width: 6,
        ),
      ),
      child: MaterialButton(
        padding: EdgeInsets.all(0),
        onPressed: () => Navigator.pushNamed(context, '/Play/${widget.gameName}'),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                child: Text(widget.gameName, style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Theme.of(context).textTheme.button!.color,
                    fontSize: mq.width*0.12
                  ),
                ),
                margin: EdgeInsets.only(left: mq.width*0.02, bottom: mq.height*0.003),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                child: IconButton(
                  onPressed: _switchCard,
                  icon: Icon(Icons.help_outline_outlined),
                  color: Theme.of(context).textTheme.headline5!.color,
                  splashRadius: mq.width*0.05,
                  iconSize: mq.width*0.08,
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildRear(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return Container(
      key: ValueKey(false),
      width: mq.width*0.9,
      height: mq.height*0.7,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15.0),
        color: Theme.of(context).primaryColorLight,
        border: Border.all(
          color: Colors.transparent,
          width: 6,
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                _switchCard();
              },
              icon: Icon(Icons.clear_outlined),
              color: Theme.of(context).primaryColor,
              splashRadius: mq.width*0.05,
              splashColor: Colors.black,
              iconSize: mq.width*0.08,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: NotificationListener<OverscrollNotification>(
              onNotification: (OverscrollNotification value){
                if (value.overscroll < 0 && widget.controller.offset + value.overscroll <= 0) {
                  if (widget.controller.offset != 0) widget.controller.jumpTo(0);
                  return true;
                }
                if (widget.controller.offset + value.overscroll >= widget.controller.position.maxScrollExtent) {
                  if (widget.controller.offset != widget.controller.position.maxScrollExtent) widget.controller.jumpTo(widget.controller.position.maxScrollExtent);
                  return true;
                }
                widget.controller.jumpTo(widget.controller.offset + value.overscroll);
                return true;
              },
              child: widget.description
            ),
          )
        ],
      ),
    );
  }
}
