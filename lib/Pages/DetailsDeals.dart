import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shouz/Constant/PageIndicator.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/Pages/profil_shop.dart';
import 'package:shouz/Pages/update_deals.dart';
import 'package:shouz/Pages/view_picture.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:shouz/Constant/widget_common.dart';
import 'package:video_player/video_player.dart';

import '../Constant/helper.dart';
import '../Constant/my_flutter_app_second_icons.dart';
import './ChatDetails.dart';
import 'Login.dart';
import 'Notifications.dart';
import 'choice_method_payement.dart';
import 'list_commande.dart';

class DetailsDeals extends StatefulWidget {
  final int comeBack;
  final DealsSkeletonData dealsDetailsSkeleton;
  const DetailsDeals(
      {required this.dealsDetailsSkeleton, required this.comeBack});
  @override
  _DetailsDealsState createState() => _DetailsDealsState();
}

class _DetailsDealsState extends State<DetailsDeals>
    with SingleTickerProviderStateMixin {
  int _currentItem = 0;
  String id = '';
  bool isMe = false;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  bool favorite = false;
  bool isPlaying = false;
  late VideoPlayerController _controller;
  late Future<void> _initialiseVideoFlutter;
  User? newClient;
  late TabController _controllerTab;

  @override
  void initState() {
    super.initState();
    if (widget.dealsDetailsSkeleton.video != "") {
      _controller = VideoPlayerController.network(
          "${ConsumeAPI.AssetProductServer}${widget.dealsDetailsSkeleton.video}");

      _controller.setLooping(false);
      _controller.setVolume(1.0);
      setState(() {
        _initialiseVideoFlutter = _controller.initialize();
      });
      _controller.addListener(checkVideo);
    }
    _controllerTab = TabController(length: 2, vsync: this);
    getUser();
    //verifyIfUserHaveReadModalExplain();
  }

  verifyIfUserHaveReadModalExplain() async {
    final prefs = await SharedPreferences.getInstance();
    final bool asRead =
        prefs.getBool('readViewDetailDealsAndDiscutModalExplain') ?? false;
    if (!asRead && !isMe) {
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}discussionInAppDeal.png",
          "1/4 - 1️⃣ Si vous voulez acheter cet article vous pouvez discutez avec le vendeur directement dans l'application.\nVous pouvez négocier le prix avec lui afin d'obtenir une réduction et/ou de vous assurer de la qualité de l'article avant achat.",
          context);
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}accordPayDirect.png",
          "2/4 - 2️⃣ SHOUZPAY: Tout achat d'article se fait directement dans l'application en rechargeant son compte SHOUZ par mobile money, crypto-monnaie ou carte bancaire.",
          context);
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}guardMoney.png",
          "3/4 - ⛔️ Attention: Ne vous laissez pas anarquer si le vendeur vous propose d'aller discuter sur une autre application ou de faire un paiement ailleurs.\nNous assurons toutes les garanties de votre sécurité quand vous restez sur SHOUZ pour toutes vos actions.",
          context);
      await modalForExplain(
          "${ConsumeAPI.AssetPublicServer}guardMoney.png",
          "4/4 - 💝 Vous pouvez acheter en toute sécurité à partir de votre compte SHOUZPAY, nous vous livrerons l'article et en cas d'insatisfication nous vous remboursons votre argent, c'est ça la garantie avec SHOUZ.",
          context);
      await prefs.setBool('readViewDetailDealsAndDiscutModalExplain', true);
    }
  }

  void checkVideo() {
    if (_controller.value.position ==
            Duration(seconds: 0, minutes: 0, hours: 0) ||
        _controller.value.position >= _controller.value.duration) {
      setState(() {
        isPlaying = false;
      });
    } else {
      setState(() {
        isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    if (widget.dealsDetailsSkeleton.video != "") {
      _controller.removeListener(() {});
      _controller.dispose();
    }

    super.dispose();
  }

  getUser() async {
    User user = await DBProvider.db.getClient();
    setState(() {
      id = user.ident;
      isMe = (widget.dealsDetailsSkeleton.autor != id) ? false : true;
      if (user.numero != 'null') {
        newClient = user;
      }
    });
    final result = await consumeAPI.verifyIfExistItemInFavor(
        widget.dealsDetailsSkeleton.id, 1);
    setState(() {
      favorite = result;
    });
  }

  Future archivateProduct(String productId) async {
    if (widget.dealsDetailsSkeleton.quantity > 0) {
      final archivage = await consumeAPI.archiveProductDeals(productId);
      if (archivage['etat'] == "found") {
        await askedToLead(
            "Votre article est archivé, il n'apparaîtra plus sur le marché",
            true,
            context);
      } else if (archivage['etat'] == "notFound") {
        showDialog(
            context: context,
            builder: (BuildContext context) => dialogCustomError(
                'Plusieurs connexions à ce compte',
                "Pour une question de sécurité nous allons devoir vous déconnecter.",
                context),
            barrierDismissible: false);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (builder) => Login()));
      } else {
        await askedToLead(archivage['error'], false, context);
      }
    } else {
      await askedToLead(
          "Le stock de ce produit est 0 vous ne pouvez plus l'archiver",
          false,
          context);
    }
  }

  Future renewProduct(String productId) async {
    if (widget.dealsDetailsSkeleton.level == 3) {
      final renewArticle = await consumeAPI.renewProductDeals(productId);
      if (renewArticle['etat'] == "found") {
        await askedToLead(
            "Votre article est rémonté en tête sur le marché", true, context);
        openAppReview(context);
      } else if (renewArticle['etat'] == "notFound") {
        showDialog(
            context: context,
            builder: (BuildContext context) => dialogCustomError(
                'Plusieurs connexions à ce compte',
                "Pour une question de sécurité nous allons devoir vous déconnecter.",
                context),
            barrierDismissible: false);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (builder) => Login()));
      } else {
        await askedToLead(renewArticle['error'], false, context);
      }
    } else {
      if (widget.dealsDetailsSkeleton.quantity == 0) {
      } else {
        await askedToLead(
            "Pour faire remonter votre article dans la liste il faut que l'article soit VIP.\nAussi si vous essayez de créer un autre article avec les informations similaires de cet article sachant que cet article n'est pas encore épuisé nous serons obligé de vous rétirer le votre compte vendeur.",
            false,
            context);
      }
    }
  }

  Future createCampagne(String productId) async {
    if (widget.dealsDetailsSkeleton.level == 3) {
      final renewArticle = await consumeAPI.createCampagne(productId);
      if (renewArticle['etat'] == "found") {
        await askedToLead(
            "Campagne lancé à ${widget.dealsDetailsSkeleton.numberVue} client${widget.dealsDetailsSkeleton.numberVue > 1 ? 's' : ''}",
            true,
            context);
        openAppReview(context);
      } else if (renewArticle['etat'] == "notFound") {
        showDialog(
            context: context,
            builder: (BuildContext context) => dialogCustomError(
                'Plusieurs connexions à ce compte',
                "Pour une question de sécurité nous allons devoir vous déconnecter.",
                context),
            barrierDismissible: false);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (builder) => Login()));
      } else {
        await askedToLead(renewArticle['error'], false, context);
      }
    } else {
      if (widget.dealsDetailsSkeleton.numberVue <= 4) {
        await askedToLead(
            "Il y a moins de 5 vues pour cet article, nous vous recommandons de ne pas gaspiller votre campagne pour ça..",
            false,
            context);
      } else {
        await askedToLead(
            "Pour lancer une campagne il faut que l'article soit VIP.",
            false,
            context);
      }
    }
  }

  Future setUpVipProduct(String productId) async {
    if (widget.dealsDetailsSkeleton.level != 3) {
      if (newClient!.wallet >= 1000) {
        final renewArticle = await consumeAPI.setUpVipProduct(productId);
        if (renewArticle['etat'] == "found") {
          await askedToLead(
              "Votre article est VIP. Bravo à vous 👏👏", true, context);
          openAppReview(context);
        } else if (renewArticle['etat'] == "notFound") {
          showDialog(
              context: context,
              builder: (BuildContext context) => dialogCustomError(
                  'Plusieurs connexions à ce compte',
                  "Pour une question de sécurité nous allons devoir vous déconnecter.",
                  context),
              barrierDismissible: false);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (builder) => Login()));
        } else {
          await askedToLead(renewArticle['error'], false, context);
        }
      } else {
        await askedToLead(
            "Pour rendre un article VIP il vous faut avoir au moins 1.000 XOF sur votre compte ShouzPay",
            false,
            context);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (builder) => ChoiceMethodPayement(
                  key: UniqueKey(),
                  isRetrait: false,
                )));
      }
    } else {
      await askedToLead("Cet article est déjà VIP.", false, context);
    }
  }

  Widget build(BuildContext context) {
    final key = GlobalObjectKey<ExpandableFabState>(context);
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
                    itemCount: widget.dealsDetailsSkeleton.video == ""
                        ? widget.dealsDetailsSkeleton.imageUrl.length
                        : widget.dealsDetailsSkeleton.imageUrl.length + 1,
                    itemBuilder: (context, index) {
                      if (widget.dealsDetailsSkeleton.video != "" &&
                          index == 0) {
                        return FutureBuilder(
                            future: _initialiseVideoFlutter,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
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
                                      child: LoadingIndicator(
                                          indicatorType:
                                              Indicator.ballRotateChase,
                                          colors: [colorText],
                                          strokeWidth: 2),
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
                                      child: LoadingIndicator(
                                          indicatorType:
                                              Indicator.ballRotateChase,
                                          colors: [colorText],
                                          strokeWidth: 2),
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
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _controller.value.isPlaying
                                                  ? _controller.pause()
                                                  : _controller.play();
                                            });
                                          },
                                          child: AspectRatio(
                                            aspectRatio:
                                                _controller.value.aspectRatio,
                                            child: VideoPlayer(_controller),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                          height: 50,
                                          bottom: 50,
                                          left: 50,
                                          right: 50,
                                          child: Container(
                                            height: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: backgroundColorSec
                                                  .withOpacity(0.25),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _controller
                                                                .value.isPlaying
                                                            ? _controller
                                                                .pause()
                                                            : _controller
                                                                .play();
                                                      });
                                                    },
                                                    icon: Icon(
                                                      _controller
                                                              .value.isPlaying
                                                          ? Icons.pause
                                                          : Icons.play_arrow,
                                                      color: _controller
                                                              .value.isPlaying
                                                          ? colorText
                                                          : colorPrimary,
                                                    )),
                                                Expanded(
                                                    child:
                                                        VideoProgressIndicator(
                                                  _controller,
                                                  allowScrubbing: true,
                                                  padding: EdgeInsets.zero,
                                                  colors: VideoProgressColors(
                                                      playedColor: colorText),
                                                ))
                                              ],
                                            ),
                                          ))
                                    ],
                                  );
                              }
                            });
                      } else {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (builder) => ViewerProduct(
                                      index:
                                          widget.dealsDetailsSkeleton.video !=
                                                  ""
                                              ? index - 1
                                              : index,
                                      level: widget.dealsDetailsSkeleton.level,
                                      imgUrl: widget
                                          .dealsDetailsSkeleton.imageUrl)),
                            );
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height / 2,
                            width: MediaQuery.of(context).size.width,
                            child: buildImageInCachedNetworkWithSizeManual(
                                "${ConsumeAPI.AssetProductServer}${widget.dealsDetailsSkeleton.imageUrl[widget.dealsDetailsSkeleton.video != "" ? _currentItem - 1 == -1 ? 0 : _currentItem - 1 : _currentItem]}",
                                double.infinity,
                                double.infinity,
                                BoxFit.cover),
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
                            margin: EdgeInsets.only(top: 10),
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50.0),
                                  color: Colors.black26),
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.close,
                                      color: Colors.white, size: 22.0),
                                  onPressed: () {
                                    if (widget.comeBack == 0) {
                                      Navigator.pop(context);
                                    } else if (widget.comeBack == 1) {
                                      Navigator.pushNamed(
                                          context, MenuDrawler.rootName);
                                    } else if (widget.comeBack == 2) {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Notifications()),
                                          (route) => route.isFirst);
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
                    child: PageIndicator(
                        _currentItem,
                        widget.dealsDetailsSkeleton.video != ""
                            ? widget.dealsDetailsSkeleton.imageUrl.length + 1
                            : widget.dealsDetailsSkeleton.imageUrl.length),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: Text(widget.dealsDetailsSkeleton.title,
                              style: Style.titre(15.0)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: <Widget>[
                              Text(afficheDate,
                                  textAlign: TextAlign.center,
                                  style: Style.titre(8.0)),
                              if (!isMe)
                                
                                Row(mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      IconButton(
                                        icon: Icon(Icons.favorite,
                                            color: favorite
                                                ? Colors.redAccent
                                                : Colors.grey,
                                            size: 22.0),
                                        onPressed: () async {
                                          if (id != '' && id != 'ident') {
                                            setState(() {
                                              favorite = !favorite;
                                            });
                                            await consumeAPI
                                                .addOrRemoveItemInFavorite(
                                                widget.dealsDetailsSkeleton.id,
                                                1);
                                            openAppReview(context);
                                          } else {
                                            await modalForExplain(
                                                "${ConsumeAPI.AssetPublicServer}ready_station.svg",
                                                "Pour avoir accès à ce service il est impératif que vous créez un compte ou que vous vous connectiez",
                                                context,
                                                true);
                                            Navigator.pushNamed(
                                                context, Login.rootName);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Share.share(
                                              "${widget.dealsDetailsSkeleton.title} à ${widget.dealsDetailsSkeleton.price}\n 🙂 Shouz Avantage:\n   - 🤩 Achète à ton prix.\n   - 🤩 Paye par mobile money ou à la livraison.\n   - 🤩 Et si l'article n'est pas ce que tu as vu en ligne, Shouz te rembourse tout ton argent.\n Clique ici pour voir l'article que je te partage ${ConsumeAPI.ProductLink}${widget.dealsDetailsSkeleton.title.toString().replaceAll(' ', '-').replaceAll('/', '_')}/${widget.dealsDetailsSkeleton.id}");
                                        },
                                        icon: Icon(
                                            Style.social_normal,
                                            color: colorText,
                                            size: 22.0
                                        ),
                                      )
                                  ],
                                ),

                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: TabBar(
                        dividerHeight: 0,
                        controller: _controllerTab,
                        labelColor: Style.white,
                        unselectedLabelColor: colorSecondary,

                        //isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorColor: colorText,
                        tabs: [
                          Tab(
                            text: 'Descriptions',
                          ),
                          Tab(
                            text:
                                'Avis (${widget.dealsDetailsSkeleton.comments.length})',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: TabBarView(
                      controller: _controllerTab,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                widget.dealsDetailsSkeleton.describe,
                                style: Style.sousTitre(12.0),
                              ),
                              SizedBox(height: 5.0),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.start,
                              //   children: <Widget>[
                              //     Icon(MyFlutterAppSecond.pin,
                              //         color: colorText),
                              //     SizedBox(width: 3),
                              //     Flexible(
                              //         child: Text(
                              //             widget.dealsDetailsSkeleton.lieu,
                              //             style: Style
                              //                 .priceOldDealsProductBiggest()))
                              //   ],
                              // ),
                              SizedBox(height: 10.0),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.local_mall, color: colorText),
                                  SizedBox(width: 5),
                                  Text(
                                      "${widget.dealsDetailsSkeleton.quantity} disponible${widget.dealsDetailsSkeleton.quantity > 1 ? 's' : ''}",
                                      style:
                                          Style.priceOldDealsProductBiggest())
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.tag, color: colorText),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      widget.dealsDetailsSkeleton.categorieName,
                                      style: Style.priceOldDealsProductBiggest(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                              if (widget.dealsDetailsSkeleton.level == 3)
                                Container(
                                    child: TextButton(
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Icon(MyFlutterAppSecond.shop,
                                                color: colorText),
                                            SizedBox(width: 5),
                                            Text("Voir la boutique du vendeur", style: Style.simpleTextOnBoard(17, colorText))
                                          ],
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) => ProfilShop(
                                                      key: UniqueKey(),
                                                      comeBack: 0,
                                                      authorName: widget
                                                          .dealsDetailsSkeleton
                                                          .authorName,
                                                      onLine: widget
                                                          .dealsDetailsSkeleton
                                                          .onLine,
                                                      profil: widget
                                                          .dealsDetailsSkeleton
                                                          .profil,
                                                      autor: widget
                                                          .dealsDetailsSkeleton
                                                          .autor)));
                                        })),

                              SizedBox(height: 10.0),
                            ],
                          ),
                        ),
                        ListView.builder(
                          itemCount:
                              widget.dealsDetailsSkeleton.comments.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: backgroundColor,
                              child: Container(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  formatedDateForLocal(
                                                      DateTime.parse(widget
                                                              .dealsDetailsSkeleton
                                                              .comments[index]
                                                          ['registerDate']),
                                                      withTime: false),
                                                  style:
                                                      Style.simpleTextOnBoard(
                                                          11),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                RatingBarIndicator(
                                                  rating: double.parse(widget
                                                      .dealsDetailsSkeleton
                                                      .comments[index]['rating']
                                                      .toString()),
                                                  itemSize: 15,
                                                  direction: Axis.horizontal,
                                                  itemCount: 5,
                                                  itemPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 2.0),
                                                  itemBuilder: (context, _) =>
                                                      Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              widget.dealsDetailsSkeleton
                                                  .comments[index]['name']
                                                  .toString()
                                                  .toUpperCase(),
                                              style: Style.sousTitre(12),
                                              maxLines: 1,
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                widget.dealsDetailsSkeleton
                                                    .comments[index]['content'],
                                                style: Style.sousTitre(11)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (widget.dealsDetailsSkeleton
                                            .comments[index]['file'] !=
                                        "")
                                      Expanded(
                                        flex: 1,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (builder) =>
                                                        ViewPicture(
                                                          key: UniqueKey(),
                                                          linkPicture:
                                                              "${ConsumeAPI.AssetProductServer}${widget.dealsDetailsSkeleton.comments[index]['file']}",
                                                        )));
                                          },
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            margin: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        "${ConsumeAPI.AssetProductServer}${widget.dealsDetailsSkeleton.comments[index]['file']}"),
                                                    fit: BoxFit.cover)),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ))
                  ],
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
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.dealsDetailsSkeleton.price.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold)),
                    if (!isMe || widget.dealsDetailsSkeleton.approved)
                      Text("(Prix discutable)",
                          style:
                              TextStyle(color: Colors.white, fontSize: 13.5)),
                    if (isMe && !widget.dealsDetailsSkeleton.approved)
                      Text("(En attente de validation par Shouz)",
                          style:
                              TextStyle(color: Colors.white, fontSize: 13.5)),
                  ],
                ),
              ),
              if (!isMe && widget.dealsDetailsSkeleton.quantity > 0)
                ElevatedButton(
                  style: raisedButtonStyle,
                  child: Text("Discuter le prix", style: Style.titre(14)),
                  onPressed: () async {
                    if (newClient != null && newClient?.numero != "null" && newClient?.numero != "null" && newClient!.numero.isNotEmpty) {
                      if (widget.dealsDetailsSkeleton.archive == 0) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => ChatDetails(
                                    newClient: newClient!,
                                    comeBack: 0,
                                    room: '',
                                    productId: widget.dealsDetailsSkeleton.id,
                                    name:
                                        widget.dealsDetailsSkeleton.authorName,
                                    onLine: widget.dealsDetailsSkeleton.onLine,
                                    profil: widget.dealsDetailsSkeleton.profil,
                                    authorId:
                                        widget.dealsDetailsSkeleton.autor)));
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => dialogCustomError(
                                'Discussion impossible',
                                "Désolé vous ne pouvez pas marchander ce produit car il est archivé",
                                context),
                            barrierDismissible: false);
                      }
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
              if (isMe)
                Expanded(
                    child: Container(
                  child: Row(
                    children: [
                      SizedBox(width: 45),
                      Icon(Icons.favorite, color: Colors.redAccent, size: 22.0),
                      SizedBox(width: 3),
                      Text(
                        widget.dealsDetailsSkeleton.numberFavorite.toString(),
                        style: Style.numberOfLike(20.0),
                      ),
                      SizedBox(width: 15),
                      Icon(Icons.remove_red_eye,
                          color: colorSecondary, size: 22.0),
                      SizedBox(width: 3),
                      Text(
                        widget.dealsDetailsSkeleton.numberVue.toString(),
                        style: Style.simpleTextOnBoard(20.0),
                      ),
                      Spacer()
                    ],
                  ),
                ))
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: isMe
          ? ExpandableFab(
              key: key,
              distance: 60,
              type: ExpandableFabType.up,
              overlayStyle: ExpandableFabOverlayStyle(
                // color: Colors.black.withOpacity(0.5),
                blur: 5,
              ),
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => ListCommande(
                                  key: UniqueKey(),
                                  productId: widget.dealsDetailsSkeleton.id,
                                  level: widget.dealsDetailsSkeleton.level,
                                )));
                  },
                  child: Row(
                    children: [
                      Text(
                        "Mes commandes",
                        style: Style.titre(15.0),
                      ),
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0)),
                        color: colorText,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.lightBlue,
                              borderRadius: BorderRadius.circular(25.0)),
                          child: Center(
                            child: Icon(MyFlutterAppSecond.shop,
                                size: 17, color: colorPrimary),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => UpdateDeals(
                                  key: UniqueKey(),
                                  dealsDetailsSkeleton:
                                      widget.dealsDetailsSkeleton,
                                )));
                  },
                  child: Row(
                    children: [
                      Text(
                        "Modifier",
                        style: Style.titre(15.0),
                      ),
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0)),
                        color: colorText,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: colorSecondary,
                              borderRadius: BorderRadius.circular(25.0)),
                          child: Center(
                            child:
                                Icon(Icons.edit, size: 17, color: colorPrimary),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await renewProduct(widget.dealsDetailsSkeleton.id);
                  },
                  child: Row(
                    children: [
                      Text(
                        "Actualiser",
                        style: Style.titre(15.0),
                      ),
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0)),
                        color: colorText,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: colorSuccess,
                              borderRadius: BorderRadius.circular(25.0)),
                          child: Center(
                            child:
                                Icon(Icons.sync, color: colorPrimary, size: 17),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                if (widget.dealsDetailsSkeleton.quantity > 0)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              dialogCustomForValidateAction(
                                  'ARCHIVER PRODUIT',
                                  'Êtes vous sûr de vouloir archiver ce produit du Marché ?',
                                  'Oui',
                                  () async => await archivateProduct(
                                      widget.dealsDetailsSkeleton.id),
                                  context),
                          barrierDismissible: false);
                    },
                    child: Row(
                      children: [
                        Text(
                          "Archiver",
                          style: Style.titre(15.0),
                        ),
                        Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                          color: colorText,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(25.0)),
                            child: Center(
                              child: Icon(Icons.archive_outlined,
                                  color: colorPrimary, size: 17),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            dialogCustomForValidateAction(
                                'CAMPAGNE DE RELANCE',
                                'Nous allons envoyer un message à tous ceux qui ont vu votre article au moins une fois pour les relancer.\nAttention vous ne pouvez créer qu\'une seule fois une campagne alors assurez-vous que c\'est le moment opportun avant de dire "OK".',
                                'Ok',
                                () async => await createCampagne(
                                    widget.dealsDetailsSkeleton.id),
                                context),
                        barrierDismissible: false);
                  },
                  child: Row(
                    children: [
                      Text(
                        "Créer campagne",
                        style: Style.titre(15.0),
                      ),
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0)),
                        color: colorText,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              borderRadius: BorderRadius.circular(25.0)),
                          child: Center(
                            child: Icon(Icons.notifications_active_outlined,
                                color: colorPrimary, size: 17),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                if (widget.dealsDetailsSkeleton.level != 3 && newClient != null)
                  GestureDetector(
                    onTap: () async {
                      await setUpVipProduct(widget.dealsDetailsSkeleton.id);
                    },
                    child: Row(
                      children: [
                        Text(
                          "Rendre l'article VIP",
                          style: Style.titre(15.0),
                        ),
                        Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                          color: colorText,
                          child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.yellow[700],
                                  borderRadius: BorderRadius.circular(25.0)),
                              child: Center(
                                child: Icon(Icons.star_border_purple500_sharp,
                                    color: colorPrimary, size: 17),
                              )),
                        )
                      ],
                    ),
                  ),
              ],
            )
          : SizedBox(
              width: 0,
            ),
    );
  }
}

class ViewerProduct extends StatefulWidget {
  final int level;
  final int index;
  final List<dynamic> imgUrl;

  const ViewerProduct(
      {required this.index, required this.imgUrl, required this.level});
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Style.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PageView.builder(
          itemCount: widget.imgUrl.length,
          controller: controller,
          itemBuilder: (context, index) {
            return Center(
              child: buildImageInCachedNetworkSimpleWithSizeAuto(
                  "${ConsumeAPI.AssetProductServer}${widget.imgUrl[index]}",
                  BoxFit.contain),
            );
          }),
    );
  }
}
