import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skeleton_text/skeleton_text.dart';

import '../Models/User.dart';
import '../Pages/ticket_detail.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import 'Style.dart';


Widget loadDataSkeletonOfActuality (BuildContext context) {
  return Padding(
    padding:
    EdgeInsets.only(top: 10.0, bottom: 10.0),
    child: Container(
      width: 300,
      margin: EdgeInsets.only(right: 20.0),
      height: 290,
      decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                blurRadius: 5.0,
                color: tint,
                offset: Offset(0.0, 1.0))
          ]),
      child: Stack(
        children: <Widget>[
          Container(
            height: 170.0,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [backgroundColor, tint],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                )),
          ),
          SkeletonAnimation(
            child: Container(
              height: 180.0,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  )),
            ),
          ),
          Positioned(
            top: 195.0,
            left: 10.0,
            right: 1.0,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonAnimation(
                  child: Container(
                    height: 15,
                    width: MediaQuery.of(context)
                        .size
                        .width *
                        0.6,
                    decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(
                            10.0),
                        color: Colors.grey[300]),
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .spaceEvenly,
                          children: <Widget>[
                            SkeletonAnimation(
                              child: Container(
                                height: 65,
                                width: 65,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                        100.0),
                                    color: Colors
                                        .grey[300]),
                              ),
                            ),
                            SizedBox(width: 5.0),
                            SkeletonAnimation(
                              child: Container(
                                width: 60,
                                height: 13,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                        10.0),
                                    color: Colors
                                        .grey[300]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}

Widget loadDataSkeletonOfDeals (BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 10.0,
        bottom: 5.0),
    child: Stack(
      children: <Widget>[
        Container(
          height: 200,
          width: MediaQuery.of(context)
              .size
              .width /
              2,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    backgroundColor,
                    tint
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment
                      .bottomRight),
              borderRadius:
              BorderRadius.only(
                  topLeft:
                  Radius.circular(
                      10.0),
                  bottomLeft:
                  Radius.circular(
                      10.0))),
          margin:
          EdgeInsets.only(top: 45.0),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    left: 15.0, top: 8.0),
                child: SkeletonAnimation(
                  child: Container(
                    height: 15,
                    width: MediaQuery.of(
                        context)
                        .size
                        .width *
                        0.6,
                    decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius
                            .circular(
                            10.0),
                        color: backgroundColorSec),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      left: 15.0),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .start,
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: <Widget>[
                      SkeletonAnimation(
                        child: Container(
                          height: 5,
                          width: 15,
                          decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                  10.0),
                              color: backgroundColorSec),
                        ),
                      ),
                      SizedBox(width: 5.0),
                      SkeletonAnimation(
                        child: Container(
                          height: 5,
                          width: 15,
                          decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                  10.0),
                              color: Colors
                                  .grey[
                              300]),
                        ),
                      ),
                    ],
                  )),
              Padding(
                padding: EdgeInsets.only(
                    left: 15.0),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .start,
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: <Widget>[
                    SkeletonAnimation(
                      child: Container(
                        height: 5,
                        width: 45,
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius
                                .circular(
                                10.0),
                            color: backgroundColorSec),
                      ),
                    ),
                    SizedBox(width: 15.0),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 15.0),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .start,
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: <Widget>[
                    SkeletonAnimation(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration:
                        BoxDecoration(
                          color: backgroundColorSec,
                          borderRadius: BorderRadius
                              .all(Radius
                              .circular(
                              30)),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    SkeletonAnimation(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration:
                        BoxDecoration(
                          color: backgroundColorSec,
                          borderRadius: BorderRadius
                              .all(Radius
                              .circular(
                              30)),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    SkeletonAnimation(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration:
                        BoxDecoration(
                          color: backgroundColorSec,
                          borderRadius: BorderRadius
                              .all(Radius
                              .circular(
                              30)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SkeletonAnimation(
                child: Container(
                  height: 40,
                  width: 180,
                  decoration: BoxDecoration(
                      color: backgroundColorSec,
                      borderRadius:
                      BorderRadius.only(
                          bottomLeft: Radius
                              .circular(
                              10.0))),
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          width: MediaQuery.of(context)
              .size
              .width /
              2.3,
          child: Material(
            elevation: 30.0,
            borderRadius: BorderRadius.only(
                topLeft:
                Radius.circular(10.0),
                topRight:
                Radius.circular(10.0),
                bottomRight:
                Radius.circular(10.0)),
            child: SkeletonAnimation(
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius
                        .only(
                        topLeft: Radius
                            .circular(
                            10.0),
                        topRight: Radius
                            .circular(
                            10.0),
                        bottomRight: Radius
                            .circular(
                            10.0)),
                    color:
                    backgroundColorSec),
              ),
            ),
          ),
        )
      ],
    ),
  );
}
Widget loadDataSkeletonOfEvent (BuildContext context, [double height = 235]) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: height,
    margin: EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
        color: tint,
        boxShadow: [
          BoxShadow(
              blurRadius: 5.0,
              color: tint,
              offset: Offset(0.0, 1.0))
        ]),
    child: Stack(
      children: <Widget>[
        Container(
          height: height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [backgroundColor, tint],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              ),
        ),
        SkeletonAnimation(
          child: Container(
            height: height,
            width: double.infinity,

          ),
        ),

      ],
    ),
  );
}

final otpInputDecoration = InputDecoration(
  contentPadding:
  EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: colorText),
  );
}
Widget dialogCustomError(String title, String message, BuildContext context) {
  bool isIos = Platform.isIOS;
  return isIos
      ? new CupertinoAlertDialog(
    title: Text(title),
    content: Text(message),
    actions: <Widget>[
      CupertinoDialogAction(
          child: Text("Ok"),
          onPressed: () {
            Navigator.of(context).pop();
          })
    ],
  )
      : new AlertDialog(
    title: Text(title),
    content: Text(message),
    elevation: 20.0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)),
    actions: <Widget>[
      TextButton(
          child: Text("Ok"),
          onPressed: () {
            Navigator.of(context).pop();
          })
    ],
  );
}

Widget dialogCustomForValidateAction(String title, String message, String titleValidateMessage, callback, BuildContext context, [bool withBackButton = true]) {
  bool isIos = Platform.isIOS;
  return isIos
      ? new CupertinoAlertDialog(
    title: Text(title),
    content: Text(message),
    actions: <Widget>[
     if(withBackButton) CupertinoDialogAction(
          child: Text("Annuler", style: Style.chatOutMe(15),),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      CupertinoDialogAction(
          child: Text(titleValidateMessage, style: Style.titleInSegmentInTypeError(),),
          onPressed: () async {
            await callback();
            Navigator.of(context).pop();
          }),
    ],
  )
      : new AlertDialog(
    title: Text(title),
    content: Text(message),
    elevation: 20.0,
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    actions: <Widget>[
      if(withBackButton) TextButton(
          child: Text("Annuler", style: Style.chatOutMe(15),),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      TextButton(
          child: Text(titleValidateMessage, style: Style.titleInSegmentInTypeError()),
          onPressed: () {
            callback();
            Navigator.of(context).pop();
          }),
    ],
  );
}

Widget dialogCustomForValidatePermissionNotification(String title, String message, String titleValidateMessage, callback, BuildContext context) {
  bool isIos = Platform.isIOS;
  return isIos
      ? new CupertinoAlertDialog(
    title: Text(title),
    content: Text(message),
    actions: <Widget>[
      CupertinoDialogAction(
          child: Text("Ne pas donner", style: Style.chatOutMe(15),),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      CupertinoDialogAction(
          child: Text(titleValidateMessage, style: Style.titleInSegmentInTypeRequest(),),
          onPressed: () async {
            await callback();
            Navigator.of(context).pop();
          }),
    ],
  )
      : new AlertDialog(
    title: Text(title),
    content: Text(message),
    elevation: 20.0,
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    actions: <Widget>[
      TextButton(
          child: Text("Ne pas donner", style: Style.chatOutMe(15),),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      TextButton(
          child: Text(titleValidateMessage, style: Style.titleInSegmentInTypeRequest()),
          onPressed: () {
            callback();
            Navigator.of(context).pop();
          }),
    ],
  );
}

Widget livraisonWidget(String assetFile, String title) {
  return Container(
    width: 120,
    height: 70,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 50,
          height: 50,
          child: Image.asset(assetFile, fit: BoxFit.contain),
        ),
        SizedBox(height: 5),
        Text(title, style: Style.chatIsMe(12))
      ],
    ),
  );
}

Widget  componentForDisplayTicketByEvent(List<dynamic> tickets, String eventTitle, var eventDate, User user) {
  return Container(
    padding: EdgeInsets.only(top: 5, bottom: 5, left: 12),
    height: 200,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Vos tickets déjà achetés : ", style: Style.sousTitreEvent(15),),
        SizedBox(height: 5),
        Expanded(
          child: ListView.builder(
              itemCount: tickets.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: 170,
                  margin: EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      Card(
                        elevation: 7.0,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                              return TicketDetail(eventTitle, tickets[index]['idEvent'], tickets[index]['_id'], tickets[index]['nameImage'], tickets[index]['placeTotal'],tickets[index]['priceTicket'],tickets[index]['typeTicket'], eventDate, user);
                            }));
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),

                            ),
                            child: Hero(
                              tag: tickets[index]['_id'],
                              child: CachedNetworkImage(
                                imageUrl: "${ConsumeAPI.AssetBuyEventServer}${tickets[index]['idEvent']}/${tickets[index]['nameImage']}",
                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                    Center(
                                        child: CircularProgressIndicator(value: downloadProgress.progress)),
                                errorWidget: (context, url, error) => notSignal(),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text("${tickets[index]['placeTotal'].toString()} Ticket${tickets[index]['placeTotal'] > 1 ? 's': ''} de ${tickets[index]['typeTicket'].toUpperCase() == 'GRATUIT' ? 'type': '' } ${tickets[index]['typeTicket']}", style: Style.simpleTextOnNews(), textAlign: TextAlign.center,)
                    ],
                  ),
                );
              }),
        ),
      ],
    ),
  );
}

Widget isErrorSubscribe(BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            "images/notconnection.svg",
            semanticsLabel: 'Not Connection',
            height: MediaQuery.of(context).size.height * 0.39,
          ),
          Text(
              "Un problème de connexion ! Veuillez verifier que vous disposez d'internet",
              textAlign: TextAlign.center,
              style: Style.sousTitreEvent(15)),

        ]),
  );
}

Widget isErrorLoadInfoBecauseNewPermissionAccording(BuildContext context, String text) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new SvgPicture.asset(
            "images/wait_vehicule_second.svg",
            semanticsLabel: 'Not Permission',
            height: MediaQuery.of(context).size.height * 0.39,
          ),
          Text(
              text,
              textAlign: TextAlign.center,
              style: Style.sousTitreEvent(15)),

        ]),
  );
}

Widget notSignal() {
  return Center(
    child: Icon(Icons.signal_cellular_connected_no_internet_4_bar_rounded, color: colorText,),
  );
}

CachedNetworkImage buildImageInCachedNetworkWithSizeManual(String urlImage, double width, double height, BoxFit fit ) {
  return CachedNetworkImage(
    imageUrl: urlImage,
    imageBuilder: (context, imageProvider) =>
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        ),
    progressIndicatorBuilder: (context, url, downloadProgress) =>
        Center(
            child: CircularProgressIndicator(value: downloadProgress.progress)),
    errorWidget: (context, url, error) => notSignal(),
  );
}

CachedNetworkImage buildImageInCachedNetworkSimpleWithSizeAuto(String urlImage,BoxFit fit) {
  return CachedNetworkImage(
    imageUrl: urlImage,
    imageBuilder: (context, imageProvider) =>
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        ),
    progressIndicatorBuilder: (context, url, downloadProgress) =>
        Center(
            child: CircularProgressIndicator(value: downloadProgress.progress)),
    errorWidget: (context, url, error) => notSignal(),
  );
}