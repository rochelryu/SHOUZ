import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/CircularClipper.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/VerifyUser.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Pages/add_decodeur.dart';
import 'package:shouz/Pages/choice_method_payement.dart';
import 'package:shouz/Pages/result_buy_event.dart';
import 'package:shouz/Pages/stats_event.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:shouz/Constant/widget_common.dart';

import '../Constant/helper.dart';
import '../Models/User.dart';
import 'Login.dart';

class EventDetails extends StatefulWidget {
  var imageUrl;
  var prixTicket = [];
  var placeTicket = [];
  var allTicket = [];
  var numberFavorite;
  var id;
  var positionRecently;
  var numberTicket;
  var eventDate;
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
  int comeBack;
  EventDetails(
      this.comeBack,
      this.imageUrl,
      this.index,
      prixTicket,
      this.numberFavorite,
      this.authorName,
      this.describe,
      this.id,
      this.numberTicket,
      this.position,
      this.eventDate,
      this.title,
      this.positionRecently,
      this.videoPub,
      this.allTicket,
      this.authorId,
      this.cumulGain,
      this.isMeAuthor,
      this.stateEvent,
      this.favorite) {
    this.prixTicket = prixTicket
        .map((value) => value['price'].toString().trim() == "GRATUIT"
            ? {"price": "GRATUIT", "choice": 0}
            : {"price": int.parse(value['price']), "choice": 0})
        .toList();
    this.placeTicket =
        prixTicket.map((value) => value['numberPlace'].toString()).toList();
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
  bool favorite = false;
  bool gratuitPass = false;
  bool loadForRecupGain = false;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  late User user = new User('null', 'null', 'ident');
  late DateTime eventDate;
  late SharedPreferences prefs;
  ScrollController _scrollController = ScrollController();

  late int placeTotal;
  int eventDateAlreadySkiped = -1;

  Future getInfo() async {
    final User me = await DBProvider.db.getClient();
    prefs = await SharedPreferences.getInstance();
    if (me.numero != 'null') {
      setState(() {
        user = me;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInfo();
    checkPros = widget.prixTicket;
    checkPlacePros = widget.placeTicket;
    favorite = widget.favorite;
    state = widget.stateEvent;
    placeTotal = widget.numberTicket;
    eventDate = DateTime.parse(widget.eventDate);
    final newDate = eventDate.difference(DateTime.now());
    print("Tolerence time is $MAX_SECONDS_TOLERANCE_TO_SHARE_TICKET and Time Actual is ${newDate.inSeconds}");
    setState(() {
      eventDateAlreadySkiped = newDate.inSeconds;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: ListView(
        controller: _scrollController,
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
                      child: CachedNetworkImage(
                        imageUrl:
                            "${ConsumeAPI.AssetEventServer}${widget.imageUrl}",
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress)),
                        errorWidget: (context, url, error) => notSignal(),
                        fit: BoxFit.cover,
                        height: 400,
                        width: double.infinity,
                      )),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: LinearGradient(
                          colors: [Color(0x00000000), tint],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white, size: 22.0),
                      onPressed: () {
                        if (widget.comeBack == 0) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushNamed(context, MenuDrawler.rootName);
                        }
                      },
                    ),
                  ),
                  if (!widget.isMeAuthor)
                    Container(
                      margin: EdgeInsets.only(right: 10.0),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: LinearGradient(
                            colors: [Color(0x00000000), tint],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.favorite,
                            color: favorite ? Colors.redAccent : Colors.grey,
                            size: 22.0),
                        onPressed: () async {
                          if (user.numero != 'null') {
                            setState(() {
                              favorite = !favorite;
                            });
                            await consumeAPI.addOrRemoveItemInFavorite(
                                widget.id, 2);
                            openAppReview(context);
                          } else {
                            await modalForExplain(
                                "${ConsumeAPI.AssetPublicServer}ready_station.svg",
                                "Pour avoir accès à ce service il est impératif que vous créez un compte ou que vous vous connectiez",
                                context,
                                true);
                            Navigator.pushNamed(context, Login.rootName);
                          }
                        },
                      ),
                    ),
                ],
              ),
              if (widget.videoPub != 'null')
                Positioned.fill(
                  bottom: 20,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: RawMaterialButton(
                      padding: EdgeInsets.all(10.0),
                      elevation: 12.0,
                      onPressed: () {
                        Navigator.of(context)
                            .push((MaterialPageRoute(builder: (context) {
                          return ViewerEvent(videoUrl: widget.videoPub);
                        })));
                      },
                      shape: CircleBorder(),
                      fillColor: Colors.white,
                      child: Icon(
                        Icons.play_arrow,
                        color: backgroundColorSec,
                        size: 40.0,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0.0,
                right: 10.0,
                child: IconButton(
                  onPressed: () {
                    Share.share(
                        "Ticket de ${widget.title} disponible dans Shouz.\n 🙂 Shouz Avantage:\n   - 🤩 Achète des semaines en avance.\n   - 🤩 Paye par mobile money ou demande à quelqu'un de payer un ticket pour toi.\n   - 🤩 Tes tickets sont des originaux.\n   - 🤩 Et si finalement tu ne peux plus y aller à cause d'un imprévu ! Shouz te rembourse tout ton argent.\n Clique ici pour voir l'évènement que je te partage ${ConsumeAPI.EventLink}${widget.title.toString().replaceAll(' ', '-').replaceAll('/', '_')}/${widget.id}");
                  },
                  icon: Icon(Icons.share, color: Colors.white),
                  iconSize: 30.0,
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              children: <Widget>[
                Container(
                    child: Text(widget.title.toUpperCase(),
                        style: Style.titre(17.0), textAlign: TextAlign.center)),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(MyFlutterAppSecond.pin,
                          color: Colors.white, size: 18.0),
                      Flexible(
                          child: Text(
                        widget.position,
                        maxLines: 2,
                        style: Style.sousTitre(12.0),
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
                        Text('Date', style: Style.sousTitre(15)),
                        Text(
                            DateTime.parse(widget.eventDate).day.toString() +
                                '/' +
                                DateTime.parse(widget.eventDate)
                                    .month
                                    .toString() +
                                '/' +
                                DateTime.parse(widget.eventDate)
                                    .year
                                    .toString(),
                            style: Style.titre(18))
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text('Heure', style: Style.sousTitre(15)),
                        Text(
                            DateTime.parse(widget.eventDate).hour.toString() +
                                ':' +
                                DateTime.parse(widget.eventDate)
                                    .minute
                                    .toString(),
                            style: Style.titre(20))
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text('Lieu', style: Style.sousTitre(15)),
                        GestureDetector(
                            onTap: () async {
                              await launchUrl(
                                  Uri.parse(
                                      "https://www.google.com/search?q=${widget.position}"),
                                  mode: LaunchMode.externalApplication);
                            },
                            child: Text("Map",
                                style: Style.titreBlue(19),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis))
                        /*Text(
                            (widget.positionRecently['longitude'] == 0)
                                ? 'N/A'
                                : '2.2 Km',
                            style: Style.titre(20))*/
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Container(
                  child: SingleChildScrollView(
                    child: Text(
                      widget.describe,
                      style: Style.sousTitre(12),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.allTicket.length > 0 && user.numero != 'null')
            componentForDisplayTicketByEvent(
                widget.allTicket, widget.title, user),
          Row(
            children: <Widget>[
              SizedBox(
                width: 16,
              ),
              Text("👇🏽 Séléctionne ton type de ticket 👇🏽",
                  style: Style.sousTitreEvent(15.0))
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
                return InkWell(
                  onTap: () {
                    var newTable = [];
                    if (int.parse(checkPlacePros[i]) >= place &&
                        int.parse(checkPlacePros[i]) > 0) {
                      widget.prixTicket.forEach((value) {
                        newTable.add({"choice": 0, "price": value["price"]});
                      });
                      newTable[i]["choice"] = 1;
                      setState(() {
                        checkPros = newTable;
                        choice = newTable[i]["price"].toString();
                        priceItem = (choice == "GRATUIT")
                            ? priceItem
                            : newTable[i]["price"] * place;
                      });
                      Timer(Duration(milliseconds: 500), () {
                        _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeInOut);
                      });
                    } else {
                      displaySnackBar(context,
                          "Pas assez de tickets disponible pour cette categorie");
                    }
                  },
                  child: Card(
                    elevation: 14.0,
                    color: (checkPros[i]['choice'] == 0)
                        ? backgroundColor
                        : Colors.white,
                    child: Container(
                      width: _width / 3.4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              '${checkPros[i]['price'].toString() == 'GRATUIT' ? checkPros[i]['price'].toString() : reformatNumberForDisplayOnPrice(checkPros[i]['price']) + ' ' + (user.numero != "null" ? user.currencies : "XOF")}',
                              style: TextStyle(
                                  color: (checkPros[i]['choice'] == 0)
                                      ? Colors.white
                                      : backgroundColor,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Montserrat")),
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('Ticket(s): ',
                                    style: TextStyle(
                                        color: (checkPros[i]['choice'] == 0)
                                            ? Colors.white
                                            : backgroundColor,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Montserrat")),
                                Text(checkPlacePros[i],
                                    style: TextStyle(
                                        color: (checkPros[i]['choice'] == 0)
                                            ? Colors.white
                                            : backgroundColor,
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
          if (choice != "")
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 16),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      if (widget.isMeAuthor)
                        Text(
                          "Places restantes: ",
                          style: Style.sousTitre(15),
                        ),
                      if (widget.isMeAuthor)
                        Text(
                          placeTotal.toString(),
                          style: Style.sousTitre(15),
                        ),
                      if (!widget.isMeAuthor)
                        Text(
                          "Nombre de places: ",
                          style: Style.sousTitre(15),
                        ),
                    ],
                  ),
                ),
                if (!widget.isMeAuthor)
                  Container(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.do_not_disturb_on, color: colorText),
                          onPressed: () {
                            var normal = (place > 0) ? place - 1 : 0;

                            if (choice.length > 1) {
                              setState(() {
                                placeTotal =
                                    (place != 0) ? placeTotal + 1 : placeTotal;
                                place = normal;
                                priceItem = (choice == "GRATUIT")
                                    ? 0
                                    : normal * int.parse(choice);
                              });
                            } else {
                              displaySnackBar(context,
                                  'Choisissez d\'abord le type de ticket avant de choisir le nombre de place');
                            }
                          },
                        ),
                        Text(place.toString(), style: Style.titre(29)),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: colorText),
                          onPressed: () {
                            var normal = 0;

                            var totalTicket = 0;
                            for (var ticket in widget.allTicket) {
                              totalTicket += ticket['placeTotal'] as int;
                            }
                            if (placeTotal > place) {
                              normal =
                                  (placeTotal > place) ? place + 1 : placeTotal;
                            } else {
                              if (placeTotal > 0) {
                                normal = place + 1;
                              } else {
                                normal = place;
                              }
                            }
                            if (totalTicket + normal <= 5 &&
                                choice.length > 1) {
                              setState(() {
                                place = normal;
                                placeTotal = (placeTotal > 0)
                                    ? placeTotal - 1
                                    : placeTotal;
                                priceItem = (choice == "GRATUIT")
                                    ? 0
                                    : normal * int.parse(choice);
                              });
                            } else if (choice.length <= 1 &&
                                totalTicket + normal <= 5) {
                              displaySnackBar(context,
                                  'Choisissez d\'abord le type de ticket avant de choisir le nombre de place');
                            } else {
                              displaySnackBar(context,
                                  'Le nombre de place maximum pour une personne est 5');
                            }
                          },
                        )
                      ],
                    ),
                  ),
                SizedBox(height: 20),
              ],
            ),
          if (widget.isMeAuthor)
            Container(
                padding: EdgeInsets.only(left: 5),
                margin: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cumul Gain: ${reformatNumberForDisplayOnPrice(widget.cumulGain)} ${user.currencies}",
                      style: Style.sousTitre(17),
                    ),
                  ],
                )),
          if (choice != "" || widget.isMeAuthor)
            Container(
              margin: EdgeInsets.all(10),
              height: 60,
              width: double.infinity,
              padding: EdgeInsets.only(
                  left: 20.0, top: 10.0, right: 10.0, bottom: 10.0),
              decoration: BoxDecoration(
                  color: backgroundColorSec,
                  borderRadius: BorderRadius.circular(30)),
              child: widget.isMeAuthor
                  ? reformatStateAuthor(state)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          priceItem.toString(),
                          style: Style.titre(28),
                        ),
                        if (state < 3 &&
                            state > 0 &&
                            widget.numberTicket > 0 &&
                            eventDateAlreadySkiped > - MAX_SECONDS_TOLERANCE_TO_SHARE_TICKET)
                          ElevatedButton(
                            style: raisedButtonStyle,
                            child: Text("Acheter maintenant", style: Style.titre(14)),
                            onPressed: () async {
                              if ((priceItem != 0 || choice == "GRATUIT") &&
                                  user.numero != "null" && user.numero.isNotEmpty &&
                                  priceItem <= user.wallet) {
                                appState.setIdEvent(widget.id);
                                appState.setNumberTicket(place);
                                appState
                                    .setPriceTicketTotal(priceItem.toString());
                                appState.setPriceUnityTicket(choice);

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (builder) => VerifyUser(
                                          redirect: ResultBuyEvent.rootName,
                                          key: UniqueKey(),
                                        )));
                              } else if (user.numero != "null" &&
                                  priceItem > user.wallet && user.numero.isNotEmpty) {
                                await prefs.setDouble('amountRecharge',
                                    priceItem - user.wallet);
                                displaySnackBar(context,
                                    'Votre solde est insuffisant, vous n\'avez que ${double.parse(user.wallet.toString()).floor().toString()}');
                                Timer(Duration(seconds: 3), () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (builder) =>
                                          ChoiceMethodPayement(
                                            key: UniqueKey(),
                                            isRetrait: false,
                                          )));
                                });
                              } else if (
                                  user.numero == "null" || user.numero.isEmpty) {
                                await modalForExplain(
                                    "${ConsumeAPI.AssetPublicServer}ready_station.svg",
                                    "Pour avoir accès à ce service il est impératif que vous créez un compte ou que vous vous connectiez",
                                    context,
                                    true);
                                Navigator.pushNamed(context, Login.rootName);
                              } else {
                                displaySnackBar(
                                  context,
                                  'Pour acheter des tickets il vous faut imperativement sélectionner un prix et un nombre de place',
                                );
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
    if (state == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push((MaterialPageRoute(builder: (context) {
                return AddDecodeur(key: UniqueKey(), eventId: widget.id);
              })));
            },
            style: raisedButtonStyle,
            child: Text('Attribuer décodeur'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push((MaterialPageRoute(builder: (context) {
                return StatsEvent(
                    key: UniqueKey(),
                    imageUrl: widget.imageUrl,
                    title: widget.title,
                    eventId: widget.id);
              })));
            },
            style: raisedButtonStyle,
            child: Text('Statistiques'),
          ),
        ],
      );
    } else if (state == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            style: raisedButtonStyleSuccess,
            child: loadForRecupGain
                ? CircularProgressIndicator(
                    color: colorPrimary,
                  )
                : Text("Recuperer Gain"),
            onPressed: () async {
              if (!loadForRecupGain) {
                setState(() {
                  loadForRecupGain = true;
                });
                final data = await consumeAPI.recupCumul(widget.id);
                setState(() {
                  loadForRecupGain = false;
                });
                if (data['etat'] == 'found') {
                  setState(() {
                    this.state = 3;
                  });
                  displaySnackBar(context, "🥳 Gain récupéré avec succès");
                } else {
                  displaySnackBar(context, data['error']);
                }
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push((MaterialPageRoute(builder: (context) {
                return StatsEvent(
                    key: UniqueKey(),
                    imageUrl: widget.imageUrl,
                    title: widget.title,
                    eventId: widget.id);
              })));
            },
            style: raisedButtonStyle,
            child: Text('Statistiques'),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Gain déjà rétiré',
            style: Style.titleDealsProduct(),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push((MaterialPageRoute(builder: (context) {
                return StatsEvent(
                    key: UniqueKey(),
                    imageUrl: widget.imageUrl,
                    title: widget.title,
                    eventId: widget.id);
              })));
            },
            style: raisedButtonStyle,
            child: Text('Statistiques'),
          ),
        ],
      );
    }
  }
}

class ViewerEvent extends StatefulWidget {
  var videoUrl;
  ViewerEvent({this.videoUrl});
  @override
  _ViewerEventState createState() => _ViewerEventState();
}

class _ViewerEventState extends State<ViewerEvent> {
  late VideoPlayerController _controller;
  late Future<void> _initialiseVideoFlutter;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse("${ConsumeAPI.AssetEventServer}${widget.videoUrl}"));

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
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: Style.white,)
          ),
        ),
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
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
          child: FutureBuilder(
              future: _initialiseVideoFlutter,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Column(
                      children: <Widget>[
                        Expanded(
                            child: Center(
                          child: Text("Echec de connexion",
                              style: Style.titreEvent(18)),
                        )),
                      ],
                    );
                  case ConnectionState.waiting:
                    return Column(
                      children: <Widget>[
                        Expanded(
                            child: Center(
                          child: Text("Chargement en cours...",
                              style: Style.titreEvent(18)),
                        )),
                      ],
                    );
                  case ConnectionState.active:
                    return Column(
                      children: <Widget>[
                        Expanded(
                            child: Center(
                          child: Text("50%...", style: Style.titreEvent(18)),
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
                                style: Style.titreEvent(18)),
                          )),
                        ],
                      );
                    }
                    return Container(
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
        : Icon(MyFlutterAppSecond.cancel, size: 120, color: colorError),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children : [
                Text(message, textAlign: TextAlign.center, style: Style.sousTitre(13)),
                RaisedButton(
                  child: Text('Ok'),
                  color: success ? colorText: colorError,
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
