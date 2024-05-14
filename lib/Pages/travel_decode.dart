import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skeleton_text/skeleton_text.dart';
import '../Constant/Style.dart';
import '../ServicesWorker/ConsumeAPI.dart';
import 'decode_by_number.dart';
import 'package:shouz/Constant/widget_common.dart';

class TravelDecode extends StatefulWidget {
  static String rootName = '/TravelDecodeNumber';
  @override
  _TravelDecodeState createState() => _TravelDecodeState();
}

class _TravelDecodeState extends State<TravelDecode> {
  ConsumeAPI consumeAPI = new ConsumeAPI();

  late Future<Map<dynamic, dynamic>> travelDecodeFull;

  @override
  void initState() {
    super.initState();
    travelDecodeFull = consumeAPI.getAllTravelFor();
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Style.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
          future: travelDecodeFull,
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
                                  "Vous n'avez aucun voyage à décoder",
                                  textAlign: TextAlign.center,
                                  style: Style.sousTitreEvent(15)),
                              SizedBox(height: 20),

                            ])),
                  );
                }
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: displayTravel(notificationsDeals['result']),
                    ),
                  ],
                );
            }
          }),
    );
  }

  Widget displayTravel(List<dynamic> atMoment){
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
                            type: 0,
                            title: "${atMoment[index]['beginCity']}->${atMoment[index]['endCity']}",
                            idOfType: atMoment[index]['_id'],)));
                } else {
                  Fluttertoast.showToast(
                      msg: 'Voyage terminé',
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
                      width: 170,
                      height: 135,
                      decoration: BoxDecoration(
                          border: Border.all(color: colorText, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: AssetImage('images/travel.jpg'),
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
                            Text(atMoment[index]['beginCity'].toString().toUpperCase(), style: Style.textBeginCity(11), maxLines: 2,),
                            Icon(Icons.arrow_circle_down, color: Colors.white,),
                            Text(atMoment[index]['endCity'].toString().toUpperCase(), style: Style.textEndCity(11), maxLines: 2,),
                            Text(
                                DateTime.parse(atMoment[index]['travelDate']).day.toString() +
                                    '/' +
                                    DateTime.parse(atMoment[index]['travelDate'])
                                        .month
                                        .toString() +
                                    '/' +
                                    DateTime.parse(atMoment[index]['travelDate'])
                                        .year
                                        .toString()+
                                    ' à ' +
                                    DateTime.parse(atMoment[index]['travelDate'])
                                        .hour
                                        .toString() +
                                    'h:' +
                                    DateTime.parse(atMoment[index]['travelDate'])
                                        .minute
                                        .toString(),
                                style: Style.titleNews(12)),
                            Text("${atMoment[index]['lieuRencontre']}", style: Style.simpleTextOnBoard(12),),
                            Row(
                              children: [
                                Icon(Icons.people, color: colorText,),
                                SizedBox(width: 5,),
                                Text(atMoment[index]['tickets'].toString(), style: Style.titleNews(14),)
                              ],
                            )
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
