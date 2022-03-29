import 'dart:async';


import 'package:flutter/material.dart';
import 'package:shouz/Constant/Style.dart';
import 'package:shouz/MenuDrawler.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:timeline_tile/timeline_tile.dart';

class CreateTravel extends StatefulWidget {
  static String rootName = '/createTravel';
  CreateTravel({required Key key}) : super(key: key);

  @override
  _CreateTravelState createState() => _CreateTravelState();
}

class _CreateTravelState extends State<CreateTravel> {
  DateTime? dateChoice;
  late DateTime date = new DateTime.now();
  late TimeOfDay time = new TimeOfDay.now();
  final formKey = new GlobalKey<FormState>();
  final ConsumeAPI consumeAPI = new ConsumeAPI();

  String beginCity = "";

  TextEditingController beginCityCtrl = new TextEditingController();
  String lieuRencontre = "";
  TextEditingController lieuRencontreCtrl = new TextEditingController();
  String endCity = "";
  TextEditingController endCityCtrl = new TextEditingController();
  String price = "";
  TextEditingController priceCtrl = new TextEditingController();
  bool _isBeginCity = true;
  bool _isPrice = false;
  bool _isRencontre = false;
  bool _isEndCity = false;
  bool _isLoading = false;

  Future<Null> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: new DateTime(new DateTime.now().year),
        lastDate: new DateTime(new DateTime.now().year + 2));
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
      selectTime(context);
    }
  }

  Future<Null> selectTime(BuildContext context) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: time);

    if (picked != null && picked != time) {
      setState(() {
        time = picked;
        dateChoice = new DateTime(
            date.year, date.month, date.day, time.hour, time.minute);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  void dispose() {
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    var loginBtn = Padding(
      padding: EdgeInsets.only(top: 15),
      child: ElevatedButton(
        onPressed: _submit,
        child: new Text(
          "Enregistrer ce voyage",
          style: Style.sousTitreEvent(15),
        ),
        style: raisedButtonStyle,
      ),
    );
    var loginForm = new Column(
      children: <Widget>[
        new Form(
          key: formKey,
          child: new Column(
            children: <Widget>[


              TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.1,
                isFirst: true,
                indicatorStyle: IndicatorStyle(
                  width: 20,
                  color: colorTextShadow,
                ),
                beforeLineStyle: LineStyle(
                  color: colorText,
                  thickness: 6,
                ),
                endChild: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.transparent,
                    elevation: _isBeginCity ? 4.0 : 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0)),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(

                          color: backgroundColorSec,
                          border: Border.all(
                              width: 1.0,
                              color: _isBeginCity
                                  ? colorText
                                  : backgroundColor),
                          borderRadius: BorderRadius.circular(50.0)),
                      child: new TextField(
                        controller: beginCityCtrl,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w300),
                        cursorColor: colorText,
                        keyboardType: TextInputType.text,
                        onChanged: (text) {
                          setState(() {
                            _isBeginCity = true;
                            _isPrice = false;
                            _isEndCity = false;
                            _isRencontre = false;
                            _isLoading = false;
                            beginCity = text;
                          });
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.looks_one,
                                color: _isBeginCity ? colorText : Colors.grey),
                            hintText: "Ville de depart",
                            hintStyle: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ),
              ),
              TimelineDivider(
                begin: 0.1,
                end: 0.9,
                thickness: 6,
                color: colorText,
              ),
              TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.9,
                beforeLineStyle: LineStyle(
                  color: colorText,
                  thickness: 6,
                ),
                afterLineStyle: const LineStyle(
                  color: Colors.deepOrange,
                  thickness: 6,
                ),
                indicatorStyle: const IndicatorStyle(
                  width: 20,
                  color: Colors.cyan,
                ),
                startChild: new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        Text(
                            (dateChoice != null)
                                ? dateChoice!.toLocal().toString().substring(
                                0, dateChoice!.toLocal().toString().length - 7)
                                : "Cliquez sur l'icone du calendrier pour choisir la date/heure de votre voyage",
                            style: Style.sousTitre(13)),
                        SizedBox(height: 10),
                        Container(
                          height: 60,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FloatingActionButton(
                                child: Icon(Icons.event_available,
                                    color: Colors.white),
                                onPressed: () {
                                  selectDate(context);
                                },
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: _isPrice ? 4.0 : 0.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0)),
                                  child: Container(
                                    height: 50,
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: backgroundColorSec,
                                        border: Border.all(
                                            width: 1.0,
                                            color: _isPrice
                                                ? colorText
                                                : backgroundColor),
                                        borderRadius: BorderRadius.circular(50.0)),
                                    child: new TextField(
                                      controller: priceCtrl,
                                      style: TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.w300),
                                      cursorColor: colorText,
                                      onChanged: (text) {
                                        setState(() {
                                          _isPrice = true;
                                          _isBeginCity = false;
                                          _isEndCity = false;
                                          _isRencontre = false;
                                          _isLoading = false;
                                          price = text;
                                        });
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: Icon(Icons.looks_two,
                                              color:
                                              _isPrice ? colorText : Colors.grey),
                                          hintText: "Prix des places",
                                          hintStyle: TextStyle(
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                ),)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.9,
                beforeLineStyle: LineStyle(
                  color: Colors.deepOrange,
                  thickness: 6,
                ),
                indicatorStyle: const IndicatorStyle(
                  width: 20,
                  color: Colors.deepOrange,
                ),
                startChild: new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        Text(
                            "Veuillez entrer un lieu de rencontre pour vos clients. Ce lieu peut être choisi en fonction de l'accessibilité pour votre voyage",
                            style: Style.sousTitre(13)),
                        SizedBox(height: 10),
                        Container(
                          height: 60,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[

                              Expanded(
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: _isRencontre ? 4.0 : 0.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0)),
                                  child: Container(
                                    height: 50,
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: backgroundColorSec,
                                        border: Border.all(
                                            width: 1.0,
                                            color: _isRencontre
                                                ? colorText
                                                : backgroundColor),
                                        borderRadius: BorderRadius.circular(50.0)),
                                    child: new TextField(
                                      controller: lieuRencontreCtrl,
                                      style: TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.w300),
                                      cursorColor: colorText,
                                      onChanged: (text) {
                                        setState(() {
                                          _isPrice = false;
                                          _isBeginCity = false;
                                          _isRencontre = true;
                                          _isEndCity = false;
                                          _isLoading = false;
                                          lieuRencontre = text;
                                        });
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          prefixIcon: Icon(Icons.looks_3,
                                              color:
                                              _isPrice ? colorText : Colors.grey),
                                          hintText: "Lieu de rencontre",
                                          hintStyle: TextStyle(
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                ),)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              TimelineDivider(
                begin: 0.1,
                end: 0.9,
                thickness: 6,
                color: Colors.deepOrange,
              ),
              TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.1,
                isLast: true,
                beforeLineStyle: const LineStyle(
                  color: Colors.deepOrange,
                  thickness: 6,
                ),
                indicatorStyle: const IndicatorStyle(
                  width: 20,
                  color: Colors.red,
                ),
                endChild: new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.transparent,
                    elevation: _isEndCity ? 4.0 : 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0)),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: backgroundColorSec,
                          border: Border.all(
                              width: 1.0,
                              color: _isEndCity
                                  ? colorText
                                  : backgroundColor),
                          borderRadius: BorderRadius.circular(50.0)),
                      child: new TextField(
                        controller: endCityCtrl,
                        onChanged: (text) {
                          setState(() {
                            _isEndCity = true;
                            _isBeginCity = false;
                            _isRencontre = false;
                            _isPrice = false;
                            _isLoading = false;

                            endCity = text;
                          });
                        },
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w300),
                        cursorColor: colorText,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.looks_4,
                                color: _isEndCity
                                    ? colorText
                                    : Colors.grey),
                            hintText:
                            "Ville d'arrivé",
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            )),
                      ),
                    ),
                  ),
                ),
              ),



            ],
          ),
        ),
        _isLoading ? new CircularProgressIndicator() : loginBtn
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Créer Un Voyage !",
                          style: Style.secondTitre(22)),
                      SizedBox(height: 10.0),
                      Text("Rémunéré vos voyage,",
                          style: Style.sousTitre(14),
                          textAlign: TextAlign.center),
                      Text("en vendant des places",
                          style: Style.sousTitre(14),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: loginForm,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    formKey.currentState;
    setState(() => _isLoading = true);
    print('$beginCity , $lieuRencontre , ${dateChoice.toString()} , $endCity, $price');
    if (beginCity.length > 2 &&
        lieuRencontre.length > 3 &&
        dateChoice != null &&
        endCity.length > 2 &&
        price.length > 3) {
      final travel = await consumeAPI.setTravel(beginCity, lieuRencontre, dateChoice.toString(), endCity, price);
      setState(() => _isLoading = false);
      if (travel['etat'] == 'found') {
        setState(() {
          dateChoice = null;

          beginCityCtrl.clear();
          lieuRencontreCtrl.clear();
          endCityCtrl.clear();
          priceCtrl.clear();
          beginCity = "";
          lieuRencontre = "";
          endCity = "";
          price = "";
        });
        await askedToLead(
            "Votre voyage est en ligne, vous recevrez des notifications lorsqu'un client achetera une place",
            true, context);
        Navigator.pushNamed(context, MenuDrawler.rootName);
      } else {
        await askedToLead(
            "Echec avec la mise en ligne, veuillez ressayer ulterieurement",
            false, context);
      }
    } else {
      setState(() => _isLoading = false);
      _showSnackBar("Remplissez correctement les champs avant d'envoyer");
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      backgroundColor: colorError,
      content: new Text(
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