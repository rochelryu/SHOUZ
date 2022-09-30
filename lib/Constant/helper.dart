import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:huawei_push/huawei_push.dart' as huawei;
import '../ServicesWorker/ConsumeAPI.dart';
import 'Style.dart';
import 'package:flutter_hms_gms_availability/flutter_hms_gms_availability.dart';
ConsumeAPI consumeAPI = new ConsumeAPI();

const maxAmountOnAccount = 10000000;
const maxAmountOfTransaction = 1000000;
const minAmountOfTransaction = 1000;
const linkAppGalleryForShouz = "https://appgallery.cloud.huawei.com/ag/n/app/C107065691?locale=fr_FR";
const linkPlayStoreForShouz = "https://play.google.com/store/apps/details?id=com.shouz.app";
const linkAppleStoreForShouz = "";

void showSnackBar(BuildContext context, String text) {
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

String reformatTimerForDisplayOnChrono(int time) {
  final minute = (time / 60).floor();
  final second = (time % 60);
  return "${minute.toString().length>1 ? minute.toString():'0${minute.toString()}' }:${second.toString().length>1 ? second.toString():'0${second.toString()}' }";
}

String reformatNumberForDisplayOnPrice(dynamic price) {
  final numberFormated = NumberFormat("#,##0", 'fr_FR');

  return numberFormated.format(price);
}
double defaultLatitude = 5.4143249;
double defaultLongitude = -3.9770197;

String descriptionShouz = '''1 - Achete tout au plus bas prix possible en plus on te livre, c’est satisfait ou remboursé.\n2 - Vends tout article déplaçable sans frais et bénéficie d’une boutique spéciale à ton nom.\n3 - Participe aux évènements qui t’intéressent avec la possibilité de partager tes tickets à tes amis. \n4 - Crée tes propres évènements dans SHOUZ EVENT et vend tes tickets, nous nous occupons de la sécurité des achats et de la vérification des tickets.\n5 - Voyage à tout moment de ville en ville dans une voiture personnel en toute sécurité et avec un prix plus bas.\n6 - Tu es propriétaire d’un véhicule, tu veux voyager mais pas seul ? Avec SHOUZ COVOITURAGE gagne de l’argent en vendant des places de voyage.\n7 - Laissez-vous suivre par les actualités qui vous intéressent, nous vous donnerons aussi des offres d’emploi et appel d’offres selon vos centres d’intérêt.\n https://www.shouz.network
''';

String oneSignalAppId = "482dc96b-bccc-4945-b55d-0f22eed6fd63";

String formatedDateForLocal(DateTime date) {
  initializeDateFormatting();
  var formatDate = DateFormat("dd-MM-yyyy' à 'HH:mm");
  return formatDate.format(date);
}

String formatedDateForLocalWithoutTime(DateTime date) {
  initializeDateFormatting();
  var formatDate = DateFormat("dd MMM yyyy");
  return formatDate.format(date);
}

String mapForDevice(String position) {
  if(Platform.isAndroid) {
    return "https://www.google.com/maps/place/${position.replaceAll(" ", ",")}";
  } else {
    return "https://maps.apple.com/?address=${position.replaceAll(" ", "")}";
  }
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day, from.hour, from.minute);
  to = DateTime(to.year, to.month, to.day, to.hour, to.minute);
  final diff = to.difference(from).inHours / 24;
  print(from.toString());
  print(to.toString());

  print(diff);
  return diff.ceil();
}
Future<bool> isGms() async {
  return await FlutterHmsGmsAvailability.isGmsAvailable;
}

Future<bool> isHms() async {
  return await FlutterHmsGmsAvailability.isHmsAvailable;
}

Future getTokenForNotificationProvider() async {


  if(Platform.isAndroid){
    if(await isHms()) {
      huawei.Push.enableLogger();
      String _token = '';
      String result = await huawei.Push.getId() ?? "";
      huawei.Push.getToken("");
      //print('Huawei push token ::  ${huawei.HosNotificationHelper.token} ');
      huawei.Push.getTokenStream.listen((String event) {
        _token = event;
        print("_token ------------, $_token");
      }, onError: (dynamic error) {
        print(error.message);
      });

      huawei.Push.getToken("");

      print('Huawei push token ::  $_token, $result');

    } else {
      final fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
      final prefs = await SharedPreferences.getInstance();
      final String tokenNotification = prefs.getString('tokenNotification') ?? "";
      if(tokenNotification != fcmToken.trim() && fcmToken.trim() != "") {
        final infoSaveToken = await consumeAPI.updateTokenVerification(fcmToken.trim(), "firebase");
        if(infoSaveToken['etat'] == "found") {
          await prefs.setString('tokenNotification', fcmToken.trim());
        }
      }

    }
  } else {
    final fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
    final prefs = await SharedPreferences.getInstance();
    final String tokenNotification = prefs.getString('tokenNotification') ?? "";
    if(tokenNotification != fcmToken.trim() && fcmToken.trim() != "") {
      final infoSaveToken = await consumeAPI.updateTokenVerification(fcmToken.trim(), "firebase");
      if(infoSaveToken['etat'] == "found") {
        await prefs.setString('tokenNotification', fcmToken.trim());
      }
    }

  }
}


//CLASS

class ChartDataLine {
  ChartDataLine(String date, List<dynamic> dataWithoutFilter) {
    final dateSplit = date.split('-');
    this.dateTime = DateTime(int.parse(dateSplit[0]),int.parse(dateSplit[1]),int.parse(dateSplit[2]));
    this.data = dataWithoutFilter.map((item) => item['count'] as int).toList();

  }
  late DateTime dateTime;
  late List<int> data;
}

class PieSeriesData {
  PieSeriesData(this.x, this.y, this.color);

  final String x;
  final int y;
  final Color color;
}

class TableDataStats {
  TableDataStats(String name, String images, String typeTicket, int priceTicket, int placeTotal, String registerDate) {

    this.registerDate = formatedDateForLocal(DateTime.parse(registerDate));
    this.name = name.trim();
    this.typeTicket = typeTicket.trim();
    this.placeTotal = placeTotal;
    this.priceTicket = priceTicket;
    this.images = "${ConsumeAPI.AssetProfilServer}$images";
  }
  late String name;
  late String images;
  late String typeTicket;
  late int placeTotal;
  late int priceTicket;
  late String registerDate;
}

class DataSourceBuyer extends DataTableSource {

  late List<dynamic> _data;
  DataSourceBuyer({required List<dynamic> data}) {
    _data = data;
  }

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
                image: NetworkImage(_data[index].images),
                fit: BoxFit.cover
            )
        ),
      )),
      DataCell(Text(_data[index].name, style: Style.sousTitre(12),)),
      DataCell(Text(_data[index].priceTicket.toString(), style: Style.priceDealsProduct(),)),
      DataCell(Text(_data[index].placeTotal.toString(), style: Style.priceDealsProduct(),)),
      DataCell(Text("Ticket ${_data[index].typeTicket}", style: Style.sousTitre(12),)),
      DataCell(Text(_data[index].registerDate, style: Style.sousTitre(12),)),
    ]);
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => _data.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
  
}

class DataSourceRemover extends DataTableSource {

  late List<dynamic> _data;
  DataSourceRemover({required List<dynamic> data}) {
    _data = data;
  }

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
                image: NetworkImage(_data[index].images),
                fit: BoxFit.cover
            )
        ),
      )),
      DataCell(Text(_data[index].name, style: Style.sousTitre(12),)),
      DataCell(Text(_data[index].priceTicket.toString(), style: Style.priceDealsProduct(),)),
      DataCell(Text(_data[index].commission.toString(), style: Style.priceDealsProduct(),)),
      DataCell(Text("Ticket ${_data[index].typeTicket}", style: Style.sousTitre(12),)),
      DataCell(Text(_data[index].registerDate, style: Style.sousTitre(12),)),
    ]);
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => _data.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;

}

class TableDataStatsForRemoved {
  TableDataStatsForRemoved(String name, String images, String typeTicket, int priceTicket, int commission, String registerDate) {

    this.registerDate = formatedDateForLocal(DateTime.parse(registerDate));
    this.name = name.trim();
    this.typeTicket = typeTicket.trim();
    this.commission = commission;
    this.priceTicket = priceTicket;
    this.images = "${ConsumeAPI.AssetProfilServer}$images";
  }
  late String name;
  late String images;
  late String typeTicket;
  late int commission;
  late int priceTicket;
  late String registerDate;
}
