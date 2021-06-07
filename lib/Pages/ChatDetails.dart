import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart' as prefix0;
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shouz/Constant/my_flutter_app_second_icons.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Provider/AppState.dart';
import 'package:provider/provider.dart';
import 'package:shouz/Utils/Database.dart';

class ChatDetails extends StatefulWidget {
  var name;
  var onLine;
  var authorId;
  var productId;
  var profil;
  @override
  ChatDetails({this.name, this.onLine, this.profil, this.authorId, this.productId});
  _ChatDetailsState createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  User newClient;
  TextEditingController eCtrl = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  File _image;
  int decompte = 0;
  final picker = ImagePicker();

  Future getImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  var message = "";

  AppState appState;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
    appState.updateTyping(false);
    appState.setConversation({});
    appState = null;
  }

  getMessage() {}

  loadProfil() async {
    final client = await DBProvider.db.getClient();

    setState(() {
      newClient = client;
    });
    appState.getConversation("${widget.authorId}_${newClient.ident}_${widget.productId}");
  }

  inWrite(bool etat, String id) async {
    appState.setTyping(etat, id);
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
        bool isMe = (newClient.ident == value['ident']) ? true : false;
//        print(date);
        if (date == 1) {
          if (!again) {
            tabs.add(Text("Hier",
                style: prefix0.Style.sousTitre(10),
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
                style: prefix0.Style.sousTitre(10),
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
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<AppState>(context);
    final conversation = appState.getConversationGetter;
    Timer(
        Duration(milliseconds: 100),
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent));

    return new Scaffold(
      backgroundColor: prefix0.backgroundColor,
      appBar: AppBar(
        backgroundColor: prefix0.backgroundColor,
        title: Row(
          children: <Widget>[
            Container(
              height: 40,
              width: 40,
              margin: EdgeInsets.fromLTRB(0, 5, 10, 0),
              decoration: BoxDecoration(
                border: Border.all(
                    width: 2.0,
                    color:
                        widget.onLine ? Colors.green[300] : Colors.yellow[300]),
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
                    maxLines: 1, style: prefix0.Style.titleInSegment()),
                Text(widget.onLine ? "En ligne" : "Déconnecté",
                    style: prefix0.Style.sousTitre(10)),
                (new Random().nextInt(3) == 0)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: 8),
                          appState.getTyping
                              ? Loading(
                                  indicator: BallPulseIndicator(), size: 10.0)
                              : SizedBox(width: 8),
                        ],
                      )
                    : SizedBox(width: 1.0),
              ],
            )
          ],
        ),
        centerTitle: false,
      ),
      body: GestureDetector(
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
                                top: 5.0, left: 5.0, right: 5.0, bottom: 70.0),
                            child: Column(
                              children: reformateView(conversation),
                            ),
                          );
                        }),
                  )
                ],
              ),
            ),
            Positioned(
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
                                    child: Image.file(_image)),
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
                                  color: prefix0.colorText),
                              onPressed: getImage,
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: eCtrl,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: prefix0.Style.chatOutMe(14),
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                decoration: InputDecoration(
                                    hintText: "Entrer le message",
                                    border: InputBorder.none,
                                    hintStyle: prefix0.Style.sousTitre(14)),
                                onChanged: (text) async {
                                  setState(() {
                                    message = text;
                                    if (message.length == 1) {
                                      print(message);
                                      inWrite(true, widget.authorId);
                                      // appState.setTyping(true, widget.authorId);
                                    } else if (message.length == 0) {
                                      print(false);
                                      inWrite(false, widget.authorId);
                                      // appState.setTyping(false, widget.authorId);
                                    }
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(MyFlutterAppSecond.email,
                                  color: prefix0.colorText),
                              onPressed: () {
                                setState(() {
                                  eCtrl.text = "";
                                  File imm = _image;
                                  _image = null;
                                  print(appState.getConversationGetter['_id']);
                                  if (appState.getConversationGetter['_id'] == null) {
                                    if (imm == null && message == "") {
                                    } else if (imm != null) {
                                      final base64Image =
                                          base64Encode(imm.readAsBytesSync());
                                      String imageCover =
                                          imm.path.split('/').last;
                                      appState.createChatMessage(
                                          destinate: "${widget.authorId}_${newClient.ident}_${widget.productId}",
                                          base64: base64Image,
                                          imageName: imageCover,
                                          content: message);
                                    } else {
                                      appState.createChatMessage(
                                          destinate: "${widget.authorId}_${newClient.ident}_${widget.productId}",
                                          content: message);
                                    }
                                    // tabs.add(Bubble(isMe: true,message: message, registerDate: (new DateTime.now().hour).toString() +":"+(new DateTime.now().minute).toString(), image: imm));
                                    Timer(
                                        Duration(milliseconds: 10),
                                        () => _scrollController.jumpTo(
                                            _scrollController
                                                .position.maxScrollExtent));
                                  } else {
                                    print(appState.getConversationGetter);
                                    if (imm == null && message == "") {
                                    } else if (imm != null) {
                                      final base64Image =
                                          base64Encode(imm.readAsBytesSync());
                                      String imageCover =
                                          imm.path.split('/').last;
                                      appState.sendChatMessage(
                                          destinate: widget.authorId,
                                          base64: base64Image,
                                          imageName: imageCover,
                                          content: message,
                                          id: appState.getIdOldConversation);
                                      print(imageCover);
                                    } else {
                                      appState.sendChatMessage(
                                          destinate: widget.authorId,
                                          content: message,
                                          id: appState.getIdOldConversation);
                                    }
                                    // tabs.add(Bubble(isMe: true,message: message, registerDate: (new DateTime.now().hour).toString() +":"+(new DateTime.now().minute).toString(), image: imm));
                                  }
                                  message = '';
                                });
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
    );
  }
}

class Bubble extends StatefulWidget {
  final bool isMe;
  final String message;
  final String registerDate;
  final String image;
  final String idDocument;

  Bubble(
      {this.message,
      this.isMe,
      this.registerDate,
      this.image,
      this.idDocument});
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

  Widget SendEtat(etat, isMe) {
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
                    color: widget.isMe ? prefix0.colorText : Colors.white,
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
                            ? prefix0.Style.chatIsMe(15)
                            : prefix0.Style.chatOutMe(15.0),
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
                      style: prefix0.Style.chatIsMe(12),
                    ),
                    SizedBox(width: 7),
                    SendEtat(stat, widget.isMe),
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
