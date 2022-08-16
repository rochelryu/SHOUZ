import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

String reformatTimerForDisplayOnChrono(int time) {
  final minute = (time / 60).floor();
  final second = (time % 60);
  return "${minute.toString().length>1 ? minute.toString():'0${minute.toString()}' }:${second.toString().length>1 ? second.toString():'0${second.toString()}' }";
}
double defaultLatitude = 5.4143249;
double defaultLongitude = -3.9770197;

String descriptionShouz = '''1 - Achete tout au plus bas prix possible en plus on te livre, c’est satisfait ou remboursé.\n2 - Vends tout article déplaçable sans frais et bénéficie d’une boutique spéciale à ton nom.\n3 - Participe aux évènements qui t’intéressent avec la possibilité de partager tes tickets à tes amis. \n4 - Crée tes propres évènements dans SHOUZ EVENT et vend tes tickets, nous nous occupons de la sécurité des achats et de la vérification des tickets.\n5 - Voyage à tout moment de ville en ville dans une voiture personnel en toute sécurité et avec un prix plus bas.\n6 - Tu es propriétaire d’un véhicule, tu veux voyager mais pas seul ? Avec SHOUZ COVOITURAGE gagne de l’argent en vendant des places de voyage.\n7 - Laissez-vous suivre par les actualités qui vous intéressent, nous vous donnerons aussi des offres d’emploi et appel d’offres selon vos centres d’intérêt.\n https://www.shouz.network
''';

String oneSignalAppId = "482dc96b-bccc-4945-b55d-0f22eed6fd63";

String formatedDateForLocal(DateTime date) {
  initializeDateFormatting();
  var formatDate = DateFormat("yyyy-MM-dd' à 'HH:mm");
  return formatDate.format(date);
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


//CLASS

class SalesData {
  SalesData(this.year, this.sales);
  final DateTime year;
  final List<double> sales;
}

class ChartDataForDonut {
  ChartDataForDonut(this.x, this.y, this.color);

  final String x;
  final double y;
  final Color color;
}