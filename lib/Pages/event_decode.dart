import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:shouz/Constant/widget_common.dart';

import '../Constant/Style.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import 'decode_by_number.dart';

class EventDecode extends StatefulWidget {
  static String rootName = '/EventDecodeNumber';
  @override
  _EventDecodeState createState() => _EventDecodeState();
}

class _EventDecodeState extends State<EventDecode> {
  ConsumeAPI consumeAPI = new ConsumeAPI();

  late Future<Map<dynamic, dynamic>> eventsDecodeFull;

  @override
  void initState() {
    super.initState();
    eventsDecodeFull = consumeAPI.getAllEventFor();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: FutureBuilder(
          future: eventsDecodeFull,
          builder:
              (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return isErrorSubscribe(context);
              case ConnectionState.waiting:
                return Column(children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: 15.0,
                              right: 15.0,
                              top: 10.0,
                              bottom: 15.0),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    backgroundColor,
                                    tint
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment
                                      .bottomRight),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: <Widget>[
                                SkeletonAnimation(
                                  child: Container(
                                    height: 170,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            10.0),
                                        color: Colors
                                            .grey[300]),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: SkeletonAnimation(
                                          child: Container(
                                            height: 20,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                color: Colors
                                                    .grey[
                                                300]),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15.0),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: SkeletonAnimation(
                                          child: Container(
                                            height: 5,
                                            width: 100,
                                            decoration: BoxDecoration(

                                                color: Colors
                                                    .grey[
                                                300]),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ]);

              case ConnectionState.active:
                return Column(children: <Widget>[
                        Expanded(
                              child: ListView.builder(
                                  itemCount: 3,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          left: 15.0,
                                          right: 15.0,
                                          top: 10.0,
                                          bottom: 15.0),
                                      child: Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                backgroundColor,
                                                tint
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment
                                                  .bottomRight),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: <Widget>[
                                            SkeletonAnimation(
                                              child: Container(
                                                height: 170,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        10.0),
                                                    color: Colors
                                                        .grey[300]),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                                    child: SkeletonAnimation(
                                                      child: Container(
                                                        height: 20,
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey[
                                                            300]),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 15.0),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                                    child: SkeletonAnimation(
                                                      child: Container(
                                                        height: 5,
                                                        width: 100,
                                                        decoration: BoxDecoration(

                                                            color: Colors
                                                                .grey[
                                                            300]),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    );
                                  },
                              ),
                        )
                ]);

              case ConnectionState.done:
                if (snapshot.hasError) {
                  return isErrorSubscribe(context);
                }
                var notificationsDeals = snapshot.data;
                if (notificationsDeals['result'].length == 0) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Center(
                        child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: <Widget>[
                              SvgPicture.network(
                                "${ConsumeAPI.AssetPublicServer}surveillance.svg",
                                semanticsLabel: 'NotSurveillance',
                                height:
                                MediaQuery.of(context).size.height *
                                    0.39,
                              ),
                              Text(
                                  "Vous n'avez aucun évènement à décoder",
                                  textAlign: TextAlign.center,
                                  style: Style.sousTitreEvent(15)),
                              SizedBox(height: 20),

                            ])),
                  );
                }
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: displayEvent(notificationsDeals['result']),
                    ),
                  ],
                );
            }
          }),
    );
  }

  Widget displayEvent(List<dynamic> atMoment){
    var item;
    if(atMoment.length != 0){
      item = ListView.builder(
          shrinkWrap: true,
          itemCount: atMoment.length,
          itemBuilder: (context, index){
            return InkWell(
              onTap: (){
                if(atMoment[index]['state'] > 0) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => DecodeByNumber(
                            key:UniqueKey(),
                            type: 1,
                            title: atMoment[index]['title'],
                            idOfType: atMoment[index]['_id'],)));
                } else {
                  Fluttertoast.showToast(
                      msg: 'Évènement terminé',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: colorError,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 150,
                      height: 160,
                      decoration: BoxDecoration(
                          border: Border.all(color: colorText, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: NetworkImage("${ConsumeAPI.AssetEventServer}${atMoment[index]['imageCover']}"),
                            fit: BoxFit.cover,
                          )
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(atMoment[index]['title'], style: Style.titreEvent(16), maxLines: 2,),
                            SizedBox(height: 10,),
                            Text(atMoment[index]['position'], style: Style.sousTitreEvent(14), maxLines: 2,),
                            SizedBox(height: 20,),
                            Text(
                                DateTime.parse(atMoment[index]['enventDate']).day.toString() +
                                    '/' +
                                    DateTime.parse(atMoment[index]['enventDate'])
                                        .month
                                        .toString() +
                                    '/' +
                                    DateTime.parse(atMoment[index]['enventDate'])
                                        .year
                                        .toString()+
                                    ' à ' +
                                    DateTime.parse(atMoment[index]['enventDate'])
                                        .hour
                                        .toString() +
                                    'h:' +
                                    DateTime.parse(atMoment[index]['enventDate'])
                                        .minute
                                        .toString(),
                                style: Style.simpleTextOnBoard(15)),
                          ],
                        ),),
                    ),

                  ],
                ),
              ),
            );
          });
    }
    else item = const SizedBox(height: 10.0);

    return item;
  }
}
