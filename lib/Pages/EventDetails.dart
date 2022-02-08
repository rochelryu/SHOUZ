import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Constant/CircularClipper.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:shouz/Constant/VerifyUser.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart' as prefix1;
import 'package:shouz/Pages/add_decodeur.dart';
import 'package:shouz/Pages/result_buy_event.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:video_player/video_player.dart';

import '../Constant/Style.dart';
import '../Models/User.dart';

class EventDetails extends StatefulWidget {
  var imageUrl;
  var prixTicket = [];
  var placeTicket = [];
  var allTicket = [];
  var numberFavorite;
  var state;
  var id;
  var positionRecently;
  var numberTicket;
  var enventDate;
  var authorName;
  var describe;
  var position;
  bool favorite;
  var index;
  var title;
  var videoPub;
  var authorId;
  int cumulGain;
  int stateEvent;
  bool isMeAuthor;
  EventDetails(
      this.imageUrl,
      this.index,
      prixTicket,
      this.numberFavorite,
      this.authorName,
      this.describe,
      this.id,
      this.numberTicket,
      this.position,
      this.enventDate,
      this.title,
      this.positionRecently,
      this.state,
      this.videoPub, this.allTicket, this.authorId, this.cumulGain, this.isMeAuthor, this.stateEvent, this.favorite) {
    this.prixTicket = prixTicket
        .map((value) => value['price'].toString().trim() == "Gratuit"
            ? {"price": "Gratuit", "choice": 0}
            : {"price": int.parse(value['price']), "choice": 0})
        .toList();
    this.placeTicket = prixTicket
        .map((value) => value['numberPlace'].toString())
        .toList();
  }

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  late AppState appState;
  List checkPros = [];
  List checkPlacePros = [];
  int place = 0;
  int priceItem = 0;
  int state = 1;
  String choice = '';
  late bool favo;
  bool gratuitPass = false;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  late User user = new User('', '');
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late int placeTotal;

  Future getInfo() async {
    try {
      final me = await DBProvider.db.getClient();
      setState(() {
        user = me;
      });
    } catch (e) {
      print("Erreur $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getInfo();
    checkPros = widget.prixTicket;
    checkPlacePros = widget.placeTicket;
    favo = widget.favorite;
    state = widget.state;
    placeTotal = widget.numberTicket;

  }

  @override
  Widget build(BuildContext context) {
    bool isIos = Platform.isIOS;
    double _width = MediaQuery.of(context).size.width;
    appState = Provider.of<AppState>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: prefix0.backgroundColor,
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                child: Hero(
                  tag: widget.index,
                  child: ClipShadowPath(
                      clipper: CircularClipper(),
                      shadow: Shadow(blurRadius: 20.0),
                      child: Image(
                        height: 400,
                        width: double.infinity,
                        image: NetworkImage(
                            "${ConsumeAPI.AssetEventServer}${widget.imageUrl}"),
                        fit: BoxFit.cover,
                      )),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  (isIos)
                      ? Container(
                          margin: EdgeInsets.only(left: 10.0),
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: LinearGradient(
                                colors: [Color(0x00000000), prefix0.tint],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.close,
                                color: Colors.white, size: 22.0),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        )
                      : SizedBox(width: 10.0),
                  Container(
                    margin: EdgeInsets.only(right: 10.0),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: LinearGradient(
                          colors: [Color(0x00000000), prefix0.tint],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.favorite,
                          color: (favo) ? Colors.redAccent : Colors.grey,
                          size: 22.0),
                      onPressed: () {
                        setState(() {
                          favo = !favo;
                        });
                      },
                    ),
                  ),
                ],
              ),
              widget.videoPub != 'null'
                  ? Positioned.fill(
                      bottom: 20,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: RawMaterialButton(
                          padding: EdgeInsets.all(10.0),
                          elevation: 12.0,
                          onPressed: () {
                            Navigator.of(context)
                                .push((MaterialPageRoute(builder: (context) {
                              return ViewerEvent(
                                  imgUrl: widget.imageUrl,
                                  videoUrl: widget.videoPub);
                            })));
                          },
                          shape: CircleBorder(),
                          fillColor: Colors.white,
                          child: Icon(
                            Icons.play_arrow,
                            color: prefix0.backgroundColorSec,
                            size: 40.0,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 10,
                    ),
              Positioned(
                bottom: 0.0,
                right: 10.0,
                child: IconButton(
                  onPressed: () => print(widget.imageUrl),
                  icon: Icon(Icons.share, color: Colors.white),
                  iconSize: 30.0,
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
            child: Column(
              children: <Widget>[
                Container(
                    child: Text(widget.title.toUpperCase(),
                        style: prefix0.Style.titre(17.0),
                        textAlign: TextAlign.center)),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Icon(prefix1.MyFlutterAppSecond.pin,
                              color: Colors.white, size: 18.0)),
                      Expanded(
                          flex: 10,
                          child: Text(
                            widget.position,
                            maxLines: 2,
                            style: prefix0.Style.sousTitre(12.0),
                          ))
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text('Date', style: prefix0.Style.sousTitre(15)),
                        Text(
                            DateTime.parse(widget.enventDate).day.toString() +
                                '/' +
                                DateTime.parse(widget.enventDate)
                                    .month
                                    .toString() +
                                '/' +
                                DateTime.parse(widget.enventDate)
                                    .year
                                    .toString(),
                            style: prefix0.Style.titre(18))
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text('Heure', style: prefix0.Style.sousTitre(15)),
                        Text(
                            DateTime.parse(widget.enventDate).hour.toString() +
                                ':' +
                                DateTime.parse(widget.enventDate)
                                    .minute
                                    .toString(),
                            style: prefix0.Style.titre(20))
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text('Distance', style: prefix0.Style.sousTitre(15)),
                        Text(
                            (widget.positionRecently['longitude'] == 0)
                                ? 'N/A'
                                : '2.2 Km',
                            style: prefix0.Style.titre(20))
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Container(
                  height: double.parse((widget.describe.toString().length / 1.9).toString()),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.describe,
                      style: prefix0.Style.sousTitre(12),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ],
            ),
          ),
          widget.allTicket.length > 0 ? componentForDisplayTicketByEvent(widget.allTicket, widget.title, widget.enventDate, user) : SizedBox(width: 10),
          Row(
            children: <Widget>[
              SizedBox(
                width: 16,
              ),
              Text("Prix :", style: prefix0.Style.sousTitreEvent(15.0))
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 16),
            height: 100,
            width: double.infinity,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: checkPros.length,
              itemBuilder: (context, i) {
                return new InkWell(
                  onTap: () {
                    var newTable = [];
                    widget.prixTicket.forEach((value) {
                      newTable.add({"choice": 0, "price": value["price"]});
                    });
                    newTable[i]["choice"] = 1;
                    setState(() {
                      checkPros = newTable;
                      choice = newTable[i]["price"].toString();
                      priceItem = (choice == "Gratuit")
                          ? priceItem
                          : newTable[i]["price"] * place;
                    });
                  },
                  child: Card(
                    elevation: 4.0,
                    color: (checkPros[i]['choice'] == 0)
                        ? prefix0.backgroundColor
                        : Colors.white,
                    child: Container(
                      width: _width / 3.4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('${checkPros[i]['price'].toString()} ${checkPros[i]['price'].toString() == 'Gratuit' ? '': user.currencies}',
                              style: TextStyle(
                                  color: (checkPros[i]['choice'] == 0)
                                      ? Colors.white
                                      : prefix0.backgroundColor,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Montserrat")),
                          (checkPros[i]['price'].toString() == "Gratuit")
                              ? SizedBox(width: 10)
                              : Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('Ticket(s): ',
                                    style: TextStyle(
                                        color: (checkPros[i]['choice'] == 0)
                                            ? Colors.white
                                            : prefix0.backgroundColor,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Montserrat")),
                                Text(checkPlacePros[i],
                                    style: TextStyle(
                                        color: (checkPros[i]['choice'] == 0)
                                            ? Colors.white
                                            : prefix0.backgroundColor,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Montserrat")),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 16),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      "Places restantes: ",
                      style: prefix0.Style.sousTitre(15),
                    ),
                    Text(
                      placeTotal.toString(),
                      style: prefix0.Style.sousTitre(15),
                    ),
                  ],
                ),
              ),
              widget.isMeAuthor ? Container(
                height: 30,
                padding: EdgeInsets.only(left: 5),
                margin: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Text("Cumul Gain: ${widget.cumulGain.toString()}", style: prefix0.Style.sousTitre(15),)
                  ],
                )
              ) :
              Container(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.do_not_disturb_on,
                          color: prefix0.colorText),
                      onPressed: () {
                        var normal = (place > 0) ? place - 1 : 0;
                        setState(() {
                          placeTotal =
                              (place != 0) ? placeTotal + 1 : placeTotal;
                          place = normal;
                          priceItem = (choice == "Gratuit")
                              ? 0
                              : normal * int.parse(choice);
                        });
                      },
                    ),
                    Text(place.toString(), style: prefix0.Style.titre(29)),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: prefix0.colorText),
                      onPressed: () {
                        var normal = 0;

                        if(placeTotal > place) {
                          normal = (placeTotal > place) ? place + 1 : placeTotal;
                        } else {
                          if(placeTotal > 0) {
                            normal = place + 1;
                          } else {
                            normal = place;
                          }
                        }
                        setState(() {
                          place = normal;
                          placeTotal =
                              (placeTotal > 0) ? placeTotal - 1 : placeTotal;
                          priceItem = (choice == "Gratuit")
                              ? 0
                              : normal * int.parse(choice);
                        });
                      },
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          Container(
            margin: EdgeInsets.all(10),
            height: 60,
            width: double.infinity,
            padding: EdgeInsets.only(
                left: 20.0, top: 10.0, right: 10.0, bottom: 10.0),
            decoration: BoxDecoration(
                color: prefix0.backgroundColorSec,
                borderRadius: BorderRadius.circular(30)),
            child: widget.isMeAuthor ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                reformatStateAuthor(state),
              ],
            ) : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  priceItem.toString(),
                  style: prefix0.Style.titre(28),
                ),
                FlatButton(
                  color: prefix0.colorText,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Text("Acheter", style: prefix0.Style.titre(18)),
                  onPressed: () {
                    print('${priceItem.toString()} ${place.toString()} ${user.wallet.toString()}, $choice');
                    if ((priceItem != 0 || choice == "Gratuit") && priceItem <= user.wallet) {
                      print('${priceItem.toString()} ${place.toString()} ${user.wallet.toString()}, $choice');
                      appState.setIdEvent(widget.id);
                      appState.setNumberTicket(place);
                      appState.setPriceTicketTotal(priceItem.toString());
                      appState.setPriceUnityTicket(choice);

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (builder) => VerifyUser(
                              redirect: ResultBuyEvent.rootName, key: UniqueKey(),)));
                    } else if(priceItem > user.wallet) {
                      _displaySnackBar(context, 'Votre  est insuffisant, vous n\'avez que ${double.parse(user.wallet.toString()).toString()}');
                    } else{
                      _displaySnackBar(context, 'Pour acheter des tickets il vous faut imperativement sélectionner un prix et un nombre de place',);
                    }

                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget reformatStateAuthor(int state) {
    if(state == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Gain pas encore retirable', style: Style.titre(10),),
          ElevatedButton(onPressed: (){
            Navigator.of(context)
                .push((MaterialPageRoute(builder: (context) {
              return AddDecodeur(
                  key: UniqueKey(),
                  eventId: widget.id);
            })));
          }, style: raisedButtonStyle,
            child: Text('Attribuer décodeur'),)
        ],
      );
    } else if (state == 2) {
      return FlatButton(
        color: prefix0.colorText,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)),
        child: Text("Recuperer Gain", style: prefix0.Style.titre(18)),
        onPressed: () async {
          final data = await consumeAPI.recupCumul(widget.id);
          if(data['etat'] == 'found') {
            setState(() {
              state = 3;
            });
            _displaySnackBar(context, "🥳 Gain récupéré avec succès");
          } else {
            _displaySnackBar(context, data['error']);
          }
        },
      );
    } else {
      return Text('Gain plus retirable', style: Style.titleDealsProduct(),);
    }
  }

  _displaySnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(
        content: Text(
      text,
      textAlign: TextAlign.center,
    ));
    _scaffoldKey.currentState?.showSnackBar(snackBar);
  }
}

class ViewerEvent extends StatefulWidget {
  var imgUrl;
  var videoUrl;
  ViewerEvent({this.imgUrl, this.videoUrl});
  @override
  _ViewerEventState createState() => _ViewerEventState();
}

class _ViewerEventState extends State<ViewerEvent> {
  late VideoPlayerController _controller;
  late Future<void> _initialiseVideoFlutter;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        "${ConsumeAPI.AssetEventServer}${widget.videoUrl}");

    _controller.setLooping(true);
    _controller.setVolume(1.0);
    setState(() {
      _initialiseVideoFlutter = _controller.initialize();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        floatingActionButton: (widget.videoUrl == 'null')
            ? SizedBox(
                width: 10.0,
              )
            : FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
        body: Center(
          child: (widget.videoUrl == 'null')
              ? Image.network("${ConsumeAPI.AssetEventServer}${widget.imgUrl}")
              : FutureBuilder(
                  future: _initialiseVideoFlutter,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Column(
                          children: <Widget>[
                            Expanded(
                                child: Center(
                              child: Text("Echec de connexion",
                                  style: prefix0.Style.titreEvent(18)),
                            )),
                          ],
                        );
                      case ConnectionState.waiting:
                        return Column(
                          children: <Widget>[
                            Expanded(
                                child: Center(
                              child: Text("Chargement en cours...",
                                  style: prefix0.Style.titreEvent(18)),
                            )),
                          ],
                        );
                      case ConnectionState.active:
                        return Column(
                          children: <Widget>[
                            Expanded(
                                child: Center(
                              child: Text("50%...",
                                  style: prefix0.Style.titreEvent(18)),
                            )),
                          ],
                        );
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Column(
                            children: <Widget>[
                              Expanded(
                                  child: Center(
                                child: Text("Echec de connexion",
                                    style: prefix0.Style.titreEvent(18)),
                              )),
                            ],
                          );
                        }
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: double.infinity,
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        );
                    }
                  }),
        ));
  }
}

/*
final event = await new ConsumeAPI().buyEvent(appState.getidEvent, appState.getPriceTicketTotal, appState.getNumberTicket);
                  if (event['etat'] == 'found') {
                    User user = event['user'];
                    await DBProvider.db.delClient();
                    await DBProvider.db.delAllHobies();
                    await DBProvider.db.newClient(user);
                    await _askedToLead(
                      (int.parse(appState.getNumberTicket) > 1 ) ? "Vos tickets ont bien été acheté, voici votre code." : "Votre ticket a bien été acheté, voici votre code.",
                      true, event['result']['nameImage']);
                  }
                  else {
                    await _askedToLead(event['error'], false, '');
                  }




                  Future<Null> _askedToLead(String message, bool success, String imgUrl) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: success ?
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("${ConsumeAPI.AssetBuyEventServer}${appState.getidEvent}/${imgUrl}"),
              fit: BoxFit.contain,
              ))
        )
        : Icon(MyFlutterAppSecond.cancel, size: 120, color: prefix0.colorError),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children : [
                Text(message, textAlign: TextAlign.center, style: prefix0.Style.sousTitre(13)),
                RaisedButton(
                  child: Text('Ok'),
                  color: success ? prefix0.colorText: prefix0.colorError,
                  onPressed: (){
                    Navigator.pop(context);
                }),
              ]
            ),)
        ],
      );
    }
  );
}

 */
