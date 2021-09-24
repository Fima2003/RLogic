import 'package:flutter/material.dart';

import 'Attempt.dart';

class AttemptBox extends StatefulWidget {
  final Attempt atmp;
  const AttemptBox(this.atmp);

  @override
  _AttemptBoxState createState() => _AttemptBoxState();
}

class _AttemptBoxState extends State<AttemptBox> {
  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).accentColor),
        borderRadius: BorderRadius.circular(5)
      ),
      height: mq.height*0.1,
      width: mq.width*0.6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("${widget.atmp.number}", style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: mq.width*0.06)),
          Text(
            "${widget.atmp.bulls}               ${widget.atmp.cows}",
            style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: mq.width*0.06)),
        ],
      ),
    );
  }
}
