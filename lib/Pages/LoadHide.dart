import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';


class LoadHide extends StatelessWidget {
  const LoadHide({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
  }
}