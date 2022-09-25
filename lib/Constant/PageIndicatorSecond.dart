import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';



class PageIndicatorSecond extends StatelessWidget {
  final int _counter;
  final pageCount;
  PageIndicatorSecond(this._counter,this.pageCount);


  _indicator(bool isActive){
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          height: 4.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.0),
            color: isActive ? colorText: Colors.grey[300],
            boxShadow: [
              BoxShadow(
                color: isActive ? colorText: Colors.black12,
                offset: Offset(0.0,2.0),
                blurRadius: 2.0
              )
            ]
          ),
        ),
      ),
    );
  }



  _buildPageIndicatorSecond(){
    List<Widget> indicatorList = [];
    for(int i = 0; i < pageCount; i++){
      indicatorList.add(i == _counter ? _indicator(true): _indicator(false));
    }
    return indicatorList;
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: _buildPageIndicatorSecond(),
    );
  }
}
