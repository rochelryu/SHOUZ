import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../Constant/Style.dart';
import '../ServicesWorker/ConsumeAPI.dart';

class NotAvailable extends StatelessWidget {
  const NotAvailable({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          SvgPicture.network(
              "${ConsumeAPI.AssetPublicServer}Work in progress-amico.svg",
              semanticsLabel: 'In Work',
              height: MediaQuery.of(context).size.height * 0.39,
          ),
            SizedBox(height: 15,),
          Text(
          "Service en cours de développement",
          textAlign: TextAlign.center,
          style: Style.sousTitreEvent(16)),
          SizedBox(height: 15,),
          Text(
          "Notre équipe travail pour la mise à disposition rapide de ce service afin d'offrir de plus grandes possibilités au publique",
          textAlign: TextAlign.center,
          style: Style.sousTitreEvent(11)),

    ],),
      )
    );
  }
}
