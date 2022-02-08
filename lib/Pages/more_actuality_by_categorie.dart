import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shouz/Constant/CardTopNewActu.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';

class MoreActualityByCategorie extends StatefulWidget {
  String categorieName;
  String categorieId;
  MoreActualityByCategorie({required Key key, required this.categorieId, required this.categorieName}) : super(key: key);

  @override
  _MoreActualityByCategorieState createState() =>
      _MoreActualityByCategorieState();
}

class _MoreActualityByCategorieState extends State<MoreActualityByCategorie> {
  int limit = 15;
  int numberScrollEnd = 1;
  List<dynamic> actualitiesFull = [];
  ScrollController _scrollController = new ScrollController();
  bool loadingFull = true, loadMinim =false;
  ConsumeAPI consumeAPI = new ConsumeAPI();

  @override
  void initState() {
    super.initState();
    LoadInfo();
    _scrollController.addListener(() async {
      if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && !loadMinim) {
        await LoadInfo();
      }
    });

  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  LoadInfo() async {
    if(loadingFull){
      final data = await consumeAPI.getActualitiesByCategorieId(widget.categorieId, limit*numberScrollEnd);
      setState(() {
        actualitiesFull = data;
        loadingFull = false;
      });
    } else {
      setState(() {
        loadMinim = true;
        numberScrollEnd++;
      });
      final data = await consumeAPI.getActualitiesByCategorieId(widget.categorieId, limit*numberScrollEnd);
      setState(() {
        actualitiesFull = data;
        loadMinim = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: backgroundColor,
          title: Text(widget.categorieName),
        ),
        body: LayoutBuilder(builder: (context,contraints) {
          if(loadingFull){
            return Center(child: Container(
              height: 70,
              width: 70,
              child: LoadingIndicator(indicatorType: Indicator.ballRotateChase,colors: [colorText], strokeWidth: 2),
            ));
          } else {
            return  Stack(
              children: [
                ListView.separated(
                    controller: _scrollController,
                    itemCount: actualitiesFull.length,
                    separatorBuilder: (context, index) {
                      return Padding(padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10), child: Divider(height: 1, color: colorSecondary,),);
                    },
                    itemBuilder: (context, index) {
                      final value = actualitiesFull[index];
                      return Container(
                        height: 300,
                        child: CardTopNewActu(
                            value['title'],
                            value['_id'],
                            value['imageCover'],
                            value['numberVue'],
                            value['registerDate'],
                            value['autherName'],
                            value['authorProfil'],
                            value['content'],
                            value['comment'],
                            value['imageCover'])
                            .propotypingScrol(context),
                      );
                    }
                ),
                if(loadMinim)...[
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                          ),
                          child: LoadingIndicator(indicatorType: Indicator.ballRotateChase,colors: [colorText], strokeWidth: 2),
                        ),
                      ))
                ]
              ],
            );
          }
        }) ,
    );
  }
}