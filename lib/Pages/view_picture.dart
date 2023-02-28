import 'package:flutter/material.dart';

import '../Constant/Style.dart';

class ViewPicture extends StatelessWidget {
  String linkPicture;
  ViewPicture({required Key key, required this.linkPicture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(child: Image.network(linkPicture)),
    );
  }
}
