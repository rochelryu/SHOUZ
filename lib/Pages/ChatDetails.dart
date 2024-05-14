import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
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
import 'package:url_launcher/url_launcher.dart';
import 'LoadHide.dart';
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
  ChatDetails(
      {this.name,
      this.onLine,
      this.profil,
      this.authorId,
      this.productId,
      this.room,
      required this.comeBack,
      required this.newClient});
  _ChatDetailsState createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails>
    with SingleTickerProviderStateMixin {
  TextEditingController eCtrl = TextEditingController();
  ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  File? _image;
  String base64Image = "", imageCover = "";
  final picker = ImagePicker();
  ConsumeAPI consumeAPI = ConsumeAPI();
  SharedPreferences? prefs;
  Map<dynamic, dynamic>? productDetails;

  String price = "";
  TextEditingController priceCtrl = TextEditingController();
  String quantity = "";
  TextEditingController quantityCtrl = TextEditingController();
  String displayTime = '00:00';
  String idConversation = '';
  int historyChangeForConversation = 0;

  Timer? _timer;
  Timer? _ampTimer;
  Timer? perodicScroll;
  final _audioRecorder = AudioRecorder();
  //String pathRecordAudio = '';

  double opacity = 0.0;

  bool isListeen = false, showFloatingAction = false;

  String message = '';

  Future getImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      base64Image = base64Encode(File(image.path).readAsBytesSync());
      imageCover = image.path.split('/').last;
      setState(() {
        _image = File(image.path);
      });
    }
  }

  String room = '';

  late AppState appState;
  var onLine = false;

  @override
  void initState() {
    super.initState();
    isListeen = false;
    _tabController = TabController(length: 2, vsync: this);
    appState = Provider.of<AppState>(context, listen: false);
    perodicScroll = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_scrollController.hasClients) {
        if (appState.getConversationGetter['content'] != null &&
            historyChangeForConversation <
                appState.getConversationGetter['content'].length) {
          historyChangeForConversation =
              appState.getConversationGetter['content'].length;

          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut);
          if (!onLine) {
            reloadForChangeConnectionUser();
          }
        }
        if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 50 &&
            showFloatingAction) {
          setState(() {
            showFloatingAction = false;
          });
        } else if (_scrollController.position.pixels <
                _scrollController.position.maxScrollExtent - 100 &&
            !showFloatingAction) {
          setState(() {
            showFloatingAction = true;
          });
        }
        if (appState.getConversationGetter['_id'] == "" &&
            productDetails != null) {
          loadProfil();
        }
      }
    });
    loadProfil();
  }

  @override
  dispose() {
    perodicScroll?.cancel();
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  getMessage() {}

  loadProfil() async {
    setState(() {
      onLine = widget.onLine;
    });

    final String roomLocal = widget.room == ''
        ? "${widget.authorId}_${widget.newClient.ident}_${widget.productId}"
        : widget.room.trim();
    setState(() {
      this.room = roomLocal;
    });
    prefs = await SharedPreferences.getInstance();
    final converse = prefs?.getString(room);

    if (converse != null) {
      final conversation = jsonDecode(converse);
      appState.setConversation(conversation);
      appState.setIdOldConversation(conversation['_id'].trim());
      idConversation = conversation['_id'].trim();
    }
    try {
      if (roomLocal != "" && roomLocal.indexOf("_") != -1) {
        appState.getConversation(roomLocal);
        final arrayOfId = roomLocal.toString().split('_');
        final productInfo = await consumeAPI.getDetailsDeals(arrayOfId[2]);
        if (arrayOfId[1] != "" && arrayOfId[0] != "") {
          final infoOnLine = await consumeAPI.verifyClientIsOnLine(
              arrayOfId[0] == widget.newClient.ident
                  ? arrayOfId[1]
                  : arrayOfId[0]);
          setState(() {
            onLine = infoOnLine;
          });
        }
        setState(() {
          productDetails = productInfo;
        });
        idConversation = appState.getConversationGetter['_id'];
      }
    } catch (e) {
      print(e);
    }
  }

  reloadForChangeConnectionUser() async {
    final String roomLocal = widget.room == ''
        ? "${widget.authorId}_${widget.newClient.ident}_${widget.productId}"
        : widget.room.trim();

    if (roomLocal != "" && roomLocal.indexOf("_") != -1) {
      final arrayOfId = roomLocal.toString().split('_');
      final infoOnLine = await consumeAPI.verifyClientIsOnLine(
          arrayOfId[0] == widget.newClient.ident ? arrayOfId[1] : arrayOfId[0]);
      setState(() {
        onLine = infoOnLine;
      });
    }
  }

  deleteMessage(int indexContent, String room, String identUser) {
    appState.deleteMessage(indexContent, room, identUser);
  }

  inWrite(bool etat, String room, String identUser) {
    appState.setTyping(etat, room, identUser);
  }

  List<Widget> reformateView(conversation) {
    bool again = false;
    bool againToday = false;
    List<Widget> tabs = [];
    if (conversation['content'] != null) {
      for (int index = 0; index < conversation['content'].length; index++) {
        final value = conversation['content'][index];
        final date = DateTime.now()
            .difference(DateTime(
                int.parse(value['date'].substring(0, 4)),
                int.parse(value['date'].substring(5, 7)),
                int.parse(value['date'].substring(8, 10))))
            .inDays;
        bool isMe = (widget.newClient.ident == value['ident']) ? true : false;
        if (date == 1) {
          if (!again) {
            tabs.add(SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text("Hier",
                  style: Style.sousTitre(10), textAlign: TextAlign.center),
            ));
            again = true;
          }
          tabs.add(boxMessage(
              indexContent: index,
              ident: widget.newClient.ident,
              room: room,
              callback: deleteMessage,
              isMe: isMe,
              message: value['content'],
              registerDate: value['date'].substring(11, 16).toString(),
              idDocument: conversation['_id'],
              isReadByOtherUser: value['isReadByOtherUser'],
              image: value['image'],
              context: context));
        } else if (date < 1) {
          if (!againToday) {
            tabs.add(SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text("Aujourd'hui",
                  style: Style.sousTitre(10), textAlign: TextAlign.center),
            ));
            againToday = true;
          }
          tabs.add(boxMessage(
              indexContent: index,
              ident: widget.newClient.ident,
              room: room,
              callback: deleteMessage,
              isMe: isMe,
              message: value['content'],
              registerDate: value['date'].substring(11, 16).toString(),
              idDocument: conversation['_id'],
              isReadByOtherUser: value['isReadByOtherUser'],
              image: value['image'],
              context: context));
          final lastMessage = conversation['content'].length == index + 1;
          if (!isMe &&
              value['content']
                      .toString()
                      .indexOf("Je viens d'enregistrer une offre") !=
                  -1 &&
              room.split('_')[0] != widget.newClient.ident &&
              conversation['etatCommunication'] ==
                  'Seller Purpose price final at buyer' &&
              lastMessage) {
            tabs.add(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final priceFinal = conversation['priceFinal'] != null
                          ? conversation['priceFinal']
                          : 0;
                      if (widget.newClient.wallet >= priceFinal) {
                        appState.agreeForPropositionForDeals(
                            room: room,
                            id: idConversation,
                            methodPayement: 'immediate');
                        openAppReview(context);
                      } else {
                        await prefs?.setDouble('amountRecharge',
                            priceFinal - widget.newClient.wallet);
                        Fluttertoast.showToast(
                            msg: 'Solde Insuffisant pensez à vous recharger',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0);

                        Timer(const Duration(milliseconds: 2000), () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => ChoiceMethodPayement(
                                    key: UniqueKey(),
                                    isRetrait: false,
                                  )));
                        });
                      }
                    },
                    child: Text(
                      "👉 Payer Maintenant",
                      style: Style.sousTitreEvent(12),
                    ),
                    style: raisedButtonStyleSuccess,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final priceFinal = conversation['priceFinal'] != null
                          ? conversation['priceFinal']
                          : 0;
                      if (priceFinal >= 0) {
                        appState.agreeForPropositionForDeals(
                            room: room,
                            id: idConversation,
                            methodPayement: 'delivery');
                        openAppReview(context);
                      } else {
                        await prefs?.setDouble('amountRecharge',
                            priceFinal - widget.newClient.wallet);
                        Fluttertoast.showToast(
                            msg: 'Solde Insuffisant pensez à vous recharger',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0);

                        Timer(const Duration(milliseconds: 2000), () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => ChoiceMethodPayement(
                                    key: UniqueKey(),
                                    isRetrait: false,
                                  )));
                        });
                      }
                    },
                    child: Text(
                      "👉 Payer à la livraison",
                      style: Style.sousTitreEvent(12),
                    ),
                    style: raisedButtonStyle,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      appState.notAgreeForPropositionForDeals(
                          room: room, id: idConversation);
                      Fluttertoast.showToast(
                          msg: 'Reponse envoyée',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: colorText,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    },
                    child: Text(
                      "Refuser l'offre 👈",
                      style: Style.sousTitreEvent(12),
                    ),
                    style: raisedButtonStyleError,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await launchUrl(
                          Uri.parse(
                              "https://wa.me/$serviceCall?text=Salut je veux acheter un atricle dans votre application mais je ne sais pas comment le faire. #aideAchat"),
                          mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      "Besoin d'aide ?",
                      style: Style.sousTitreEvent(15),
                    ),
                    style: raisedButtonStyle,
                  ),
                ],
              ),
            );
          }
        } else {
          tabs.add(boxMessage(
              indexContent: index,
              ident: widget.newClient.ident,
              room: room,
              callback: deleteMessage,
              isMe: isMe,
              message: value['content'],
              isReadByOtherUser: value['isReadByOtherUser'],
              registerDate: value['date']
                  .substring(0, 16)
                  .toString()
                  .replaceAll(RegExp('T'), ' à '),
              idDocument: conversation['_id'],
              image: value['image'],
              context: context));
        }
      }
    }
    if (conversation['etatCommunication'] != null &&
        conversation['etatCommunication'] ==
            'Seller and Buyer validate price final' &&
        conversation['levelDelivery'] <= 3) {
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
                    color: conversation['levelDelivery'] > 0
                        ? colorSuccess
                        : colorSecondary,
                  ),
                  indicatorStyle: IndicatorStyle(
                    color: colorSuccess,
                  ),
                  startChild: livraisonWidget(
                      'images/chez_client.png', 'Niveau Vendeur'),
                ),
                TimelineTile(
                  axis: TimelineAxis.horizontal,
                  alignment: TimelineAlign.manual,
                  lineXY: 0.8,
                  beforeLineStyle: LineStyle(
                    color: conversation['levelDelivery'] >= 2
                        ? colorSuccess
                        : colorSecondary,
                  ),
                  afterLineStyle: LineStyle(
                    color: conversation['levelDelivery'] >= 3
                        ? colorSuccess
                        : colorSecondary,
                  ),
                  indicatorStyle: IndicatorStyle(
                    color: conversation['levelDelivery'] >= 2
                        ? colorSuccess
                        : colorSecondary,
                  ),
                  startChild: livraisonWidget(
                      conversation['levelDelivery'] >= 2
                          ? 'images/reception_shouz.png'
                          : 'images/reception_shouz_off.png',
                      'Niveau Shouz'),
                ),
                TimelineTile(
                  axis: TimelineAxis.horizontal,
                  alignment: TimelineAlign.manual,
                  lineXY: 0.8,
                  isLast: true,
                  beforeLineStyle: LineStyle(
                    color: conversation['levelDelivery'] >= 3
                        ? colorSuccess
                        : colorSecondary,
                  ),
                  indicatorStyle: IndicatorStyle(
                    color: conversation['levelDelivery'] >= 3
                        ? colorSuccess
                        : colorSecondary,
                  ),
                  startChild: livraisonWidget(
                      conversation['levelDelivery'] >= 3
                          ? 'images/client_a_colis.png'
                          : 'images/client_a_colis_off.png',
                      'Niveau Client'),
                ),
              ],
            )),
      );
      if (conversation['levelDelivery'] > 0 &&
          conversation['levelDelivery'] < 3 &&
          conversation['methodPayement'] == 'delivery') {
        tabs.add(Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "💁 Quand le livreur sera devant vous avec l'article il vous faudra cliquer sur le boutton 'Payer Maintenant'",
                style: Style.chatIsMe(fontSize: 15),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final priceFinal = conversation['priceFinal'] != null
                          ? conversation['priceFinal']
                          : 0;
                      if (widget.newClient.wallet >= priceFinal) {
                        appState.agreeForPropositionForDeals(
                            room: room,
                            id: appState.getIdOldConversation.trim(),
                            methodPayement: "delivery",
                            finalityPayement: true,
                        );
                        openAppReview(context);
                      } else {
                        await prefs?.setDouble('amountRecharge',
                            priceFinal - widget.newClient.wallet);
                        Fluttertoast.showToast(
                            msg: 'Solde Insuffisant pensez à vous recharger',
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: colorError,
                            textColor: Colors.white,
                            fontSize: 16.0);

                        Timer(const Duration(milliseconds: 2000), () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => ChoiceMethodPayement(
                                    key: UniqueKey(),
                                    isRetrait: false,
                                  )));
                        });
                      }
                    },
                    child: Text(
                      "Payer Maintenant",
                      style: Style.sousTitreEvent(15),
                    ),
                    style: raisedButtonStyle,
                  ),
                ],
              )
            ],
          ),
        ));
      }
    }
    if (conversation['levelDelivery'] == 3 &&
        room != '' &&
        room.split('_')[1] == widget.newClient.ident) {
      tabs.add(Container(
        height: 120,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "💁 ️Le produit est il bel et bien ce dont vous avez convenu avec le vendeur ? ",
              style: Style.chatIsMe(fontSize: 15),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final info =
                        await consumeAPI.responseProductForLastStep(room, 0);
                    if (info['etat'] == 'found') {
                      await askedToLead(
                          "Nous sommes heureux de savoir que le produit vous a convenu. Au plaisir de vous revoir !!!",
                          true,
                          context);
                      Navigator.pushNamed(context, MenuDrawler.rootName);
                    } else {
                      await askedToLead(
                          "Un problème est survenue veuillez attendre quelque instant avant de relancer ou contacter le support technique",
                          false,
                          context);
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
                    final info =
                        await consumeAPI.responseProductForLastStep(room, 1);
                    if (info['etat'] == 'found') {
                      await askedToLead(
                          "Nous somme désolé que vous n'ayez pas apprecié le produit votre argent vous sera restitué une fois que notre livreur viendra chercher le produit",
                          true,
                          context);
                      Navigator.pushNamed(context, MenuDrawler.rootName);
                    } else {
                      await askedToLead(
                          "Un problème est survenue veuillez attendre quelque instant avant de relancer ou contacter le support technique",
                          false,
                          context);
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
      ));
    }
    if (productDetails != null &&
        productDetails!['result']['quantity'] > 0 &&
        conversation['etatCommunication'] != null &&
        conversation['etatCommunication'] ==
            'Seller and Buyer validate price final' &&
        conversation['levelDelivery'] >= 5 &&
        conversation['levelDelivery'] < 7 &&
        room != '' &&
        room.split('_')[1] == widget.newClient.ident) {
      tabs.add(SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Il y'a encore ce produit en stock, voulez vous relancer un nouveau Deal ?",
              style: Style.titleNews(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                appState.relanceDeals(
                    destinate: room,
                    content: "Encore moi 👋🏽",
                    id: idConversation);
              },
              child: Text(
                "Oui, je suis intéressé.",
                style: Style.sousTitreEvent(15),
              ),
              style: raisedButtonStyle,
            ),
          ],
        ),
      ));
    }

    if (productDetails != null &&
        conversation['etatCommunication'] != null &&
        conversation['etatCommunication'] ==
            'Seller and Buyer validate price final' &&
        conversation['levelDelivery'] == 7) {
      tabs.add(Container(
        height: 45,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Le produit ne se trouvait pas avec le vendeur",
              style: Style.titleNews(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ));
    }
    return tabs;
  }

  Widget propositionAuteur(
      String? etatCommunication, bool iAmAuteur, int? priceFinal, int? qte) {
    if (etatCommunication == 'Conversation between users') {
      if (iAmAuteur) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prix Total Proposé', style: Style.chatIsMe(fontSize: 13)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Card(
                          color: Colors.transparent,
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0)),
                          child: Container(
                            height: 50,
                            width:
                                MediaQuery.of(context).size.width * 0.3,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            decoration: BoxDecoration(
                                color: backgroundColorSec,
                                border: Border.all(
                                    width: 1.0, color: colorText),
                                borderRadius:
                                    BorderRadius.circular(50.0)),
                            child: TextField(
                              textAlign: TextAlign.start,
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
                                contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  hintText: "Prix vente",
                                  hintStyle: TextStyle(
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                      ]),
                ],
              ),
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Qte Proposée', style: Style.chatIsMe(fontSize: 13)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Card(
                      color: Colors.transparent,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.3,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: backgroundColorSec,
                            border:
                                Border.all(width: 1.0, color: colorText),
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
                ),
              ],
            ))
          ],
        );
      } else {
        return Center(
          child: Text('Pas encore de proposition faites par le vendeur', textAlign: TextAlign.center,
              style: Style.chatIsMe(fontSize: 15)),
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
                Text('Prix Proposé', style: Style.chatIsMe(fontSize: 15)),
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
                Text('Qte Proposé', style: Style.chatIsMe(fontSize: 15)),
                Text(qte!.toString(), style: Style.titleNews()),
              ],
            ),
          ),
        ],
      );
    } else if (etatCommunication == 'Seller and Buyer validate price final') {
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Prix Total Proposé', style: Style.chatIsMe(fontSize: 13)),
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
                Text('Qte Proposé', style: Style.chatIsMe(fontSize: 13)),
                Text(qte!.toString(), style: Style.titleNews()),
              ],
            ),
          ),
          Text(
            'Vendeur et Acheteur se sont entendus sur cette proposition 🤝',
            textAlign: TextAlign.center,
            style: Style.titleNews(16.0),
          )
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
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Style.white),
            onPressed: () {
                appState.setConversation({});
                appState.setIdOldConversation('');
                appState.updateLoadingToSend(false);
                appState.updateTyping(false);
                if (widget.comeBack == 0) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushNamed(context, MenuDrawler.rootName);
                }
            },
          ),
          actions: [
            badges.Badge(
              showBadge: room.split('_')[0] != widget.newClient.ident &&
                  conversation['etatCommunication'] ==
                      'Seller Purpose price final at buyer',
              position: badges.BadgePosition.topStart(top: 0, start: 0),
              badgeStyle: badges.BadgeStyle(badgeColor: colorText),
              badgeContent: Text(
                '!',
                style: TextStyle(color: Colors.white),
              ),
              child: IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: Style.white,),
                onPressed: () {
                  scaffoldKey.currentState?.openEndDrawer();
                },
              ),
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
                        maxLines: 1,
                        style: Style.titleInSegment(12.0),
                        overflow: TextOverflow.ellipsis),
                    if (onLine) Text("En ligne", style: Style.sousTitre(10)),
                    if (appState.getTyping)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: 3),
                          Container(
                            height: 6,
                            width: 25,
                            padding: EdgeInsets.only(top: 2),
                            child: LoadingIndicator(
                                indicatorType: Indicator.ballPulse,
                                colors: [colorSecondary],
                                strokeWidth: 1),
                          ),
                        ],
                      )
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/backgoundChat.png'),
                      fit: BoxFit.cover)),
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
                                        top: 5.0,
                                        left: 5.0,
                                        right: 5.0,
                                        bottom: conversation[
                                                        'etatCommunication'] !=
                                                    null &&
                                                conversation[
                                                        'etatCommunication'] ==
                                                    'Seller and Buyer validate price final'
                                            ? 10
                                            : 70.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: reformateView(conversation),
                                    ),
                                  );
                                }),
                          )
                        ],
                      ),
                    ),
                    if ((conversation['etatCommunication'] != null &&
                            conversation['etatCommunication'] !=
                                'Seller and Buyer validate price final') ||
                        conversation['etatCommunication'] == null)
                      Positioned(
                          bottom: 0,
                          left: 0,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 85,
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    if (_image != null)
                                      GestureDetector(
                                        child: Container(
                                          height: 85,
                                          width: 85,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 2.0,
                                                  color: colorPrimary),
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(4),
                                                  topLeft: Radius.circular(4)),
                                              image: DecorationImage(
                                                  image: FileImage(_image!),
                                                  fit: BoxFit.cover)),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _image = null;
                                          });
                                        },
                                      ),
                                    Spacer(),
                                    if (showFloatingAction)
                                      SizedBox(
                                          height: 85,
                                          width: 85,
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                _scrollController.animateTo(
                                                    _scrollController.position
                                                        .maxScrollExtent,
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve: Curves.easeInOut);
                                              },
                                              child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: colorText
                                                        .withOpacity(0.3),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.arrow_downward,
                                                      color: colorPrimary,
                                                      size: 18,
                                                    ),
                                                  )),
                                            ),
                                          )),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(30),
                                      topLeft: Radius.circular(
                                          _image != null ? 0 : 30),
                                    ),
                                    color: Colors.white),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight:
                                        eCtrl.text.length < 17 ? 50.0 : 125.0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(MyFlutterAppSecond.attach,
                                            color: colorText),
                                        onPressed: getImage,
                                      ),
                                      Expanded(
                                        child: isListeen
                                            ? Container(
                                                height: 50,
                                                width: double.infinity,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    AnimatedOpacity(
                                                        child: Container(
                                                          height: 15,
                                                          width: 15,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: colorError,
                                                          ),
                                                        ),
                                                        opacity: opacity,
                                                        duration:
                                                            const Duration(
                                                                seconds: 1)),
                                                    SizedBox(width: 10),
                                                    Text(displayTime,
                                                        style: Style
                                                            .simpleTextBlack())
                                                  ],
                                                ),
                                              )
                                            : TextFormField(
                                                controller: eCtrl,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                style: Style.chatOutMe(14),
                                                keyboardType:
                                                    TextInputType.multiline,
                                                maxLines: null,
                                                decoration: InputDecoration(
                                                    hintText:
                                                        "Entrer le message",
                                                    border: InputBorder.none,
                                                    hintStyle:
                                                        Style.sousTitre(14)),
                                                onChanged: (text) {
                                                  setState(() {
                                                    message = text;
                                                  });
                                                  if (text.length == 1) {
                                                    inWrite(true, room,
                                                        widget.newClient.ident);
                                                    // appState.setTyping(true, widget.authorId);
                                                  } else if (text.length == 0) {
                                                    inWrite(false, room,
                                                        widget.newClient.ident);
                                                    // appState.setTyping(false, widget.authorId);
                                                  }
                                                },
                                              ),
                                      ),
                                      if (isListeen)
                                        IconButton(
                                          icon: Icon(Icons.delete_sharp,
                                              color: backgroundColorSec),
                                          onPressed: () {
                                            _removeRecord();
                                          },
                                        ),
                                      if (appState.getLoadingToSend)
                                        LoadingIndicator(
                                            indicatorType: Indicator
                                                .ballClipRotateMultiple,
                                            colors: [colorText],
                                            strokeWidth: 2)
                                      else if ((!appState.getLoadingToSend &&
                                              message.length > 0 &&
                                              !isListeen) ||
                                          _image != null)
                                        IconButton(
                                          icon: Icon(MyFlutterAppSecond.email,
                                              color: colorText),
                                          onPressed: () async {
                                            if (_image == null &&
                                                message == "") {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      'Ecrivé au moins quelque chose avant d\'envoyer',
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: colorError,
                                                  textColor: Colors.black,
                                                  fontSize: 16.0);
                                            } else {
                                              appState
                                                  .updateLoadingToSend(true);
                                              eCtrl.text = "";

                                              if (appState.getConversationGetter[
                                                      '_id'] ==
                                                  null) {
                                                if (_image != null) {
                                                  appState.createChatMessage(
                                                      destinate: room,
                                                      base64: base64Image,
                                                      imageName: imageCover,
                                                      content: message);
                                                  inWrite(false, room,
                                                      widget.newClient.ident);
                                                  setState(() {
                                                    isListeen = false;
                                                    message = "";
                                                  });
                                                  eCtrl.clear();
                                                } else {
                                                  appState.createChatMessage(
                                                      destinate: room,
                                                      content: message);
                                                  inWrite(false, room,
                                                      widget.newClient.ident);
                                                }
                                                setState(() {
                                                  _image = null;
                                                  base64Image = '';
                                                  imageCover = '';
                                                  isListeen = false;
                                                  message = "";
                                                });
                                                eCtrl.clear();
                                                _scrollController.animateTo(
                                                    _scrollController.position
                                                        .maxScrollExtent,
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve: Curves.easeInOut);
                                              } else {
                                                if (_image != null) {
                                                  final setFile = await consumeAPI
                                                      .postFileOfConversation(
                                                          message,
                                                          room,
                                                          base64Image,
                                                          imageCover,
                                                          idConversation
                                                              .trim());
                                                  if (setFile['etat'] ==
                                                      'found') {
                                                    appState.refreshChatMessage(
                                                        room: room,
                                                        id: idConversation
                                                            .trim());
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'Problème de reseau',
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            colorError,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  }
                                                  inWrite(false, room,
                                                      widget.newClient.ident);
                                                } else {
                                                  appState.sendChatMessage(
                                                      destinate: room,
                                                      content: message,
                                                      id: idConversation
                                                          .trim());
                                                  inWrite(false, room,
                                                      widget.newClient.ident);
                                                }
                                                setState(() {
                                                  _image = null;
                                                  base64Image = '';
                                                  imageCover = '';
                                                  isListeen = false;
                                                  message = "";
                                                });
                                                eCtrl.clear();
                                                _scrollController.animateTo(
                                                    _scrollController.position
                                                        .maxScrollExtent,
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    curve: Curves.easeInOut);
                                              }
                                            }
                                          },
                                        )
                                      else if (!appState.getLoadingToSend &&
                                          message.length == 0 &&
                                          _image == null)
                                        IconButton(
                                          icon: Icon(
                                            isListeen
                                                ? MyFlutterAppSecond.email
                                                : Icons.mic_none_outlined,
                                            color: colorText,
                                          ),
                                          onPressed: () async {
                                            if (!isListeen) {
                                              _start();
                                            } else {
                                              appState
                                                  .updateLoadingToSend(true);
                                              _stop();
                                            }
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ))
                  ],
                ),
              ),
            ),
          ],
        ),
        endDrawer: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Drawer(
            child: Container(
              color: backgroundColor,
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: productDetails == null
                  ? Center(
                      child: LoadingIndicator(
                          indicatorType: Indicator.ballClipRotateMultiple,
                          colors: [colorText],
                          strokeWidth: 2),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 35.0),
                          child: Material(
                            elevation: 10,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "${ConsumeAPI.AssetProductServer}${productDetails!['result']['images'][0]}"),
                                      fit: BoxFit.cover)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => LoadProduct(
                                            key: UniqueKey(),
                                            productId: widget.productId,
                                            doubleComeBack: 2,
                                          )));
                            },
                            child: Text("Voir l'article"),
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
                                text: (room.split('_')[0] ==
                                        widget.newClient.ident)
                                    ? 'Mon offre'
                                    : 'Vendeur',
                              ),
                              Tab(
                                //icon: const Icon(Icons.shopping_cart),
                                text: (room.split('')[1] ==
                                        widget.newClient.ident)
                                    ? 'Ma réponse'
                                    : 'Acheteur',
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 40,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Prix Initial',
                                                  style: Style.chatIsMe(fontSize: 15)),
                                              Text(
                                                  productDetails!['result']
                                                          ['price']
                                                      .toString(),
                                                  style: Style.titleNews()),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 40,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Prix Livraison',
                                                  style: Style.chatIsMe(fontSize: 15)),
                                              Text(
                                                  productDetails!['result']
                                                          ['priceDelivery']
                                                      .toString(),
                                                  style: Style.titleNews()),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 40,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Qte Restante',
                                                  style: Style.chatIsMe(fontSize: 15)),
                                              Text(
                                                  productDetails!['result']
                                                          ['quantity']
                                                      .toString(),
                                                  style: Style.titleNews()),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Divider(
                                          height: 1,
                                          indent: 12,
                                          endIndent: 12,
                                          color: Colors.grey[200],
                                        ),
                                        SizedBox(height: 5),
                                        Text('Proposition du vendeur',
                                            style: Style.titleNews()),
                                        SizedBox(height: 10),
                                        Divider(
                                          height: 1,
                                          indent: 12,
                                          endIndent: 12,
                                          color: Colors.grey[200],
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          width: double.infinity,
                                          child: propositionAuteur(
                                              conversation['etatCommunication'],
                                              (room.split('_')[0] ==
                                                  widget.newClient.ident),
                                              conversation['priceFinal'],
                                              conversation['quantityProduct']),
                                        ),
                                        if (conversation['etatCommunication'] !=
                                                null &&
                                            conversation['etatCommunication'] ==
                                                'Conversation between users' &&
                                            room.split('_')[0] ==
                                                widget.newClient.ident)
                                          ElevatedButton(
                                            onPressed: () {
                                              if (int.parse(quantity) <=
                                                      productDetails!['result']
                                                          ['quantity'] &&
                                                  double.parse(price) > 0 &&
                                                  double.parse(quantity) > 0) {
                                                appState
                                                    .sendPropositionForDealsByAuteur(
                                                        price: price,
                                                        qte: quantity,
                                                        room: room,
                                                        id: idConversation);
                                                Navigator.pop(context);
                                                Fluttertoast.showToast(
                                                    msg: 'Proposition envoyée',
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: colorText,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                                Timer(Duration(seconds: 2), () {
                                                  openAppReview(context);
                                                });
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Erreur sur la quantité ou le prix",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
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
                                if (conversation['etatCommunication'] != null &&
                                    conversation['etatCommunication'] ==
                                        'Seller and Buyer validate price final')
                                  Column(
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
                                          (room.split('_')[0] ==
                                                  widget.newClient.ident)
                                              ? "L'acheteur a accepté votre proposition 🤝"
                                              : "Vous vous êtes entendu avec le vendeur sur sa proposition 🤝",
                                          textAlign: TextAlign.center,
                                          style: Style.sousTitreEvent(15)),
                                    ],
                                  )
                                else
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: reformatText(conversation),
                                  )
                              ]),
                        ),
                      ],
                    ),
            ),
          ),
        ));
  }

  List<Widget> reformatText(conversation) {
    if (conversation['etatCommunication'] != null &&
        conversation['etatCommunication'] == 'Conversation between users') {
      return [
        Text(
            (room.split('_')[0] == widget.newClient.ident)
                ? "Vous n'avez pas encore fait de proposition"
                : "Le vendeur n'a pas encore fait de proposition concernant votre deals",
            textAlign: TextAlign.center,
            style: Style.sousTitreEvent(15))
      ];
    } else if (conversation['etatCommunication'] != null &&
        conversation['etatCommunication'] ==
            'Seller Purpose price final at buyer') {
      if (room.split('_')[0] == widget.newClient.ident) {
        return [
          Text("En attente de reponse de l'acheteur",
              textAlign: TextAlign.center, style: Style.sousTitreEvent(15))
        ];
      } else {
        return [
          ElevatedButton(
            onPressed: () async {
              final priceFinal = conversation['priceFinal'] != null
                  ? conversation['priceFinal']
                  : 0;
              if (widget.newClient.wallet >= priceFinal) {
                appState.agreeForPropositionForDeals(
                    room: room,
                    id: appState.getIdOldConversation.trim(),
                    methodPayement: "immediate");
                Navigator.pop(context);
              } else {
                await prefs?.setDouble(
                    'amountRecharge', priceFinal - widget.newClient.wallet);
                Fluttertoast.showToast(
                    msg: 'Solde Insuffisant pensez à vous recharger',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: colorError,
                    textColor: Colors.white,
                    fontSize: 16.0);

                Timer(const Duration(milliseconds: 2000), () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => ChoiceMethodPayement(
                            key: UniqueKey(),
                            isRetrait: false,
                          )));
                });
              }
            },
            child: Text(
              "Payer maintenant",
              style: Style.sousTitreEvent(15),
            ),
            style: raisedButtonStyleSuccess,
          ),
          SizedBox(height: 35),
          ElevatedButton(
            onPressed: () async {
              final priceFinal = conversation['priceFinal'] != null
                  ? conversation['priceFinal']
                  : 0;
              if (priceFinal >= 0) {
                appState.agreeForPropositionForDeals(
                    room: room,
                    id: appState.getIdOldConversation.trim(),
                    methodPayement: "delivery");
                Navigator.pop(context);
              } else {
                await prefs?.setDouble(
                    'amountRecharge', priceFinal - widget.newClient.wallet);
                Fluttertoast.showToast(
                    msg: 'Solde Insuffisant pensez à vous recharger',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: colorError,
                    textColor: Colors.white,
                    fontSize: 16.0);

                Timer(const Duration(milliseconds: 2000), () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => ChoiceMethodPayement(
                            key: UniqueKey(),
                            isRetrait: false,
                          )));
                });
              }
            },
            child: Text(
              "Payer à la livraison",
              style: Style.sousTitreEvent(15),
            ),
            style: raisedButtonStyle,
          ),
          SizedBox(height: 35),
          ElevatedButton(
            onPressed: () {
              appState.notAgreeForPropositionForDeals(
                  room: room, id: appState.getIdOldConversation.trim());
              Navigator.pop(context);
              Fluttertoast.showToast(
                  msg: 'Reponse envoyée',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: colorText,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            child: Text(
              "Refuser l'offre",
              style: Style.sousTitreEvent(15),
              textAlign: TextAlign.center,
            ),
            style: raisedButtonStyleError,
          ),
          SizedBox(height: 35),
          ElevatedButton(
            onPressed: () async {
              await launchUrl(
                  Uri.parse(
                      "https://wa.me/$serviceCall?text=Salut je veux acheter un atricle dans votre application mais je ne sais pas comment le faire. #aideAchat"),
                  mode: LaunchMode.externalApplication);
            },
            child: Text(
              "Besoin d'aide ?",
              style: Style.sousTitreEvent(15),
            ),
            style: raisedButtonStyle,
          ),
        ];
      }
    } else {
      return [
        Text(
            "Le vendeur n'a pas encore fait de proposition concernant votre deals",
            textAlign: TextAlign.center,
            style: Style.sousTitreEvent(15))
      ];
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
            DateTime.now().millisecondsSinceEpoch.toString() +
            '.m4a';

        return customPath;
      } else {
        final statusPermissionMicro = await Permission.microphone.request();
        final statusPermissionStorage = await Permission.storage.request();
        final statusPermissionManageStorage =
            await Permission.manageExternalStorage.request();
        if (statusPermissionMicro != PermissionStatus.granted) {
          showDialog(
              context: context,
              builder: (BuildContext context) => dialogCustomError(
                  'Permission Microphone',
                  "Il est impératif que vous nous donniez la permission de votre microphone",
                  context),
              barrierDismissible: false);
          await Permission.microphone.request();
        }
        if (statusPermissionStorage != PermissionStatus.granted) {
          showDialog(
              context: context,
              builder: (BuildContext context) => dialogCustomError(
                  'Permission Stockage',
                  "Il est impératif que vous nous donniez la permission de votre stockage fichiers",
                  context),
              barrierDismissible: false);
          await Permission.storage.request();
        }
        if (statusPermissionManageStorage != PermissionStatus.granted) {
          showDialog(
              context: context,
              builder: (BuildContext context) => dialogCustomError(
                  'Permission Enregistrement Stockage',
                  "Il est impératif que vous nous donniez la permission de gestion stockage fichiers",
                  context),
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
            const RecordConfig(),
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
    if (appState.getConversationGetter['_id'] == null) {
      appState.createChatMessage(
          destinate: room,
          base64: base64Audio,
          imageName: audioName,
          content: message);
    } else {
      final setFile = await consumeAPI.postFileOfConversation(
          message, room, base64Audio, audioName, idConversation.trim());
      if (setFile['etat'] == 'found') {
        appState.refreshChatMessage(room: room, id: idConversation.trim());
      } else {
        Fluttertoast.showToast(
            msg: 'Problème de reseau',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: colorError,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      /*appState.sendChatMessage(
          destinate: room,
          base64: base64Audio,
          imageName: audioName,
          content: message,
          id: idConversation.trim());*/
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
        opacity = opacity == 0.0 ? 1.0 : 0.0;
      });
    });
  }
}
