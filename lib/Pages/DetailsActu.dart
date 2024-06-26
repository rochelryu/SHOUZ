import 'package:flutter/material.dart';
import 'package:gradient_text/gradient_text.dart';
import 'package:shouz/Constant/PageIndicatorSecond.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/Models/User.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';

import 'comment_actu.dart';

class DetailsActu extends StatefulWidget {
  String title;
  String id;
  var comment;
  var numberVue;
  var autherName;
  var authorProfil;
  var imageCover;
  var content;

  DetailsActu(
      {this.title,
      this.id,
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
  bool lastPage = false;
  bool favorite = false;

  PageController _controller;

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
    User newClient = await DBProvider.db.getClient();
    final result = await new ConsumeAPI().verifyIfExistItemInFavor(widget.id, 0);
    final etat = await new ConsumeAPI().addView(newClient.ident, widget.id);
    print(etat);
    setState(() {
      favorite = result;
    });

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
                      Container(
                        height: double.infinity,
                        width: double.infinity,
                        child:
                            Image.network(widget.imageCover, fit: BoxFit.cover),
                      ),
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
                        var y = 1.0;

                        if (_controller.position.haveDimensions) {
                          delta = _controller.page - index;
                          y = 1 - delta.abs().clamp(0.0, 1.0);
                        }
                        return new SingleChildScrollView(
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
          Positioned(
            right: 30.0,
            bottom: 30.0,
            child: lastPage
                ? FloatingActionButton(
                    backgroundColor: colorText,
                    child: Icon(
                      Icons.message,
                      color: colorPrimary,
                      size: 22.0,
                    ),
                    onPressed: () {
                      Navigator.of(context).push((MaterialPageRoute(
                          builder: (context) => CommentActu(id: widget.id, title: widget.title,comment: widget.comment, imageCover: widget.imageCover))));
                    },
                  )
                : Container(),
          )
        ],
      ),
      bottomNavigationBar: new Material(
        color: backgroundColor,
        elevation: 15.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {
                    Navigator.pop(context);
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
                        onPressed: () {
                          setState(() {
                            favorite = !favorite;
                          });
                        },
                        color: favorite ? colorError : Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Style.social_normal),
                        onPressed: () {
                          Navigator.pop(context);
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
    switch (page['isContentType']) {
      case 'only_text':
        return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Transform(
                transform: Matrix4.translationValues(0.0, 50 * (1 - y), 0.0),
                child: Text(
                  page['inContent'],
                  style: Style.simpleTextOnNews(),
                ),
              ),
            ]);
      case 'picture_text':
        return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Material(
                elevation: 25.0,
                borderRadius: BorderRadius.circular(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Image.network(page['inImage']),
                ),
              ),
              SizedBox(height: 18.0),
              Transform(
                transform: Matrix4.translationValues(0.0, 50 * (1 - y), 0.0),
                child: Text(
                  page['inContent'],
                  style: Style.simpleTextOnNews(),
                ),
              ),
            ]);
        break;
      case 'subtitle_text':
        return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 27.0),
                child: GradientText(
                  page['inTitle'],
                  textAlign: TextAlign.center,
                  gradient: LinearGradient(
                      colors: [Color(0xFF9708CC), Color(0xFF43CBFF)]),
                  style: Style.titleNews(),
                ),
              ),
              SizedBox(height: 20.0),
              Transform(
                transform: Matrix4.translationValues(0.0, 50 * (1 - y), 0.0),
                child: Text(
                  page['inContent'],
                  style: Style.simpleTextOnNews(),
                ),
              ),
            ]);

        break;
      case 'only_picture':
        return new Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(page['inImage']), fit: BoxFit.cover)),
        );
        break;
      default:
        return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
}
