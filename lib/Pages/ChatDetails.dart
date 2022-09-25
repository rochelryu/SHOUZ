import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/helper.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:record/record.dart';
import 'package:shouz/Constant/widget_common.dart';

import 'choice_method_payement.dart';

class ChatDetails extends StatefulWidget {
  var name;
  var onLine;
  var authorId;
  var productId;
  var profil;
  var room;
  int comeBack;
  User newClient;
  @override
  ChatDetails({this.name, this.onLine, this.profil, this.authorId, this.productId, this.room, required this.comeBack, required this.newClient});
  _ChatDetailsState createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> with SingleTickerProviderStateMixin {
  TextEditingController eCtrl = TextEditingController();
  ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  File? _image;
  final picker = ImagePicker();
  ConsumeAPI consumeAPI = ConsumeAPI();
  Map<dynamic, dynamic>? productDetails;

  String price = "";
  TextEditingController priceCtrl = TextEditingController();
  String quantity = "";
  TextEditingController quantityCtrl = TextEditingController();
  String displayTime = '00:00';

  Timer? _timer;
  Timer? _ampTimer;
  final _audioRecorder = Record();
  //String pathRecordAudio = '';

  double opacity = 0.0;



  bool isListeen = false;

  Future getImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  var message = "";
  String room = '';

  late AppState appState;
  var onLine = false;

  @override
  void initState() {
    super.initState();
    isListeen = false;
    _tabController = TabController(length: 2, vsync: this);
    appState = Provider.of<AppState>(context, listen: false);
    loadProfil();
  }

  @override
  dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  getMessage() {}

  loadProfil() async {
    setState(() {
      onLine = widget.onLine;
    });

    final room = widget.room == '' ? "${widget.authorId}_${widget.newClient.ident}_${widget.productId}": widget.room;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final converse = prefs.getString(room);

    if(converse != null) {
      final conversation = jsonDecode(converse);
      appState.setConversation(conversation);
      appState.setIdOldConversation(conversation['_id']);
    }
    try {
      appState.getConversation(room);
      final productInfo = await consumeAPI.getDetailsDeals(room.toString().split('_')[2]);
      final arrayOfId = room.toString().split('_');
      final infoOnLine = await consumeAPI.verifyClientIsOnLine(arrayOfId[0] == widget.newClient.ident ? arrayOfId[1] : arrayOfId[0]);
      setState(() {
        this.room = room.toString();
        productDetails = productInfo;
        onLine = infoOnLine;
      });
    } catch (e) {
      _showSnackBar("Aucune connexion internet");

    }

  }

  inWrite(bool etat, String id, String identUser) async {
    appState.setTyping(etat, id, identUser);
  }

  List<Widget> reformateView(conversation) {
    bool again = false;
    bool againToday = false;
    List<Widget> tabs = [];
    if (conversation['content'] != null) {
      conversation['content'].map((value) {
        final date = DateTime.now()
            .difference(DateTime(
                int.parse(value['date'].substring(0, 4)),
                int.parse(value['date'].substring(5, 7)),
                int.parse(value['date'].substring(8, 10))))
            .inDays;
        bool isMe = (widget.newClient.ident == value['ident']) ? true : false;
        if (date == 1) {
          if (!again) {
            tabs.add(Text("Hier",
                style: Style.sousTitre(10),
                textAlign: TextAlign.center));
            again = true;
          }
          tabs.add(Bubble(
              isMe: isMe,
              message: value['content'],
              registerDate: value['date'].substring(11, 16).toString(),
              idDocument: conversation['_id'],
              isReadByOtherUser: value['isReadByOtherUser'],
              image: value['image']));
        } else if (date < 1) {
          if (!againToday) {
            tabs.add(Text("Aujourd'hui",
                style: Style.sousTitre(10),
                textAlign: TextAlign.center));
            againToday = true;
          }
          tabs.add(Bubble(
              isMe: isMe,
              message: value['content'],
              registerDate: value['date'].substring(11, 16).toString(),
              idDocument: conversation['_id'],
              isReadByOtherUser: value['isReadByOtherUser'],
              image: value['image']));
        } else {
          tabs.add(Bubble(
              isMe: isMe,
              message: value['content'],
              isReadByOtherUser: value['isReadByOtherUser'],
              registerDate: value['date']
                  .substring(0, 16)
                  .toString()
                  .replaceAll(RegExp('T'), ' à '),
              idDocument: conversation['_id'],
              image: value['image']));
        }
      }).toList();
    }
    if(conversation['etatCommunication'] != null && conversation['etatCommunication'] == 'Seller and Buyer validate price final' && conversation['levelDelivery'] <= 3) {
      tabs.add(
        Container(
          height: 120,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TimelineTile(
                axis: TimelineAxis.horizontal,
                alignment: TimelineAlign.manual,
                isFirst: true,
                lineXY: 0.8,
                afterLineStyle: LineStyle(
                    color: conversation['levelDelivery'] > 0 ? colorSuccess : colorSecondary,
                ),
                indicatorStyle: IndicatorStyle(
                  color: colorSuccess,
                ),
                startChild: livraisonWidget('images/chez_client.png', 'Niveau Vendeur'),
              ),
              TimelineTile(
                axis: TimelineAxis.horizontal,
                alignment: TimelineAlign.manual,
                lineXY: 0.8,
                beforeLineStyle: LineStyle(
                  color: conversation['levelDelivery'] >= 2 ? colorSuccess:  colorSecondary,
                ),
                afterLineStyle: LineStyle(
                    color: conversation['levelDelivery'] >= 3 ? colorSuccess:  colorSecondary,
                ),
                indicatorStyle: IndicatorStyle(
                  color: conversation['levelDelivery'] >= 2 ? colorSuccess:  colorSecondary,
                ),
                startChild: livraisonWidget(conversation['levelDelivery'] >= 2 ? 'images/reception_shouz.png': 'images/reception_shouz_off.png', 'Niveau Shouz'),
              ),
              TimelineTile(
                axis: TimelineAxis.horizontal,
                alignment: TimelineAlign.manual,
                lineXY: 0.8,
                isLast: true,
                beforeLineStyle: LineStyle(
                  color: conversation['levelDelivery'] >= 3 ? colorSuccess:  colorSecondary,
                ),

                indicatorStyle: IndicatorStyle(
                  color: conversation['levelDelivery'] >= 3 ? colorSuccess:  colorSecondary,
                ),
                startChild: livraisonWidget(conversation['levelDelivery'] >= 3 ? 'images/client_a_colis.png': 'images/client_a_colis_off.png', 'Niveau Client'),
              ),
            ],
          )
        ),
      );
    }
    if(conversation['levelDelivery'] == 3  && room != '' && room.split('_')[1] == widget.newClient.ident) {
      tabs.add(
        Container(
          height: 120,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(" 💁🏽‍♂ ️Le produit vous convient il ?", style: Style.chatIsMe(15),),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final info = await consumeAPI.responseProductForLastStep(room, 0);
                      if(info['etat'] == 'found') {
                        await askedToLead(
                            "Nous sommes heureux de savoir que le produit vous a convenu. Au plaisir de vous revoir !!!",
                            true, context);
                        Navigator.pushNamed(context, MenuDrawler.rootName);
                      } else {
                        await askedToLead(
                            "Un problème est survenue veuillez attendre quelque instant avant de relancer ou contacter le support technique", false, context);
                      }
                    },
                    child: Text(
                      "Oui",
                      style: Style.sousTitreEvent(15),
                    ),
                    style: raisedButtonStyle,

                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final info = await consumeAPI.responseProductForLastStep(room, 1);
                      if(info['etat'] == 'found') {
                        await askedToLead(
                            "Nous somme désolé que vous n'ayez pas apprecié le produit votre argent vous sera restitué une fois que notre livreur viendra chercher le produit",
                            true, context);
                        Navigator.pushNamed(context, MenuDrawler.rootName);
                      } else {
                        await askedToLead("Un problème est survenue veuillez attendre quelque instant avant de relancer ou contacter le support technique", false, context);
                      }
                    },
                    child: Text(
                      "Non, je veux mon argent",
                      style: Style.sousTitreEvent(15),
                    ),
                    style: raisedButtonStyleError,
                  )
                ],
              )
            ],
          ),
        )
      );
    }
    if(productDetails != null && productDetails!['result']['quantity']>0 && conversation['etatCommunication'] != null && conversation['etatCommunication'] == 'Seller and Buyer validate price final' && conversation['levelDelivery'] >= 5 && conversation['levelDelivery'] < 7 && room != '' && room.split('_')[1] == widget.newClient.ident) {
      tabs.add(
          Container(
            height: 140,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Il y'a encore ce produit en stock, voulez vous relancer un nouveau Deal ?", style: Style.titleNews(), textAlign: TextAlign.center,),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () async {
                    appState.relanceDeals(
                        destinate: room,
                        content: "Encore moi 👋🏽",
                        id: appState.getIdOldConversation
                        );
                  },
                  child: Text(
                    "Oui, je suis intéressé.",
                    style: Style.sousTitreEvent(15),
                  ),
                  style: raisedButtonStyle,

                ),
              ],
            ),
          )
      );
    }

    if(productDetails != null && conversation['etatCommunication'] != null && conversation['etatCommunication'] == 'Seller and Buyer validate price final' &&  conversation['levelDelivery'] == 7) {
      tabs.add(
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Le produit ne se trouvait pas avec le vendeur", style: Style.titleNews(), textAlign: TextAlign.center,),

              ],
            ),
          )
      );
    }
    return tabs;
  }
  Widget propositionAuteur(String? etatCommunication, bool iAmAuteur, int? priceFinal, int? qte) {
    if(etatCommunication == 'Conversation between users'){
      if(iAmAuteur) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prix Total Proposé', style: Style.chatIsMe(13)),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 60,
                          width: double.infinity,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Card(
                                  color: Colors.transparent,
                                  elevation: 2.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0)),
                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width * 0.25,
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: backgroundColorSec,
                                        border: Border.all(
                                            width: 1.0,
                                            color: colorText),
                                        borderRadius: BorderRadius.circular(50.0)),
                                    child: TextField(
                                      controller: priceCtrl,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300),
                                      cursorColor: colorText,
                                      onChanged: (text) {
                                        setState(() {

                                          price = text.toString();
                                        });
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Prix vente",
                                          hintStyle: TextStyle(
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                ),
                              ]),
                        )),
                  ],
                ),
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Qte Proposée', style: Style.chatIsMe(13)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Card(
                              color: Colors.transparent,
                              elevation: 2.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0)),
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * 0.25,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    color: backgroundColorSec,
                                    border: Border.all(
                                        width: 1.0,
                                        color: colorText),
                                    borderRadius: BorderRadius.circular(50.0)),
                                child: TextField(
                                  controller: quantityCtrl,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300),
                                  cursorColor: colorText,
                                  onChanged: (text) {
                                    setState(() {
                                      quantity = text.toString();
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Quantité",
                                      hintStyle: TextStyle(
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                            ),
                          ],
                        )
                      ),
                    ),
                  ],
                )
            )
          ],
        );
      } else {
        return Center(
          child: Text('Pas encore de proposition faites pour le vendeur', style: Style.chatIsMe(15)),
        );
      }
    } else if (etatCommunication == 'Seller Purpose price final at buyer') {
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Prix Proposé', style: Style.chatIsMe(15)),
                Text(priceFinal!.toString(), style: Style.titleNews()),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Qte Proposé', style: Style.chatIsMe(15)),
                Text(qte!.toString(), style: Style.titleNews()),
              ],
            ),
          ),
        ],
      );
    } else if (etatCommunication ==  'Seller and Buyer validate price final') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Prix Total Proposé', style: Style.chatIsMe(13)),
                        Text(priceFinal!.toString(), style: Style.titleNews()),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 53,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Qte Proposé', style: Style.chatIsMe(13)),
                        Text(qte!.toString(), style: Style.titleNews()),
                      ],
                    ),
                  ),
                  Text('Vendeur et Acheteur se sont entendus sur cette proposition 🤝', textAlign: TextAlign.center, style: Style.titleNews(16.0),)
                ],
              )
          ),
        ],
      );
    } else {
      return SizedBox(width: 20);
    }
  }



  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    final conversation = appState.getConversationGetter;
    if (_scrollController.hasClients) Timer(
        Duration(seconds: 1),
            () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent));

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          appState.setConversation({});
          appState.setIdOldConversation('');
          if(widget.comeBack == 0) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamed(context, MenuDrawler.rootName);
          }
        }, icon: Icon(Icons.arrow_back)),
        actions: [
          IconButton(
            icon: Icon(Icons.book_outlined),
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
        backgroundColor: backgroundColor,
        title: Row(
          children: <Widget>[
            Container(
              height: 40,
              width: 40,
              margin: EdgeInsets.fromLTRB(0, 5, 10, 0),
              decoration: BoxDecoration(
                border: Border.all(
                    width: 2.0,
                    color: onLine ? Colors.green[300]! : Colors.yellow[300]!),
                borderRadius: BorderRadius.circular(50.0),
                image: DecorationImage(
                    image: NetworkImage(
                        "${ConsumeAPI.AssetProfilServer}${widget.profil}"),
                    fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.name.toString().split('_')[0],
                    maxLines: 1, style: Style.titleInSegment(12.0), overflow: TextOverflow.ellipsis),
                  Text(onLine ? "En ligne" : "",
                      style: Style.sousTitre(10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(width: 3),
                      appState.getTyping
                          ? Container(
                        height: 6,
                        width: 25,
                        padding: EdgeInsets.only(top: 2),
                        child: LoadingIndicator(indicatorType: Indicator.ballPulse,colors: [colorSecondary], strokeWidth: 1),
                      )
                          : SizedBox(width: 8),

                    ],
                  )
                ],
              ),
            ),
            SizedBox(width: 10,),
          ],
        ),
        centerTitle: false,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/backgoundChat.png'),
                fit: BoxFit.cover
            )
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          controller: _scrollController,
                          shrinkWrap: true,
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: 5.0, left: 5.0, right: 5.0, bottom: conversation['etatCommunication'] != null && conversation['etatCommunication'] == 'Seller and Buyer validate price final' ? 10 :70.0),
                              child: Column(
                                children: reformateView(conversation),
                              ),
                            );
                          }),
                    )
                  ],
                ),
              ),
              if ((conversation['etatCommunication'] != null && conversation['etatCommunication'] != 'Seller and Buyer validate price final') || conversation['etatCommunication'] == null) Positioned(
                bottom: 0,
                left: 0,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    if (_image != null) Container(
                      height: 85,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            child: Container(
                              height: 85,
                              width: 85,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2.0,
                                      color: colorPrimary),
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(4),topLeft: Radius.circular(4)),
                                  image: DecorationImage(
                                      image: FileImage(_image!),
                                      fit: BoxFit.cover
                                  )
                              ),
                            ),
                            onTap: () {
                              setState(() { _image =null;});
                            },
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(_image != null ? 0:30),),
                        color: Colors.white
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(MyFlutterAppSecond.attach,
                                color: colorText),
                            onPressed: getImage,
                          ),
                          Expanded(
                            child: isListeen ? Container(
                              height: 50,
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  AnimatedOpacity(
                                      child: Container(
                                        height: 15,
                                        width: 15,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colorError,
                                        ),
                                      ),
                                      opacity: opacity,
                                      duration: const Duration(seconds: 1)),
                                  SizedBox(width: 10),
                                  Text(displayTime, style: Style.simpleTextBlack())
                                ],
                              ),
                            ) : TextFormField(
                              controller: eCtrl,
                              textCapitalization:
                              TextCapitalization.sentences,
                              style: Style.chatOutMe(14),
                              keyboardType: TextInputType.text,
                              maxLines: 1,
                              decoration: InputDecoration(
                                  hintText: "Entrer le message",
                                  border: InputBorder.none,
                                  hintStyle: Style.sousTitre(14)),
                              onChanged: (text) async {
                                setState(() {
                                  message = text;
                                  if (message.length == 1) {
                                    inWrite(true, room, widget.newClient.ident);
                                    // appState.setTyping(true, widget.authorId);
                                  } else if (message.length == 0) {
                                    inWrite(false, room, widget.newClient.ident);
                                    // appState.setTyping(false, widget.authorId);
                                  }
                                });
                              },
                            ),
                          ),
                          if(isListeen) IconButton(
                            icon: Icon(Icons.delete_sharp, color: backgroundColorSec),
                            onPressed: () {
                              _removeRecord();
                            },
                          ),
                          if (appState.getLoadingToSend) LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2)
                          else if ((!appState.getLoadingToSend && message.length > 0 && !isListeen) || _image != null) IconButton(
                            icon: Icon(MyFlutterAppSecond.email,
                                color: colorText),
                            onPressed: () {
                              if (_image == null && message == "") {
                                Fluttertoast.showToast(
                                    msg: 'Ecrivé au moins quelque chose avant d\'envoyer',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: colorError,
                                    textColor: Colors.black,
                                    fontSize: 16.0
                                );
                              } else {
                                appState.updateLoadingToSend(true);
                                setState(() {
                                  eCtrl.text = "";
                                  File? imm = _image;
                                  _image = null;
                                  if (appState.getConversationGetter['_id'] == null) {
                                    if (imm != null) {
                                      final base64Image =
                                      base64Encode(imm.readAsBytesSync());
                                      String imageCover =
                                          imm.path.split('/').last;
                                      appState.createChatMessage(
                                          destinate: "${widget.authorId}_${widget.newClient.ident}_${widget.productId}",
                                          base64: base64Image,
                                          imageName: imageCover,
                                          content: message);
                                      inWrite(false, room, widget.newClient.ident);
                                    } else {
                                      appState.createChatMessage(
                                          destinate: "${widget.authorId}_${widget.newClient.ident}_${widget.productId}",
                                          content: message);
                                      inWrite(false, room, widget.newClient.ident);
                                    }
                                    // tabs.add(Bubble(isMe: true,message: message, registerDate: (DateTime.now().hour).toString() +":"+(DateTime.now().minute).toString(), image: imm));
                                    Timer(
                                        Duration(milliseconds: 10),
                                            () => _scrollController.jumpTo(
                                            _scrollController
                                                .position.maxScrollExtent));
                                  } else {
                                    if (imm != null) {
                                      final base64Image =
                                      base64Encode(imm.readAsBytesSync());
                                      String imageCover =
                                          imm.path.split('/').last;
                                      appState.sendChatMessage(
                                          destinate: room,
                                          base64: base64Image,
                                          imageName: imageCover,
                                          content: message,
                                          id: appState.getIdOldConversation);
                                      inWrite(false, room, widget.newClient.ident);
                                    } else {
                                      appState.sendChatMessage(
                                          destinate: room,
                                          content: message,
                                          id: appState.getIdOldConversation);
                                      inWrite(false, room, widget.newClient.ident);
                                    }
                                    // tabs.add(Bubble(isMe: true,message: message, registerDate: (DateTime.now().hour).toString() +":"+(DateTime.now().minute).toString(), image: imm));
                                  }
                                  message = '';
                                });
                              }

                            },
                          )
                          else if (!appState.getLoadingToSend && message.length == 0 && _image == null) IconButton(
                              icon: Icon(isListeen ? MyFlutterAppSecond.email :Icons.mic_none_outlined, color: colorText,),
                              onPressed: () async {
                                if(!isListeen) {
                                  _start();
                                } else {
                                  appState.updateLoadingToSend(true);
                                  _stop();
                                }
                              },
                            ),

                        ],
                      ),
                    )
                  ],
                ))
            ],
          ),
        ),
      ),

      endDrawer: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
        child: Drawer(
          child: Container(
            color: backgroundColor,
            child: productDetails == null ? Center(
              child: LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2),
            ) : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 35.0),
                  child: Material(
                    elevation: 10,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage("${ConsumeAPI.AssetProductServer}${productDetails!['result']['images'][0]}"),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 30,
                  child: TabBar(
                    controller: _tabController,
                    unselectedLabelColor: Color(0xdd3c5b6d),
                    labelColor: colorText,
                    indicatorColor: colorText,
                    tabs: [
                      Tab(
                        text: (room.split('_')[0] == widget.newClient.ident) ? 'Moi ':'Vendeur',
                      ),
                      Tab(
                        //icon: const Icon(Icons.shopping_cart),
                        text: (room.split('_')[1] == widget.newClient.ident) ? 'Moi': 'Acheteur',
                      ),

                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Padding(
                            padding:EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Prix Initial', style: Style.chatIsMe(15)),
                                      Text(productDetails!['result']['price'].toString(), style: Style.titleNews()),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Qte Restante', style: Style.chatIsMe(15)),
                                      Text(productDetails!['result']['quantity'].toString(), style: Style.titleNews()),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Divider(height: 1, indent: 12, endIndent: 12, color: Colors.grey[200],),
                                SizedBox(height: 10),
                                Text('Proposition du vendeur', style: Style.titleNews()),
                                SizedBox(height: 10),
                                Divider(height: 1, indent: 12, endIndent: 12, color: Colors.grey[200],),
                                SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  height: 170,
                                  child: propositionAuteur(conversation['etatCommunication'], (room.split('_')[0] == widget.newClient.ident), conversation['priceFinal'], conversation['quantityProduct']),
                                ),
                                if (conversation['etatCommunication'] != null && conversation['etatCommunication'] == 'Conversation between users' && room.split('_')[0] == widget.newClient.ident) ElevatedButton(
                              onPressed: () {
                                if(int.parse(quantity) <= productDetails!['result']['quantity'] && double.parse(price) > 0 && double.parse(quantity) > 0) {
                                  appState.sendPropositionForDealsByAuteur(price : price, qte: quantity, room: room, id: appState.getIdOldConversation );
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                      msg: 'Proposition envoyée',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: colorText,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Erreur sur la quantité ou le prix",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );
                                }
                              },
                              child: Text(
                                "Envoyer la proposition",
                                style: Style.sousTitreEvent(15),
                              ),
                              style: raisedButtonStyle,
                            ),
                              ],
                            ),
                          ),
                        ),
                        if (conversation['etatCommunication'] != null && conversation['etatCommunication'] == 'Seller and Buyer validate price final') Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "images/deals_validate.svg",
                              semanticsLabel: 'deals_validate',
                              height:
                              MediaQuery.of(context).size.height *
                                  0.39,
                            ),
                            Text(
                                (room.split('_')[0] == widget.newClient.ident) ? "L'acheteur a accepté votre proposition 🤝" :"Vous vous êtes entendu avec le vendeur sur sa proposition 🤝",
                                textAlign: TextAlign.center,
                                style: Style.sousTitreEvent(15)),
                          ],
                        ) else Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: reformatText(conversation),
                        )

                      ]
                  ),
                ),

              ],
            ),
          ),
        ),
      )

    );
  }


  List<Widget> reformatText(conversation) {
    if(conversation['etatCommunication'] != null && conversation['etatCommunication'] == 'Conversation between users') {
      return [
        Text((room.split('_')[0] == widget.newClient.ident) ? "Vous n'avez pas encore fait de proposition" : "Le vendeur n'a pas encore fait de proposition concernant votre deals",
            textAlign: TextAlign.center,
            style: Style.sousTitreEvent(15))
      ];
    } else if(conversation['etatCommunication'] != null && conversation['etatCommunication'] == 'Seller Purpose price final at buyer') {
      if(room.split('_')[0] == widget.newClient.ident) {
        return [Text("En attente de reponse de l'acheteur", textAlign: TextAlign.center,style: Style.sousTitreEvent(15))];
      } else {
        return [
          ElevatedButton(
            onPressed: () {
                final priceFinal = conversation['priceFinal'] != null ? conversation['priceFinal'] : 0;
                if(widget.newClient.wallet >= priceFinal) {
                  appState.agreeForPropositionForDeals(room: room, id: appState.getIdOldConversation);
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(
                      msg: 'Solde Insuffisant pensez à vous recharger',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: colorError,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );

                  Timer(const Duration(milliseconds: 2000), () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => ChoiceMethodPayement(key: UniqueKey(), isRetrait: false,)));
                  });
                }


            },
            child: Text(
              "Je suis d'accord",
              style: Style.sousTitreEvent(15),
            ),
            style: raisedButtonStyle,

          ),
          SizedBox(height: 35),
          ElevatedButton(
            onPressed: () {
                appState.notAgreeForPropositionForDeals(room: room, id: appState.getIdOldConversation);
                Navigator.pop(context);
                Fluttertoast.showToast(
                    msg: 'Reponse envoyée',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: colorText,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
            },
            child: Text(
              "Non, Je ne suis pas d'accord",
              style: Style.sousTitreEvent(15),
            ),
           style: raisedButtonStyleError,
          )];
      }

    }
    else {
      return [Text("Le vendeur n'a pas encore fait de proposition concernant votre deals",
          textAlign: TextAlign.center,
          style: Style.sousTitreEvent(15))];
    }
  }

  _pathRecord() async {
    try {

      if (await _audioRecorder.hasPermission()) {
        String customPath = '/chat_records_';
        Directory appDocDirectory;
        if (Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = (await getExternalStorageDirectory())!;
        }

        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString()+'.m4a';
        setState(() {
          //pathRecordAudio = customPath;
        });
        return customPath;

      } else {
        final statusPermissionMicro = await Permission.microphone.request();
        final statusPermissionStorage = await Permission.storage.request();
        final statusPermissionManageStorage = await Permission.manageExternalStorage.request();
        if(statusPermissionMicro != PermissionStatus.granted) {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Permission Microphone', "Il est impératif que vous nous donniez la permission de votre microphone", context),
              barrierDismissible: false);
          await Permission.microphone.request();
        }
        if(statusPermissionStorage != PermissionStatus.granted) {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Permission Stockage', "Il est impératif que vous nous donniez la permission de votre stockage fichiers", context),
              barrierDismissible: false);
          await Permission.storage.request();
        }
        if(statusPermissionManageStorage != PermissionStatus.granted) {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  dialogCustomError('Permission Enregistrement Stockage', "Il est impératif que vous nous donniez la permission de gestion stockage fichiers", context),
              barrierDismissible: false);
          await Permission.manageExternalStorage.request();
        }
        await _pathRecord();
      }
    } catch (e) {
      print(e);
    }
  }


  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          path: await _pathRecord(),
        );

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          displayTime = "00:00";
          isListeen = isRecording;
        });

        _startTimer();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    final path = await _audioRecorder.stop();


    setState(() {
      isListeen = false;
    });
    String audioName = path!.split('/').last;
    final base64Audio = base64Encode(File(path).readAsBytesSync());
    if(appState.getConversationGetter['_id'] == null) {
      appState.createChatMessage(
          destinate: "${widget.authorId}_${widget.newClient.ident}_${widget.productId}",
          base64: base64Audio,
          imageName: audioName,
          content: message);
    } else {
      appState.sendChatMessage(
          destinate: room,
          base64: base64Audio,
          imageName: audioName,
          content: message,
          id: appState.getIdOldConversation);
    }

  }

  Future<void> _removeRecord() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    await _audioRecorder.stop();
    setState(() {
      isListeen = false;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        displayTime = reformatTimerForDisplayOnChrono(t.tick);
        opacity = opacity == 0.0 ? 1.0: 0.0;
      });
    });
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: colorError,
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
      action: SnackBarAction(
          label: 'Ok',
          onPressed: () {

          }),
    ));
  }
}


class Bubble extends StatefulWidget {
  final bool isMe;
  final String message;
  final String registerDate;
  final String image;
  final String idDocument;
  final bool isReadByOtherUser;

  Bubble(
      {required this.message,
      required this.isMe,
      required this.registerDate,
      required this.image,
      required this.isReadByOtherUser,
      required this.idDocument});
  @override
  _BubbleState createState() => _BubbleState();
}

class _BubbleState extends State<Bubble> {

  @override
  void initState() {
    super.initState();
  }

  Widget sendEtat(etat, isMe) {
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



  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.all(10.0),
      padding:
          widget.isMe ? EdgeInsets.only(left: 40) : EdgeInsets.only(right: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment:
                widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    color: widget.isMe ? colorText : Colors.white,
                    borderRadius: widget.isMe
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (widget.image != '') ClipRRect(
                            borderRadius: widget.isMe
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
                      child: widget.image.indexOf('.m4a') == -1 ? CachedNetworkImage(
                        imageUrl: "${ConsumeAPI.AssetConversationServer}${widget.idDocument}/${widget.image}",
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            Center(
                                child: CircularProgressIndicator(value: downloadProgress.progress)),
                        errorWidget: (context, url, error) => notSignal(),
                      ): LoadAudioAsset(url: "${ConsumeAPI.AssetConversationServer}${widget.idDocument}/${widget.image}", isMe: widget.isMe, key: UniqueKey(),),
                    ),

                    if(widget.message != '') Container(
                      child: Text(
                        widget.message,
                        style: widget.isMe
                            ? Style.chatIsMe(15)
                            : Style.chatOutMe(15.0),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: widget.isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.registerDate,
                      style: Style.chatIsMe(12),
                    ),
                    SizedBox(width: 7),
                    sendEtat(widget.isReadByOtherUser, widget.isMe),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }



}


class LoadAudioAsset extends StatefulWidget {
  String url;
  bool isMe;
  LoadAudioAsset({required Key key, required this.url, required this.isMe}) : super(key: key);

  @override
  _LoadAudioAssetState createState() => _LoadAudioAssetState();
}

class _LoadAudioAssetState extends State<LoadAudioAsset> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool isListenSound = false, firstListeen = true;
  Duration _duration = Duration();
  Duration _position = Duration();
  AudioPlayer audioPlayer = AudioPlayer();

  Future play() async {

    await audioPlayer.play(UrlSource(widget.url));
    controller.forward();
    setState(() {
      firstListeen = false;
    });
  }
  Future pause() async {
    await audioPlayer.pause();
    controller.reverse();
  }

  Future resume() async {
    await audioPlayer.resume();
    controller.forward();
  }

  void changeToSecond(int millisecond) async {
    Duration duration = Duration(milliseconds: millisecond);
    await audioPlayer.seek(duration);
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300)
    );
    audioPlayer.setSourceUrl(widget.url);
    audioPlayer.stop();
    audioPlayer.onDurationChanged.listen((d) {
      if(mounted) {
        setState(() {
          _duration = d;
        });
      }
    });
    audioPlayer.onPositionChanged.listen((p) {
      if(mounted) {
        setState(() {
          _position = p;
        });
      }

    });

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isListenSound = false;
        firstListeen = true;
        _position = Duration(milliseconds: 0);
      });
      controller.reverse();
    });
  }


  @override
  void dispose() {
    audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          GestureDetector (
            onTap: () async {
              if(isListenSound && !firstListeen) {
                await pause();
              } else if(firstListeen && !isListenSound) {
                await play();
              } else {
                await resume();
              }
              setState(() {
                isListenSound = !isListenSound;
              });
            },
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: controller,
              color: widget.isMe ? Colors.white: colorText,
              size: 30,
            ),
          ),
          SizedBox(width: 2),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 45,
                  child: Text(_position.toString().substring(2).split('.')[0], style: widget.isMe
                      ? Style.chatIsMe(13.0)
                      : Style.chatOutMe(13.0)),
                ),
                Expanded(child: Slider(
                  inactiveColor: widget.isMe ? Colors.white.withOpacity(0.4) : colorText.withOpacity(0.4),
                  activeColor: widget.isMe ? Colors.white: colorText,
                  value: _position.inMilliseconds.toDouble(),
                  max: _duration.inMilliseconds.toDouble(),
                  min: 0.0,
                  onChanged: (value) {
                    setState(() {
                      changeToSecond(value.toInt());
                      value = value;
                    });
                  },
                )),

                SizedBox(
                  width: 50,
                  child: Text(_duration.toString().substring(2).split('.')[0], style: widget.isMe
                      ? Style.chatIsMe(13.0)
                      : Style.chatOutMe(13.0), textAlign: TextAlign.start),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}


