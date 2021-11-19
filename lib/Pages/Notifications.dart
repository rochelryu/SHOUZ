import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:skeleton_text/skeleton_text.dart';

import 'ChatDetails.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>  with SingleTickerProviderStateMixin{
  TabController _controller;

  Future<Map<dynamic, dynamic>> notificationsFull;


  @override
  void initState() {
    super.initState();
    _controller =  new TabController(length: 3, vsync: this);
    new ConsumeAPI().videNotif();
    notificationsFull = new ConsumeAPI().getAllNotif();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prefix0.backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: prefix0.backgroundColor,
        title: Text('Notifications'),
        bottom: new TabBar(
          controller: _controller,
          unselectedLabelColor: Color(0xdd3c5b6d),
          labelColor: prefix0.colorText,
          indicatorColor: prefix0.colorText,
          tabs: [
            new Tab(
              text: 'Deals',
            ),
            new Tab(
              //icon: const Icon(Icons.shopping_cart),
              text: 'Events',
            ),
            new Tab(
              //icon: const Icon(Icons.shopping_cart),
              text: 'Travel',
            ),
          ],
        ),
      ),
      body:Container(
        height: MediaQuery.of(context).size.height,
        child: new TabBarView(
          controller: _controller,
          children: <Widget>[
            FutureBuilder(
                future: notificationsFull,
                builder:
                    (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Column(
                        children: <Widget>[
                          Expanded(
                              child: Center(
                                child: Text("Erreur de connexion avec le serveur",
                                    style: prefix0.Style.titreEvent(18)),
                              )),
                        ],
                      );
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
                                    bottom: 5.0),
                                child: Container(
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          prefix0.backgroundColor,
                                          prefix0.tint
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
                                          height: 50,
                                          width: 50,
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
                                                  height: 5,
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
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 40,
                                          width: 40,
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
                                    bottom: 5.0),
                                child: Container(
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          prefix0.backgroundColor,
                                          prefix0.tint
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
                                          height: 50,
                                          width: 50,
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
                                                  height: 5,
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
                                      SkeletonAnimation(
                                        child: Container(
                                          height: 40,
                                          width: 40,
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
                              );
                            },
                          ),
                        )
                      ]);

                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Column(children: <Widget>[
                          Expanded(
                              child: Padding(
                                  padding: EdgeInsets.all(30),
                                  child: Center(
                                      child: Text("${snapshot.error}",
                                          style: prefix0.Style.sousTitreEvent(
                                              15)))))
                        ]);
                      }
                      var notificationsDeals = snapshot.data;
                      if (notificationsDeals['result']['deals'].length == 0) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Center(
                              child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    new SvgPicture.asset(
                                      "images/not_notification.svg",
                                      semanticsLabel: 'NotNotificationDeals',
                                      height:
                                      MediaQuery.of(context).size.height *
                                          0.39,
                                    ),
                                    Text(
                                        "Vous n'avez aucune notication de deals pour le moment",
                                        textAlign: TextAlign.center,
                                        style: prefix0.Style.sousTitreEvent(15)),
                                    SizedBox(height: 20),

                                  ])),
                        );
                      }
                      return Column(
                        children: <Widget>[
                          Expanded(
                            child: today(notificationsDeals['result']['deals']),
                          ),
                        ],
                      );
                  }
                }),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20.0),
                Expanded(
                  child: today(prefix0.atMoment),
                ),

              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                (prefix0.atMois.length == 0) ? SizedBox(height: 10.0): Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[Text("Ce mois", style: prefix0.Style.titre(24.0)), FlatButton(
                      child: Text("voir plus", style: TextStyle(color: prefix0.colorText)), onPressed: (){ print('Voir plus'); },)
                    ],
                    )
                ),
                Expanded(
                  child: today(prefix0.atMois),
                ),

              ],
            ),


          ],
        ),
      ),
    );
  }

  Widget today(List<dynamic> atMoment){
    var item;
    if(atMoment.length != 0){
      item = new ListView.builder(
        shrinkWrap: true,
          itemCount: atMoment.length,
          itemBuilder: (context, index){
            return InkWell(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => ChatDetails(
                            room: atMoment[index]['room'],
                            productId: atMoment[index]['productId'],
                            name: atMoment[index]['name'],
                            onLine: atMoment[index]['onLine'],
                            profil: atMoment[index]['imageOtherUser'],
                            //authorId prend la valeur de idOtherUser
                            authorId: atMoment[index]['idOtherUser'])));
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: prefix0.colorText, width: 1.0),
                          borderRadius: BorderRadius.circular(50.0),
                          image: DecorationImage(
                            image: NetworkImage("${ConsumeAPI.AssetProfilServer}${atMoment[index]['imageOtherUser']}"),
                            fit: BoxFit.cover,
                          )
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(atMoment[index]['content'], style: prefix0.Style.contextNotif(11), maxLines: 3,)
                        ],
                      ),),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          image: DecorationImage(
                              image: NetworkImage("${ConsumeAPI.AssetProductServer}${atMoment[index]['nameImage']}"),
                              fit: BoxFit.cover
                          )
                      ),
                    )
                  ],
                ),
              ),
            );
          });
    }
    else item = new SizedBox(height: 10.0);

    return item;
  }
}

