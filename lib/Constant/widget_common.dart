import 'dart:async';
import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';
import 'package:photo_view/photo_view.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:ticket_widget/ticket_widget.dart';

import '../MenuDrawler.dart';
import '../Models/User.dart';
import '../Pages/share_ticket.dart';
import '../Pages/ticket_detail.dart';
import '../Pages/view_picture.dart';
import '../Provider/Audio.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import 'Style.dart';
import 'helper.dart';

Location location = Location();

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

Widget detailTicket(String idTicket, String idEvent, String nameImage, int placeTotal, String typeTicket, int priceTicket, List<dynamic> timesDecode, String registerDate, int durationEventByDay, String nameEvent, BuildContext context, [bool removeTicket = false]) {
  final consumeAPI = ConsumeAPI();
  return Center(
    child:TicketWidget(
        padding: EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push((MaterialPageRoute(
                        builder: (context) => ShareTicket(key: UniqueKey(), ticketId: idEvent, placeTotal: placeTotal, typeTicket: typeTicket))));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(width: 1.0, color: colorSuccess),
                    ),
                    child: Center(
                      child: Text(
                        'Partager',
                        style: TextStyle(color: colorSuccess),
                      ),
                    ),
                  ),
                ),
                if(removeTicket && placeTotal < 3) GestureDetector(
                  onTap: () async {
                    final shareTicket = await consumeAPI.dropEventTicket(idTicket);
                    if(shareTicket['etat'] == 'found') {
                      await askedToLead(
                          "Ticket Annulé votre compte vient de recevoir 90% du montant total du ticket",
                          true, context);
                      Timer(Duration(seconds: 3), () {
                        Navigator.of(context).pushNamedAndRemoveUntil(MenuDrawler.rootName, (Route<dynamic> route) => false);
                      });

                    }
                    else {
                      await askedToLead(shareTicket['error'], false, context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(width: 1.0, color: colorError),
                    ),
                    child: Center(
                      child: Text(
                        'Annuler',
                        style: TextStyle(color: colorError),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(nameEvent, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: Style.grandTitreBlack(14.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ticketDetailsWidget('Type ticket', typeTicket.toString().toUpperCase() == 'GRATUIT' ? typeTicket: reformatNumberForDisplayOnPrice(int.parse(typeTicket)) , 'Nbre place', placeTotal.toString()),
                  SizedBox(height: 10),
                  ticketDetailsWidget('Prix achat', reformatNumberForDisplayOnPrice(priceTicket), 'Utilisation', '${timesDecode.length.toString()}/$durationEventByDay'),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Date achat",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            formatedDateForLocal(DateTime.parse(registerDate)),
                            style: const TextStyle(color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 190,
                    width: 190,
                    child: Hero(
                        tag: idTicket,
                        child: CachedNetworkImage(
                          imageUrl: "${ConsumeAPI.AssetBuyEventServer}$idEvent/$nameImage",
                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                              Center(
                                  child: CircularProgressIndicator(value: downloadProgress.progress)),
                          errorWidget: (context, url, error) => notSignal(),
                          fit: BoxFit.cover,
                        )
                    )),

              ],
            ))
          ],
        )
    ),
  );
}

Widget ticketDetailsWidget(String firstTitle, String firstDesc,
    String secondTitle, String secondDesc) {
  return Row(
    children: [
      Expanded(
        flex: 3,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                firstTitle,
                style: const TextStyle(color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  firstDesc,
                  style: const TextStyle(color: Colors.black),
                ),
              )
            ],
          ),
        ),
      ),
      Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  secondTitle,
                  style: const TextStyle(color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    secondDesc,
                    style: const TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ))
    ],
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
      ? CupertinoAlertDialog(
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
      : AlertDialog(
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

Widget dialogCustomForValidateAction(String title, String message, String titleValidateMessage, callback, BuildContext context, [bool withBackButton = true, String titleBackButton = "Annuler"]) {
  bool isIos = Platform.isIOS;
  return isIos
      ? CupertinoAlertDialog(
    title: Text(title),
    content: Text(message),
    actions: <Widget>[
     if(withBackButton) CupertinoDialogAction(
          child: Text(titleBackButton, style: Style.chatOutMe(15),),
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
      : AlertDialog(
    title: Text(title),
    content: Text(message),
    elevation: 20.0,
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    actions: <Widget>[
      if(withBackButton) TextButton(
          child: Text(titleBackButton, style: Style.chatOutMe(15),),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      TextButton(
          child: Text(titleValidateMessage, style: Style.titleInSegmentInTypeError()),
          onPressed: () async  {
            await callback();
            Navigator.of(context).pop();
          }),
    ],
  );
}

Widget dialogCustomForNotChangeProfil(String title, String message, String titleValidateMessage, callback, BuildContext context, [bool withBackButton = true, String titleBackButton = "Annuler"]) {
  bool isIos = Platform.isIOS;
  return isIos
      ? CupertinoAlertDialog(
    title: Text(title),
    content: Text(message),
    actions: <Widget>[
      if(withBackButton) CupertinoDialogAction(
          child: Text(titleBackButton, style: Style.chatOutMe(15),),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      CupertinoDialogAction(
          child: Text(titleValidateMessage, style: Style.titleInSegmentInTypeError(),),
          onPressed: () async {
            await callback();
          }),
    ],
  )
      : AlertDialog(
    title: Text(title),
    content: Text(message),
    elevation: 20.0,
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    actions: <Widget>[
      if(withBackButton) TextButton(
          child: Text(titleBackButton, style: Style.chatOutMe(15),),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      TextButton(
          child: Text(titleValidateMessage, style: Style.titleInSegmentInTypeError()),
          onPressed: () async  {
            await callback();
          }),
    ],
  );
}

Widget dialogCustomForValidatePermissionNotification(String title, String message, String titleValidateMessage, callback, BuildContext context) {
  bool isIos = Platform.isIOS;
  return isIos
      ? CupertinoAlertDialog(
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
      : AlertDialog(
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

Widget  componentForDisplayTicketByEvent(List<dynamic> tickets, String eventTitle, User user) {
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
                  child: Column(
                    children: [
                      Card(
                        elevation: 7.0,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                              return TicketDetail(
                                  eventTitle,
                                  tickets[index]['idEvent'],
                                  tickets[index]['_id'],
                                  tickets[index]['nameImage'],
                                  tickets[index]['placeTotal'],
                                  tickets[index]['priceTicket'],
                                  tickets[index]['typeTicket'],
                                  tickets[index]['registerDate'],
                                  user,
                                  tickets[index]['timesDecode'],
                                  tickets[index]['durationEventByDay'],
                              );
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

Widget isErrorSubscribe(BuildContext context, [double height = 0]) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    height: height == 0 ? MediaQuery.of(context).size.height : height,
    width: MediaQuery.of(context).size.width,
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            "images/notconnection.svg",
            semanticsLabel: 'Not Connection',
            height: height == 0 ? MediaQuery.of(context).size.height * 0.39 : height * 0.5,
          ),
          Text(
              "Un problème de connexion ! Veuillez verifier que vous disposez d'internet",
              textAlign: TextAlign.center,
              style: Style.sousTitreEvent(15)),

        ]),
  );
}

Widget isNotPermissionLocationActuality(BuildContext context, [double height = 0]) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    height: height == 0 ? MediaQuery.of(context).size.height : height,
    width: MediaQuery.of(context).size.width,
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.network(
            "${ConsumeAPI.AssetPublicServer}news_permission.svg",
            semanticsLabel: 'Not Permission',
            height: height == 0 ? MediaQuery.of(context).size.height * 0.39 : height * 0.5,
          ),
          Text(
              "Suivez l'actualité et soyez informé des dernières offres d'emploi et appel d'offres de votre localité.",
              textAlign: TextAlign.center,
              style: Style.sousTitreEvent(13)),
          SizedBox(height: 15,),
          ElevatedButton(
            onPressed: () async {
              if(Platform.isIOS) {
                await location.requestPermission();
              } else {
                await openSettingApp();
              }

            },
            child: Text('Autoriser la localisation'),
            style: raisedButtonStyle,
          ),
          SizedBox(height: 15,),
          SizedBox(height: 15,),
          Text(
              "Votre position exacte est nécessaire pour vous présenter les actualités et offres d'emploi de votre localité.",
              textAlign: TextAlign.center,
              style: Style.sousTitreEvent(11)),
          SizedBox(height: 15,),
          Text(messageForActivatePermissionNotification(),
              textAlign: TextAlign.center,
              style: Style.sousTitreEvent(11)),

        ]),
  );
}

Widget isNotPermissionLocationTravel(BuildContext context, [double height = 0]) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15.0),
    height: height == 0 ? MediaQuery.of(context).size.height : height,
    width: MediaQuery.of(context).size.width,
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.network(
            "${ConsumeAPI.AssetPublicServer}driving.svg",
            semanticsLabel: 'Not Permission',
            height: height == 0 ? MediaQuery.of(context).size.height * 0.39 : height * 0.5,
          ),
          Text(
              "Payez 2 fois plus moins chers, avec des tarifs qui se reduisent au lieu d'augmenter.",
              textAlign: TextAlign.center,
              style: Style.sousTitreEvent(13)),
          SizedBox(height: 15,),
          ElevatedButton(
            onPressed: () async {
              if(Platform.isIOS) {
                await location.requestPermission();
              } else {
                await openSettingApp();
              }

            },
            child: Text('Autoriser la localisation'),
            style: raisedButtonStyleSuccess,
          ),
          SizedBox(height: 15,),
          Text(
              "Votre position exacte est nécessaire pour que le chauffeur puisse vous prendre là où vous êtes.",
              textAlign: TextAlign.center,
              style: Style.sousTitreEvent(11)),
          SizedBox(height: 15,),
          Text(messageForActivatePermissionNotification(),
              textAlign: TextAlign.center,
              style: Style.sousTitreEvent(11)),

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
          SvgPicture.asset(
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

//Discussion
Widget sendEtatForChat(etat, isMe) {
  if (isMe) {
    if (etat) {
      return Icon(Icons.check_circle_outline,
          color: Colors.white, size: 12.0);
    } else {
      return Icon(Icons.check, color: Colors.white, size: 12.0);
    }
  } else {
    return SizedBox(width: 1.0);
  }
}

Widget boxMessage({
  required BuildContext context,
  required bool isMe,
  required String message,
  required bool isReadByOtherUser,
  required callback,
  required int indexContent,
  required String room,
  required String ident,
  required String image,
  required String registerDate,
  required String idDocument,
}) {
  return Container(
    margin: EdgeInsets.all(10.0),
    padding:
    isMe ? EdgeInsets.only(left: 40) : EdgeInsets.only(right: 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  color: isMe ? colorText : Colors.white,
                  borderRadius: isMe
                      ? BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                      : BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )),
              child: InkWell(
                onLongPress: () {
                  if(isMe) {
                    showAdaptiveActionSheet(
                      context: context,
                      title: Text('Plus d\'options', style: Style.simpleTextInContainer(Colors.black54),),
                      androidBorderRadius: 30,
                      actions: <BottomSheetAction>[
                        if(message != '') BottomSheetAction(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.copy, color: colorText,),
                                Text('Copier', style: Style.sousTitre(15, colorText),),
                              ],
                            ), onPressed: (context) {
                          Navigator.pop(context);
                          Clipboard.setData(ClipboardData(text: message))
                              .then((value) { //only if ->
                            displaySnackBar(context, "Texte copié avec succès");
                          });
                        }),
                        BottomSheetAction(title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, color: colorError,),
                            Text('Supprimer', style: Style.sousTitre(15, colorError),),
                          ],
                        ), onPressed: (context) {
                          Navigator.pop(context);
                          if(isReadByOtherUser) {
                            displaySnackBar(context, "Message déjà lu par le destinataire donc nous ne pouvons le supprimer.");
                          } else {
                            callback(indexContent, room, ident);
                          }
                        }),
                      ],
                      cancelAction: CancelAction(title: Text('Retour', style: Style.sousTitre(15, colorBlack),)),// onPressed parameter is optional by default will dismiss the ActionSheet
                    );
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (image != '') ClipRRect(
                      borderRadius: isMe
                          ? BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      )
                          : BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: image.indexOf('.m4a') == -1 ? GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => ViewPicture(key: UniqueKey(), linkPicture: "${ConsumeAPI.AssetConversationServer}$idDocument/$image",)));
                        },
                        child: CachedNetworkImage(
                          imageUrl: "${ConsumeAPI.AssetConversationServer}$idDocument/$image",
                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                              Center(
                                  child: CircularProgressIndicator(value: downloadProgress.progress)),
                          errorWidget: (context, url, error) => notSignal(),
                        ),
                      ): LoadAudioAsset(
                        url:
                        "${ConsumeAPI.AssetConversationServer}$idDocument/$image",
                        isMe: isMe,
                        key: UniqueKey(),
                      ),
                    ),

                    if(message != '') Container(
                      child: Text(
                        message,
                        style: isMe
                            ? Style.chatIsMe(15)
                            : Style.chatOutMe(15.0),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    registerDate,
                    style: Style.chatIsMe(12),
                  ),
                  SizedBox(width: 7),
                  sendEtatForChat(isReadByOtherUser, isMe),
                ],
              ),
            )
          ],
        )
      ],
    ),
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
          child: PhotoView(
            imageProvider: imageProvider,
            minScale: PhotoViewComputedScale.contained * 1,
          ),
        ),
    progressIndicatorBuilder: (context, url, downloadProgress) =>
        Center(
            child: CircularProgressIndicator(value: downloadProgress.progress)),
    errorWidget: (context, url, error) => notSignal(),
  );
}

 displaySnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
      ));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Widget customSwitch(bool value, callback) {
  if(Platform.isIOS) {
    return CupertinoSwitch(
      value: value,
      activeColor: colorText,
      onChanged: (bool value) {
        callback();
      },
    );
  }
  else {
    return Switch(
      value: value,
      activeColor: colorText,
      onChanged: (bool value) {
        callback();
      },
    );
  }
}