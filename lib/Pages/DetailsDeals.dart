
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shouz/Constant/PageIndicator.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/profil_shop.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:video_player/video_player.dart';

import '../Constant/my_flutter_app_second_icons.dart';
import './ChatDetails.dart';
import 'Login.dart';

class DetailsDeals extends StatefulWidget {
  int comeBack;
  final DealsSkeletonData dealsDetailsSkeleton;
  DetailsDeals({required this.dealsDetailsSkeleton, required this.comeBack});
  @override
  _DetailsDealsState createState() => _DetailsDealsState();
}

class _DetailsDealsState extends State<DetailsDeals> {
  int _currentItem = 0;
  String id = '';
  bool isMe = false;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  bool favorite = false;
  bool isPlaying = false;
  late VideoPlayerController _controller;
  late Future<void> _initialiseVideoFlutter;

  @override
  void initState() {
    super.initState();
    print("widget.dealsDetailsSkeleton.video ${widget.dealsDetailsSkeleton.video.length.toString()}");
    if(widget.dealsDetailsSkeleton.video != "") {
      _controller =  VideoPlayerController.network(
          "${ConsumeAPI.AssetProductServer}${widget.dealsDetailsSkeleton.video}");

      _controller.setLooping(false);
      _controller.setVolume(1.0);
      setState(() {
        _initialiseVideoFlutter = _controller.initialize();
      });
      _controller.addListener(checkVideo);
    }

    getUser();
  }


  void checkVideo(){
    if(_controller.value.position == Duration(seconds: 0, minutes: 0, hours: 0) || _controller.value.position >= _controller.value.duration) {
      setState(() {
        isPlaying = false;
      });
    }
    else {
      setState(() {
        isPlaying = true;
      });
    }

  }

  @override
  void dispose(){
    if(widget.dealsDetailsSkeleton.video != "") {
      _controller.removeListener(() {});
      _controller.dispose();
    }

    super.dispose();
  }

  getUser() async {
    User newClient = await DBProvider.db.getClient();
    setState(() {
      id = newClient.ident;
      isMe = (widget.dealsDetailsSkeleton.autor != id) ? false : true;
    });
    final result = await consumeAPI.verifyIfExistItemInFavor(widget.dealsDetailsSkeleton.id, 1);
    setState(() {
      favorite = result;
    });
  }

  Future archivateProduct(String productId) async {

    if(widget.dealsDetailsSkeleton.quantity > 0) {
      final archivage = await consumeAPI.archiveProductDeals(productId);
      if(archivage['etat'] == "found") {
        await askedToLead(
            "Votre produit est archivé, il n'apparaîtra plus sur le marché",
            true, context);
      } else if (archivage['etat'] == "notFound") {
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialogCustomError('Plusieurs connexions sur ce compte', "Nous doutons de votre identité donc nous allons vous déconnecter.\nVeuillez vous reconnecter si vous êtes le vrai detenteur du compte", context),
            barrierDismissible: false);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => Login()));
      } else {
        await askedToLead(
            archivage['error'], false, context);
      }
    } else {
      await askedToLead("Le stock de ce produit est 0 vous ne pouvez plus l'archiver", false, context);
    }

  }

  Widget build(BuildContext context) {
    final register =
        DateTime.parse(widget.dealsDetailsSkeleton.registerDate); //.toString();
    String afficheDate = (DateTime.now()
                .difference(
                    DateTime(register.year, register.month, register.day))
                .inDays <
            1)
        ? "Aujourd'hui ${register.hour.toString()}h ${register.minute.toString()}"
        : "${register.day.toString()}/${register.month.toString()}/${register.year.toString()}, ${register.hour.toString()}h${register.minute.toString()}";
    afficheDate = (DateTime.now()
                .difference(
                    DateTime(register.year, register.month, register.day))
                .inDays ==
            1)
        ? "Hier ${register.hour.toString()}h${register.minute.toString()}"
        : afficheDate;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 1.9,
                  child: PageView.builder(
                    onPageChanged: (value) {
                      setState(() {
                        _currentItem = value;
                      });
                    },
                    itemCount: widget.dealsDetailsSkeleton.video == "" ? widget.dealsDetailsSkeleton.imageUrl.length: widget.dealsDetailsSkeleton.imageUrl.length +1,
                    itemBuilder: (context, index) {
                      if(widget.dealsDetailsSkeleton.video != "" && index == 0) {
                        return FutureBuilder(
                            future: _initialiseVideoFlutter,
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                  return Center(
                                    child: Text("Vidéo non chargé",
                                        style: Style.titreEvent(18)),
                                  );
                                case ConnectionState.waiting:
                                  return Center(
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.white,
                                      ),
                                      child: LoadingIndicator(indicatorType: Indicator.ballRotateChase,colors: [colorText], strokeWidth: 2),
                                    ),
                                  );
                                case ConnectionState.active:
                                  return Center(
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.white,
                                      ),
                                      child: LoadingIndicator(indicatorType: Indicator.ballRotateChase,colors: [colorText], strokeWidth: 2),
                                    ),
                                  );
                                case ConnectionState.done:
                                  if (snapshot.hasError) {
                                    return Column(
                                      children: <Widget>[
                                        Expanded(
                                            child: Center(
                                              child: Text("Vidéo non chargé",
                                                  style: Style.titreEvent(18)),
                                            )),
                                      ],
                                    );
                                  }
                                  return Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: AspectRatio(
                                          aspectRatio: _controller.value.aspectRatio,
                                          child: VideoPlayer(_controller),
                                        ),
                                      ),
                                      Positioned(
                                          height: 50,
                                          bottom:50,
                                          left:50,
                                          right:50,
                                          child: Container(
                                            height: double.infinity,
                                            padding:EdgeInsets.symmetric(horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: backgroundColorSec.withOpacity(0.25),
                                              borderRadius: BorderRadius.circular(30),

                                            ),
                                            child: Row(
                                              children: [
                                                IconButton(onPressed: () {
                                                  setState(() {
                                                    _controller.value.isPlaying
                                                        ? _controller.pause()
                                                        : _controller.play();
                                                  });
                                                }, icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow, color: _controller.value.isPlaying ? colorText: colorPrimary,)),
                                                Expanded(

                                                    child: VideoProgressIndicator(_controller, allowScrubbing: true, padding: EdgeInsets.zero, colors: VideoProgressColors(playedColor: colorText),))
                                              ],
                                            ),
                                          ))
                                    ],
                                  );
                              }
                            });
                      }
                      else {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (builder) => ViewerProduct(
                                      index: widget.dealsDetailsSkeleton.video != "" ? index - 1: index,
                                      level: widget.dealsDetailsSkeleton.level,
                                      imgUrl: widget.dealsDetailsSkeleton.imageUrl)),
                            );
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height / 2,
                            width: MediaQuery.of(context).size.width,
                            child: Image.network(
                                "${ConsumeAPI.AssetProductServer}${widget.dealsDetailsSkeleton.imageUrl[widget.dealsDetailsSkeleton.video != "" ? _currentItem - 1 == -1 ? 0:_currentItem - 1:_currentItem]}",
                                fit: BoxFit.cover),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 32.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(50.0),
                                  color: Colors.black26),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.close,
                                      color: Colors.white, size: 22.0),
                                  onPressed: () {
                                    if(widget.comeBack == 0) {
                                      Navigator.pop(context);
                                    } else {
                                      Navigator.pushNamed(context, MenuDrawler.rootName);
                                    }
                                  },
                                ),
                              )),
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width / 2.7,
                  bottom: 45.0,
                  child: Container(
                    width: 100.0,
                    child: PageIndicator(_currentItem,
                        widget.dealsDetailsSkeleton.video != "" ? widget.dealsDetailsSkeleton.imageUrl.length+ 1:widget.dealsDetailsSkeleton.imageUrl.length),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.35,
              transform: Matrix4.translationValues(0.0, -40, 0.0),
              decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Padding(
                padding: EdgeInsets.only(left: 25.0, top: 20.0, right: 25.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 7,
                            child: Text(widget.dealsDetailsSkeleton.title,
                                style: Style.titre(20.0)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: <Widget>[
                                Text(afficheDate,
                                    textAlign: TextAlign.center,
                                    style: Style.titre(10.0)),
                                if(!isMe) IconButton(
                                  icon: Icon(Icons.favorite,
                                      color: favorite
                                          ? Colors.redAccent
                                          : Colors.grey,
                                      size: 22.0),
                                  onPressed: () async {
                                    setState(() {
                                      favorite = !favorite;
                                    });
                                    await consumeAPI.addOrRemoveItemInFavorite(widget.dealsDetailsSkeleton.id, 1);

                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Text(
                        widget.dealsDetailsSkeleton.describe,
                        style: Style.sousTitre(14.0),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(MyFlutterAppSecond.pin, color: colorText),
                          SizedBox(width: 3),
                          Flexible(child: Text(widget.dealsDetailsSkeleton.lieu,
                              style: Style.priceOldDealsProductBiggest()))
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: <Widget>[
                          Icon(Icons.local_mall, color: colorText),
                          SizedBox(width: 5),
                          Text("${widget.dealsDetailsSkeleton.quantity} disponible${widget.dealsDetailsSkeleton.quantity > 1 ? 's':''}",
                              style: Style.priceOldDealsProductBiggest())
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: <Widget>[
                          Icon(Icons.tag, color: colorText),
                          SizedBox(width: 5),
                          Text(widget.dealsDetailsSkeleton.categorieName,
                              style: Style.priceOldDealsProductBiggest())
                        ],
                      ),
                      if(widget.dealsDetailsSkeleton.level == 3) Container(
                        child: TextButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Style.social_normal, color: colorText),
                                SizedBox(width: 5),
                                Text("Partager cet article")
                              ],
                            ),
                            onPressed: () {
                              Share.share("${ConsumeAPI.ProductLink}${widget.dealsDetailsSkeleton.id}");
                            }),
                        width: 200,
                      ),
                      if(widget.dealsDetailsSkeleton.level == 3) Container(
                        width: 275,
                        child: TextButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(MyFlutterAppSecond.shop, color: colorText),
                                SizedBox(width: 5),
                                Text("Voir la boutique du vendeur")
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => ProfilShop(
                                          key: UniqueKey(),
                                          comeBack: 0,
                                          authorName: widget.dealsDetailsSkeleton.authorName,
                                          onLine: widget.dealsDetailsSkeleton.onLine,
                                          profil: widget.dealsDetailsSkeleton.profil,
                                          autor: widget.dealsDetailsSkeleton.autor)));
                            })),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomSheet: Container(
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          height: 70,
          decoration: BoxDecoration(
              color: backgroundColorSec,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.dealsDetailsSkeleton.price.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold)),
                  Text("(Prix discutable)",
                      style: TextStyle(color: Colors.white, fontSize: 13.5)),
                ],
              ),
              if (isMe && widget.dealsDetailsSkeleton.quantity > 0) Container(
                height: double.infinity,
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //ICI SE TROUVERA L'icon pour la modification de l'article plutard pour le moment c'est l'archivage seul qui est disponible

                    IconButton(
                      icon: Icon(Icons.delete_sharp, color: colorText, size: 30,),
                      onPressed: (){
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => dialogCustomForValidateAction('ARCHIVER PRODUIT', 'Êtes vous sûr de vouloir archiver ce produit du Marché ?', 'Oui', () async => await archivateProduct(widget.dealsDetailsSkeleton.id), context),
                            barrierDismissible: false);

                      },
                      tooltip: 'Archiver cet article ?',
                    )
                  ],
                ),
              ),
              if (!isMe && widget.dealsDetailsSkeleton.quantity > 0) ElevatedButton(
                style: raisedButtonStyle,
                child: Text("Discuter", style: Style.titre(18)),
                onPressed: () {
                  if(widget.dealsDetailsSkeleton.archive == 0) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => ChatDetails(
                                comeBack: 0,
                                room: '',
                                productId: widget.dealsDetailsSkeleton.id,
                                name: widget.dealsDetailsSkeleton.authorName,
                                onLine: widget.dealsDetailsSkeleton.onLine,
                                profil: widget.dealsDetailsSkeleton.profil,
                                authorId: widget.dealsDetailsSkeleton.autor)));
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            dialogCustomError('Discussion impossible', "Désolé vous ne pouvez pas marchander ce produit car il est archivé", context),
                        barrierDismissible: false);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> Accumulation(List<String> otherClient) {
    List<Widget> entass = [];

    for (var i = 0; i < otherClient.length; i++) {
      if (i > 2) {
        var item = Container(
          margin: EdgeInsets.only(right: 10.0),
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: backgroundColorSec),
          child: Center(
            child: Text((otherClient.length - i).toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ),
        );
        entass.add(item);
        break;
      } else {
        var item = Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              image: DecorationImage(
                  image: AssetImage(otherClient[i]), fit: BoxFit.cover)),
        );
        entass.add(item);
      }
    }
    return entass;
  }
}

class ViewerProduct extends StatefulWidget {
  int level;
  final int index;
  final List<dynamic> imgUrl;

  ViewerProduct({required this.index, required this.imgUrl, required this.level});
  @override
  _ViewerProductState createState() => _ViewerProductState();
}

class _ViewerProductState extends State<ViewerProduct> {
  bool isSave = false;
  late PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        
      ),
      body: PageView.builder(
        itemCount: widget.imgUrl.length,
        controller:controller,
        itemBuilder: (context, index) {
          return Center(
            child: Image.network(
                "${ConsumeAPI.AssetProductServer}${widget.imgUrl[index]}",
                fit: BoxFit.contain),
          );
        }
      ),
    );
  }
}
