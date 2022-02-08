import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Pages/EventInter.dart';
import 'package:shouz/Pages/Public.dart';
class Event extends StatefulWidget {
  @override
  _EventState createState() => new _EventState();
}

class _EventState extends State<Event> with SingleTickerProviderStateMixin {
  // TabController to control and switch tabs
  late TabController _tabController;

  // Current Index of tab
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController =
    new TabController(vsync: this, length: 2, initialIndex: _currentIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: backgroundColor,

      body: new Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: new Container(
              width: 255,
              decoration: new BoxDecoration(
                  border: new Border.all(color: colorText),
                borderRadius: BorderRadius.circular(30.0)
              ),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Sign In Button
                  new GestureDetector(
                    onTap: (){
                      _tabController.animateTo(0);
                      setState(() {
                      _currentIndex = 0;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _currentIndex == 0 ? colorText: Colors.transparent,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0),bottomLeft: Radius.circular(30.0))
                      ),
                      width: 125,
                      height: 40,
                      child: Center(
                        child: new Text("Evènements", style: Style.titleInSegment()),
                      ),
                    ),
                  ),
                  new GestureDetector(
                    onTap: (){
                      _tabController.animateTo(1);
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: _currentIndex == 1 ? colorText: Colors.transparent,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(30.0),bottomRight: Radius.circular(30.0))
                      ),
                      width: 125,
                      height: 40,
                      child: Center(
                        child: new Text("Publicité", style: Style.titleInSegment()),
                      ),
                    ),
                  ),
                  // Sign Up Button
                ],
              ),
            ),
          ),
          new Expanded(
            child: new TabBarView(
                controller: _tabController,
                // Restrict scroll by user
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  EventInter(),
                  Public()
                ],
            ),
          ),
        ],
      ),

    );
  }
}