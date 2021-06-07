import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';



class PageIndicator extends StatelessWidget {
  final int _counter;
  final pageCount;
  PageIndicator(this._counter,this.pageCount);


  _indicator(bool isActive){
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          height: 4.0,
          decoration: BoxDecoration(
            borderRadius: isActive ? BorderRadius.circular(100.0): BorderRadius.circular(0) ,
            color: isActive ? backgroundColorSec: Colors.grey[300],
            boxShadow: [
              BoxShadow(
                color: isActive ? backgroundColorSec: Colors.black12,
                offset: Offset(0.0,2.0),
                blurRadius: 2.0
              )
            ]
          ),
        ),
      ),
    );
  }



  _buildPageIndicator(){
    List<Widget> indicatorList = [];
    for(int i = 0; i < pageCount; i++){
      indicatorList.add(i == _counter ? _indicator(true): _indicator(false));
    }
    return indicatorList;
  }
  @override
  Widget build(BuildContext context) {
    return new Row(
      children: _buildPageIndicator(),
    );
  }
}
