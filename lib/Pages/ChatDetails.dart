import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ChatDetails extends StatefulWidget {
  var name;
  var onLine;
  var authorId;
  var productId;
  var profil;
  var room;
  @override
  ChatDetails({this.name, this.onLine, this.profil, this.authorId, this.productId, this.room});
  _ChatDetailsState createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> with SingleTickerProviderStateMixin {
  User? newClient;
  TextEditingController eCtrl = TextEditingController();
  ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  File? _image;
  int decompte = 0;
  final picker = ImagePicker();
  ConsumeAPI consumeAPI = new ConsumeAPI();
  Map<dynamic, dynamic>? productDetails;

  String price = "";
  TextEditingController priceCtrl = TextEditingController();
  String quantity = "";
  TextEditingController quantityCtrl = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    appState = Provider.of<AppState>(context, listen: false);
    loadProfil();


    // reformateData(conversation);
    // getUser();
    // initializeSocket();
  }

//  @override
//  didChangeDependencies() {
//    if(decompte == 0) {
//      appState = Provider.of<AppState>(context);
//      appState.getConversation(widget.authorId);
//      decompte++;
//    }
//  }

  @override
  dispose() {

    /*appState.updateTyping(false);
    appState.setConversation({});
    appState = null;*/
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
    final client = await DBProvider.db.getClient();

    final room = widget.room == '' ? "${widget.authorId}_${client.ident}_${widget.productId}": widget.room;
    appState.getConversation(room);
    final productInfo = await consumeAPI.getDetailsDeals(room.toString().split('_')[2]);
    setState(() {
      this.room = room.toString();
      productDetails = productInfo;
      newClient = client;
    });
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
        bool isMe = (newClient!.ident == value['ident']) ? true : false;
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
              image: value['image']));
        } else {
          tabs.add(Bubble(
              isMe: isMe,
              message: value['content'],
              registerDate: value['date']
                  .substring(0, 16)
                  .toString()
                  .replaceAll(new RegExp('T'), ' à '),
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
    if(conversation['levelDelivery'] == 3 && newClient != null && room.split('_')[1] == newClient!.ident) {
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
                    child: new Text(
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
                    child: new Text(
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
                    new Padding(
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
                                    child: new TextField(
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
                    new Padding(
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
                                child: new TextField(
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
                Text(priceFinal!.toString() + ' Fcfa', style: Style.titleNews()),
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
                        Text('Prix Proposé', style: Style.chatIsMe(15)),
                        Text(priceFinal!.toString() + ' Fcfa', style: Style.titleNews()),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 53,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Qte Restante', style: Style.chatIsMe(15)),
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
    Timer(
        Duration(milliseconds: 500),
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent));

    return new Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(Icons.arrow_back)),
            Container(
              height: 40,
              width: 40,
              margin: EdgeInsets.fromLTRB(0, 5, 10, 0),
              decoration: BoxDecoration(
                border: Border.all(
                    width: 2.0,
                    color:
                        widget.onLine ? Colors.green[300]! : Colors.yellow[300]!),
                borderRadius: BorderRadius.circular(50.0),
                image: DecorationImage(
                    image: NetworkImage(
                        "${ConsumeAPI.AssetProfilServer}${widget.profil}"),
                    fit: BoxFit.cover),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.name.toString().split('_')[0],
                  maxLines: 2, style: Style.titleInSegment(12.0), overflow: TextOverflow.ellipsis),
                Text(widget.onLine ? "En ligne" : "Déconnecté",
                    style: Style.sousTitre(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 8),
                    appState.getTyping
                        ? LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2)
                        : SizedBox(width: 8),
                  ],
                )
              ],
            )
          ],
        ),
        centerTitle: false,
      ),
      body: newClient == null ? Center(
        child: LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2),
      ) : GestureDetector(
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
            conversation['etatCommunication'] != null && conversation['etatCommunication'] == 'Seller and Buyer validate price final' ? SizedBox(width: 10):Positioned(
              bottom: 0,
              left: 0,
              width: MediaQuery.of(context).size.width,
              child: Container(
                  padding: EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    color: Colors.white,
                    // boxShadow: [
                    //   BoxShadow(
                    //     offset: Offset(-2,0),
                    //     color: Colors.grey[200],
                    //     blurRadius: 2,
                    //   )
                    // ]
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: _image == null
                            ? SizedBox(width: 10)
                            : Container(
                                height:
                                    MediaQuery.of(context).size.height / 1.76,
                                width: double.infinity,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30.0)),
                                    child: Image.file(_image!)),
                              ),
                      ),
                      Container(
                        height: 50,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(MyFlutterAppSecond.attach,
                                  color: colorText),
                              onPressed: getImage,
                            ),
                            Expanded(
                              child: TextFormField(
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
                                      inWrite(true, room, newClient!.ident);
                                      // appState.setTyping(true, widget.authorId);
                                    } else if (message.length == 0) {
                                      inWrite(false, room, newClient!.ident);
                                      // appState.setTyping(false, widget.authorId);
                                    }
                                  });
                                },
                              ),
                            ),
                            appState.getLoadingToSend ?  LoadingIndicator(indicatorType: Indicator.ballClipRotateMultiple,colors: [colorText], strokeWidth: 2) : IconButton(
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
                                            destinate: "${widget.authorId}_${newClient!.ident}_${widget.productId}",
                                            base64: base64Image,
                                            imageName: imageCover,
                                            content: message);
                                        inWrite(false, room, newClient!.ident);
                                      } else {
                                        appState.createChatMessage(
                                            destinate: "${widget.authorId}_${newClient!.ident}_${widget.productId}",
                                            content: message);
                                        inWrite(false, room, newClient!.ident);
                                      }
                                      // tabs.add(Bubble(isMe: true,message: message, registerDate: (new DateTime.now().hour).toString() +":"+(new DateTime.now().minute).toString(), image: imm));
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
                                        inWrite(false, room, newClient!.ident);
                                      } else {
                                        appState.sendChatMessage(
                                            destinate: room,
                                            content: message,
                                            id: appState.getIdOldConversation);
                                        inWrite(false, room, newClient!.ident);
                                      }
                                      // tabs.add(Bubble(isMe: true,message: message, registerDate: (new DateTime.now().hour).toString() +":"+(new DateTime.now().minute).toString(), image: imm));
                                    }
                                    message = '';
                                  });
                                }

                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
            )
          ],
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
                Material(
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
                Container(
                  width: double.infinity,
                  height: 30,
                  child: new TabBar(
                    controller: _tabController,
                    unselectedLabelColor: Color(0xdd3c5b6d),
                    labelColor: colorText,
                    indicatorColor: colorText,
                    tabs: [
                      new Tab(
                        text: (newClient != null && room.split('_')[0] == newClient!.ident) ? 'Moi ':'Vendeur',
                      ),
                      new Tab(
                        //icon: const Icon(Icons.shopping_cart),
                        text: (newClient != null && room.split('_')[1] == newClient!.ident) ? 'Moi': 'Acheteur',
                      ),

                    ],
                  ),
                ),
                Expanded(
                  child: new TabBarView(
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
                                      Text(productDetails!['result']['price'].toString() + ' Fcfa', style: Style.titleNews()),
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
                                  child: propositionAuteur(conversation['etatCommunication'], (newClient != null && room.split('_')[0] == newClient!.ident), conversation['priceFinal'], conversation['quantityProduct']),
                                ),
                                (conversation['etatCommunication'] != null && conversation['etatCommunication'] == 'Conversation between users' && newClient != null && room.split('_')[0] == newClient!.ident) ? new RaisedButton(
                              onPressed: () {
;                                if(int.parse(quantity) <= productDetails!['result']['quantity'] && double.parse(price) > 0 && double.parse(quantity) > 0) {
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
                              child: new Text(
                                "Envoyer la proposition",
                                style: Style.sousTitreEvent(15),
                              ),
                              color: colorText,
                              disabledElevation: 0.0,
                              disabledColor: Colors.grey[300],
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                            ): SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ),
                        if (conversation['etatCommunication'] != null && conversation['etatCommunication'] == 'Seller and Buyer validate price final') Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new SvgPicture.asset(
                              "images/deals_validate.svg",
                              semanticsLabel: 'deals_validate',
                              height:
                              MediaQuery.of(context).size.height *
                                  0.39,
                            ),
                            Text(
                                (newClient != null && room.split('_')[0] == newClient!.ident) ? "L'acheteur a accepté votre proposition 🤝" :"Vous vous êtes entendu avec le vendeur sur ça proposition 🤝",
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
        Text((newClient != null && room.split('_')[0] == newClient!.ident) ? "Vous n'avez pas encore fait de proposition" : "Le vendeur n'a pas encore fait de proposition concernant votre deals",
            textAlign: TextAlign.center,
            style: Style.sousTitreEvent(15))
      ];
    } else if(conversation['etatCommunication'] != null && conversation['etatCommunication'] == 'Seller Purpose price final at buyer') {
      if(newClient != null && room.split('_')[0] == newClient!.ident) {
        return [Text("En attente de reponse de l'acheteur", textAlign: TextAlign.center,style: Style.sousTitreEvent(15))];
      } else {
        return [
          ElevatedButton(
            onPressed: () {
                final priceFinal = conversation['priceFinal'] != null ? conversation['priceFinal'] : 0;
                if(newClient != null && newClient!.wallet >= priceFinal) {
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
                }


            },
            child: new Text(
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
            child: new Text(
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
}

class Bubble extends StatefulWidget {
  final bool isMe;
  final String message;
  final String registerDate;
  final String image;
  final String idDocument;

  Bubble(
      {required this.message,
      required this.isMe,
      required this.registerDate,
      required this.image,
      required this.idDocument});
  @override
  _BubbleState createState() => _BubbleState();
}

class _BubbleState extends State<Bubble> {
  bool stat = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {});
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
    Timer(Duration(milliseconds: 3000), () {
      setState(() {
        stat = true;
      });
    });
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    widget.image == ''
                        ? SizedBox(width: 2.0)
                        : ClipRRect(
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
                            child: Image.network(
                                "${ConsumeAPI.AssetConversationServer}${widget.idDocument}/${widget.image}"),
                          ),
                    Container(
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
                    sendEtat(stat, widget.isMe),
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

