import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shouz/Constant/PageIndicatorSecond.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../Constant/helper.dart';
import '../Constant/widget_common.dart';
import '../MenuDrawler.dart';
import 'Login.dart';
import 'comment_actu.dart';

class DetailsActu extends StatefulWidget {
  int comeBack;
  String title;
  String id;
  var comment;
  var numberVue;
  var autherName;
  var authorProfil;
  var imageCover;
  var content;

  DetailsActu(
      {required this.title,
      required this.id,
      required this.comeBack,
      this.autherName,
      this.authorProfil,
      this.comment,
      this.content,
      this.imageCover,
      this.numberVue});

  @override
  _DetailsActuState createState() => _DetailsActuState();
}

class _DetailsActuState extends State<DetailsActu> {
  int _currentItem = 0;
  bool lastPage = false, favorite = false, error = false;
  ConsumeAPI consumeAPI = new ConsumeAPI();
  User? user;

  late PageController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = PageController(initialPage: _currentItem);
    LoadInfo();
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  LoadInfo() async {
    try {
      final User newClient = await DBProvider.db.getClient();
      if (newClient.numero != 'null') {
        final result = await consumeAPI.verifyIfExistItemInFavor(widget.id, 0);
        await consumeAPI.addView(newClient.ident, widget.id);
        setState(() {
          favorite = result;
          user = newClient;
        });
      }
    } catch (e) {
      setState(() {
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PageView.builder(
            itemCount: widget.content.length + 1,
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentItem = index;
              });
              if (_currentItem == widget.content.length)
                lastPage = true;
              else
                lastPage = false;
            },
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: <Widget>[
                      buildImageInCachedNetworkWithSizeManual(widget.imageCover,
                          double.infinity, double.infinity, BoxFit.cover),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 700,
                          child: Container(
                            padding: EdgeInsets.all(30.0),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                  const Color(0x00000000),
                                  const Color(0x99111111),
                                ],
                                    begin: FractionalOffset(0.0, 0.0),
                                    end: FractionalOffset(0.0, 1.0))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(widget.title, style: Style.titre(25.0)),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.4),
                                  child: Divider(
                                      color: Colors.white, height: 10.0),
                                ),
                                Text(widget.autherName,
                                    style: Style.sousTitre(14.0)),
                              ],
                            ),
                          ))
                    ],
                  ),
                );
              } else {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        var page = widget.content[index - 1];
                        var delta;
                        double y = 1.0;

                        if (_controller.position.haveDimensions) {
                          delta = _controller.page! -
                              double.parse(index.toString());
                          y = 1 -
                              double.parse(
                                  delta.abs().clamp(0.0, 1.0).toString());
                        }
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(
                            top: 43,
                            bottom: 100,
                            left: 10,
                            right: 10,
                          ),
                          child: choiceDisposition(page, y),
                        );
                      },
                    )
                  ],
                );
              }
            },
          ),
          if (lastPage && !error)
            Positioned(
                right: 30.0,
                bottom: 30.0,
                child: FloatingActionButton(
                  backgroundColor: colorText,
                  child: badges.Badge(
                    position: badges.BadgePosition.topEnd(top: -23, end: -15),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: colorPrimary,
                    ),
                    badgeContent: Text(
                      widget.comment.length.toString(),
                      style: TextStyle(color: backgroundColor),
                    ),
                    showBadge: widget.comment.length > 0,
                    child: Icon(
                      Icons.message,
                      color: colorPrimary,
                      size: 22.0,
                    ),
                  ),
                  onPressed: () async {
                    if (user != null) {
                      Navigator.of(context).push((MaterialPageRoute(
                          builder: (context) => CommentActu(
                                id: widget.id,
                                title: widget.title,
                                comment: widget.comment,
                                imageCover: widget.imageCover,
                                key: UniqueKey(),
                              ))));
                    } else {
                      await modalForExplain(
                          "${ConsumeAPI.AssetPublicServer}ready_station.svg",
                          "Pour avoir accès à ce service il est impératif que vous créez un compte ou que vous vous connectiez",
                          context,
                          true);
                      Navigator.pushNamed(context, Login.rootName);
                    }
                  },
                ))
        ],
      ),
      bottomNavigationBar: Material(
        color: backgroundColor,
        elevation: 15.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {
                    if (widget.comeBack == 0) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushNamed(context, MenuDrawler.rootName);
                    }
                  },
                  color: Colors.white,
                ),
              ),
              Expanded(
                flex: 6,
                child: PageIndicatorSecond(
                    _currentItem, widget.content.length + 1),
              ),
              Expanded(
                  flex: 3,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.favorite),
                        onPressed: () async {
                          if (user != null) {
                            setState(() {
                              favorite = !favorite;
                            });
                            await consumeAPI.addOrRemoveItemInFavorite(
                                widget.id, 0);
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
                        color: favorite ? colorError : Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Style.social_normal),
                        onPressed: () {
                          Share.share(
                              "${widget.title}\n\n Clique ici pour voir l'information que je te partage ${ConsumeAPI.NewsLink}${widget.id}");
                        },
                        color: Colors.white,
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget choiceDisposition(page, double y) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (page['inImage'] != '')
            Material(
              elevation: 25.0,
              borderRadius: BorderRadius.circular(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: CachedNetworkImage(
                  imageUrl: page['inImage'],
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress)),
                  errorWidget: (context, url, error) => notSignal(),
                ),
              ),
            ),
          if (page['inTitle'] != '')
            Padding(
              padding: const EdgeInsets.only(top: 27.0),
              child: GradientText(
                page['inTitle'],
                colors: gradient[1],
                style: Style.titleNews(),
              ),
            ),
          if (page['inTitle'] != '') SizedBox(height: 20.0),
          Transform(
            transform: Matrix4.translationValues(0.0, 50 * (1 - y), 0.0),
            child: Text(
              page['inContent'],
              style: Style.simpleTextOnNews(),
            ),
          ),
        ]);
  }
}
