import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shouz/Utils/Database.dart';

Color colorOne = tint;
Color colorTwo = backgroundColorSec;
Color colorThree = colorText;
enum TypePayement { trovaExchange, bitcoin, ethereum }

/*final indicatorList = [
  BallPulseIndicator(),
  BallBeatIndicator(),
  BallGridPulseIndicator(),
  BallScaleIndicator(),
  BallScaleMultipleIndicator(),
  BallSpinFadeLoaderIndicator(),
  LineScaleIndicator(),
  LineScalePartyIndicator(),
  LineScalePulseOutIndicator(),
];*/
final appTheme = ThemeData(
  primarySwatch: backgroundColor,
);
bool primaryTheme = true;
final Color backgroundColor =
    (!primaryTheme) ? Colors.white : Color(0xFF2d3447);
final Color backgroundColorSec = Color(0xFF4A4A58);
final Color tint = Color(0xFF4A4A65);
final Color colorText = Color(0xFF0288D1);
final Color colorTextShadow = Color(0xFF2979FF);
final Color colorError = Color(0xFFB71C1C);
final Color colorWarning = Color(0xFFDEB31C);
final Color colorSuccess = Color(0xFF4CAF50);
final Color colorPrimary = /*(!primaryTheme)? Colors.black87: */ Colors.white;
final Color colorSecondary = Colors.grey;
final Color colorWelcome = Colors.white70;
final Color secondColor =
    (!primaryTheme) ? Color(0xFFFFFFFF) : Color(0xFFFFFFFF);
final transitionMedium = new Duration(milliseconds: 400);
final transitionLong = new Duration(milliseconds: 800);
final transitionSuperLong = new Duration(milliseconds: 1200);

class DealsSkeletonData {
  List<dynamic> imageUrl;
  var title;
  var favorite;
  var price;
  var numero;
  var autor;
  var authorName;
  var describe;
  var numberFavorite;
  var quantity;
  var lieu;
  var registerDate;
  var id;
  var profil;
  var onLine;
  //List<String> PersonneLike = [];
  DealsSkeletonData(
      {this.imageUrl,
      this.title,
      this.favorite,
      this.price,
      this.numero,
      this.autor,
      this.describe,
      this.numberFavorite,
      this.lieu,
      this.registerDate,
      this.id,
      this.profil,
      this.quantity,
      this.onLine, this.authorName});
}

List atMoment = [
  {
    "author": mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
    "name": "Ryu",
    "verbe": "vous a écrit",
    "complement": "pour un deals",
    "product": "Nike au revoir",
    "productImage":
        mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
  },
  {
    "author": mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
    "name": "Ryu",
    "verbe": "vous a écrit",
    "complement": "pour un deals",
    "product": "Nike au revoir",
    "productImage":
        mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
  },
  {
    "author": mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
    "name": "Ryu",
    "verbe": "vous a écrit",
    "complement": "pour un deals",
    "product": "Nike au revoir",
    "productImage":
        mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
  },
];

List atSemaine = [
  {
    "author": mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
    "name": "Ryu",
    "verbe": "vous a écrit",
    "complement": "pour un deals",
    "product": "Nike au revoir",
    "productImage":
        mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
  },
  {
    "author": mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
    "name": "Ryu",
    "verbe": "vous a écrit",
    "complement": "pour un deals",
    "product": "Nike au revoir",
    "productImage":
        mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
  },
  {
    "author": mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
    "name": "Ryu",
    "verbe": "vous a écrit",
    "complement": "pour un deals",
    "product": "Nike au revoir",
    "productImage":
        mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
  },
];

List atMois = [
  {
    "author": mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
    "name": "Ryu",
    "verbe": "vous a écrit",
    "complement": "pour un deals",
    "product": "Nike au revoir",
    "productImage":
        mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
  },
  {
    "author": mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
    "name": "Ryu",
    "verbe": "vous a écrit",
    "complement": "pour un deals",
    "product": "Nike au revoir",
    "productImage":
        mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
  },
  {
    "author": mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
    "name": "Ryu",
    "verbe": "vous a écrit",
    "complement": "pour un deals",
    "product": "Nike au revoir",
    "productImage":
        mesUsersLocal[new Random().nextInt(mesUsersLocal.length - 1)],
  },
];
List<String> mesUsers = [
  "https://image.freepik.com/photos-gratuite/femme-tailleur-travaillant-usine-couture_1303-15841.jpg",
  "https://image.freepik.com/vecteurs-libre/pensee-intelligence-artificielle-dans-tete-humanoide-reseau-neurones-ia-cerveau-numerique_119244-52.jpg",
  "https://image.freepik.com/psd-gratuit/modele-vente-banniere-coloree_1393-167.jpg",
  "https://image.freepik.com/vecteurs-libre/illustration-maman-drole-faisant-mouvement-limande_102811-35.jpg",
  "https://image.freepik.com/photos-gratuite/gens-heureux-dansent-dans-concert-discotheque_31965-606.jpg",
  "https://image.freepik.com/vecteurs-libre/modele-affiche-evenement-musique-formes-abstraites_1361-1316.jpg",
  "https://image.freepik.com/vecteurs-libre/modele-affiche-evenement-beaute_1361-1225.jpg"
];
List<String> prices = ["Gratuit", "5000 F cfa", "15000 F cfa"];
List<String> mesUsersLocal = [
  "images/actu.png",
  "images/l.jpg",
  "images/l2.jpg",
  "images/noter.png",
  "images/publi.png",
  "images/ryu.jpg",
  "images/ryuotaKise.jpg",
  "images/secondvoyage.png"
];

var dealsList = [
  DealsModel(
      imageUrl: "images/l.jpg",
      title: "Nike Au revoir",
      favorite: false,
      price: 35000,
      numero: "48803377",
      autor: "images/me.jpg",
      registerDate: "il y 6 heures"),
  DealsModel(
      imageUrl: "images/l2.jpg",
      title: "Nike Au revoir",
      favorite: false,
      price: 25000,
      numero: "48803377",
      autor: "images/l2.jpg",
      registerDate: "il y 8 heures"),
  DealsModel(
      imageUrl: "images/me.jpg",
      title: "Nike Au revoir",
      favorite: true,
      price: 15000,
      numero: "48803377",
      autor: "images/l.jpg",
      registerDate: "il y 12 heures"),
  DealsModel(
      imageUrl: "images/ryotaFluid.jpg",
      title: "Nike Au revoir",
      favorite: true,
      price: 5000,
      numero: "48803377",
      autor: "images/ryotaFluid.jpg",
      registerDate: "il y 16 heures"),
  DealsModel(
      imageUrl: "images/ryuotaKise.jpg",
      title: "Nike Au revoir",
      favorite: true,
      price: 1000,
      numero: "48803377",
      autor: "images/ryuotaKise.jpg",
      registerDate: "il y 18 heures"),
  DealsModel(
      imageUrl: "images/soulE.jpg",
      title: "Nike Au revoir",
      favorite: false,
      price: 3000,
      numero: "48803377",
      autor: "images/soulE.jpg",
      registerDate: "hier à 09h15"),
];
var pageList = [
  PageModel(
      imageUrl: "images/actu.png",
      title: "ACTUALITES",
      body: "Suiver l'actualité d'ici et d'ailleur",
      titleGradient: gradient[0]),
  PageModel(
      imageUrl: "images/deals.png",
      title: "DEALS",
      body:
          "Vendez et/ou achetez sans frais et même avec des bons de reduction",
      titleGradient: gradient[1]),
  PageModel(
      imageUrl: "images/event.png",
      title: "EVENEMENTS",
      body: "Suivez des évènements ou partagez vos évènements",
      titleGradient: gradient[2]),
  PageModel(
      imageUrl: "images/voyage.png",
      title: "VOYAGES",
      body: "Le covoiturage simplifie vos trajets",
      titleGradient: gradient[3]),
  PageModel(
      imageUrl: "images/publi.png",
      title: "PUBLICITES",
      body: "Touchez une large audience de par votre publicité",
      titleGradient: gradient[4]),
  PageModel(
      imageUrl: "images/choice.png",
      title: "PREFERENCE",
      body: "Et tout ça selon vos préférences.",
      titleGradient: gradient[5]),
];

List<List<Color>> gradient = [
  [Color(0xFF9CCC64), Color(0xFF33691E)],
  [Color(0xFFE2859F), Color(0xFFFCCF31)],
  [Color(0xFF5EFCE8), Color(0xFF736EFE)],
  [Color(0xFFFFCDD2), Color(0xFFFF1744)],
  [Color(0xFF9708CC), Color(0xFF43CBFF)],
  [backgroundColorSec, backgroundColor],
];

class PageModel {
  var imageUrl;
  var title;
  var body;
  List<Color> titleGradient = [];
  PageModel({this.imageUrl, this.title, this.body, this.titleGradient});
}

class DealsModel {
  var imageUrl;
  var title;
  var favorite;
  var price;
  var numero;
  var autor;
  var registerDate;
  List<String> PersonneLike = [];
  DealsModel(
      {this.imageUrl,
      this.title,
      this.favorite,
      this.price,
      this.numero,
      this.PersonneLike,
      this.autor,
      this.registerDate});
}

class VoyageModel {
  var id;
  var imageUrl;
  var origin;
  var chauffeur;
  var chauffeurName;
  var price;
  var levelName;
  var numberTravel;
  var nextLevel;
  var detination;
  int placeTotal;
  List<dynamic> placeDisponible = [];
  List<dynamic> hobiesCovoiturage = [];
  var dateVoyage;
  //List<String> PersonneLike = [];
  VoyageModel(
      {this.imageUrl,
      this.origin,
      this.chauffeur,
      this.price,
      this.detination,
      this.placeTotal,
      this.placeDisponible,
      this.dateVoyage,
      this.chauffeurName,
      this.id,
      this.levelName,
      this.nextLevel,
      this.numberTravel,
      this.hobiesCovoiturage});
}

class ImageArround extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: min(size.width, size.height) / 2,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}

class Style {
  Widget widget;
  Style(this.widget);

  static const Color colorPrimary = Color.fromARGB(255, 255, 255, 255);
  static const Color colorPrimaryDark = Color.fromARGB(255, 41, 41, 41);
  static const Color colorAccent = Color.fromARGB(255, 30, 198, 89);
  static const Color yellow = Color.fromARGB(255, 252, 163, 38);
  static const Color orange = Color.fromARGB(255, 252, 109, 38);
  static const Color grey_unselected = Color.fromARGB(255, 96, 96, 96);
  static const Color white_card = Color.fromARGB(255, 250, 250, 250);
  static const Color chrome_grey = Color.fromARGB(255, 240, 240, 240);
  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color white_secondary = Color.fromARGB(255, 220, 220, 220);
  static const Color white_un_selected = Color.fromARGB(255, 180, 180, 180);
  static const Color indigo = Color.fromARGB(255, 51, 105, 231);
  static const Color primary_text = Color.fromARGB(255, 51, 51, 51);
  static const Color secondary_text = Color.fromARGB(255, 114, 114, 114);
  static const Color grey = Color.fromARGB(255, 188, 187, 187);

  static const _kFontFam = 'MyFlutterApp';

  static const IconData menu_outline =
      const IconData(0xe800, fontFamily: _kFontFam);
  static const IconData menu = const IconData(0xe801, fontFamily: _kFontFam);
  static const IconData chatting =
      const IconData(0xe802, fontFamily: _kFontFam);
  static const IconData mobile_phone =
      const IconData(0xe803, fontFamily: _kFontFam);
  static const IconData social_normal =
      const IconData(0xe804, fontFamily: _kFontFam);
  static const IconData undraw_adventure_4hum =
      const IconData(0xe805, fontFamily: _kFontFam);
  static const IconData undraw_at_the_park_2e47 =
      const IconData(0xe806, fontFamily: _kFontFam);
  static const IconData undraw_booked_j7rj =
      const IconData(0xe807, fontFamily: _kFontFam);
  static const IconData undraw_business_shop_qw5t =
      const IconData(0xe808, fontFamily: _kFontFam);
  static const IconData undraw_city_driver_jh2h =
      const IconData(0xe809, fontFamily: _kFontFam);
  static const IconData undraw_conference_uo36 =
      const IconData(0xe80a, fontFamily: _kFontFam);
  static const IconData undraw_connected_world_wuay =
      const IconData(0xe80b, fontFamily: _kFontFam);
  static const IconData undraw_detailed_information_3sp6 =
      const IconData(0xe80c, fontFamily: _kFontFam);
  static const IconData undraw_developer_activity_bv83 =
      const IconData(0xe80d, fontFamily: _kFontFam);
  static const IconData undraw_fast_loading_0lbh =
      const IconData(0xe80e, fontFamily: _kFontFam);
  static const IconData undraw_feedback_h2ft =
      const IconData(0xe80f, fontFamily: _kFontFam);
  static const IconData undraw_female_avatar_l3ey =
      const IconData(0xe810, fontFamily: _kFontFam);
  static const IconData undraw_functions_egi3 =
      const IconData(0xe811, fontFamily: _kFontFam);
  static const IconData undraw_goals_w8tw =
      const IconData(0xe812, fontFamily: _kFontFam);
  static const IconData undraw_hologram_fjwp =
      const IconData(0xe813, fontFamily: _kFontFam);
  static const IconData undraw_ideas_s70l =
      const IconData(0xe814, fontFamily: _kFontFam);
  static const IconData undraw_male_avatar_323b =
      const IconData(0xe815, fontFamily: _kFontFam);
  static const IconData undraw_newspaper_k72w =
      const IconData(0xe816, fontFamily: _kFontFam);
  static const IconData undraw_online_art_bgb4 =
      const IconData(0xe817, fontFamily: _kFontFam);
  static const IconData undraw_people_tax5 =
      const IconData(0xe818, fontFamily: _kFontFam);
  static const IconData undraw_react_y7wq =
      const IconData(0xe819, fontFamily: _kFontFam);
  static const IconData undraw_schedule_pnbk =
      const IconData(0xe81a, fontFamily: _kFontFam);
  static const IconData undraw_selection_92i4 =
      const IconData(0xe81b, fontFamily: _kFontFam);
  static const IconData undraw_sunlight_tn7t =
      const IconData(0xe81c, fontFamily: _kFontFam);
  static const IconData undraw_transfer_money_rywa =
      const IconData(0xe81d, fontFamily: _kFontFam);
  static const IconData undraw_travelers_qlt1 =
      const IconData(0xe81e, fontFamily: _kFontFam);
  static const IconData undraw_walk_dreaming_u58a =
      const IconData(0xe81f, fontFamily: _kFontFam);
  static const IconData undraw_wandering_mind_0mkm =
      const IconData(0xe820, fontFamily: _kFontFam);
  static const IconData undraw_web_developer_p3e5 =
      const IconData(0xe821, fontFamily: _kFontFam);
  static const IconData undraw_winners_ao2o =
      const IconData(0xe822, fontFamily: _kFontFam);
  static const IconData undraw_invest_88iw =
      const IconData(0xe823, fontFamily: _kFontFam);

  static dynamic menuStyleItem(double size) {
    return TextStyle(
        color: secondColor,
        fontSize: size,
        fontWeight: FontWeight.w600,
        fontFamily: "Montserrat");
  }

  static dynamic grandTitre(double size) {
    return TextStyle(
        color: secondColor,
        fontSize: size,
        fontWeight: FontWeight.w600,
        fontFamily: "LexendExa");
  }

  static dynamic grandTitreBlack(double size) {
    return TextStyle(
        color: Colors.black,
        fontSize: size,
        fontWeight: FontWeight.w600,
        fontFamily: "LexendExa");
  }

  static dynamic titre(double size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "LexendExa",
      color: secondColor,
    );
  }

  static dynamic secondTitre(double size) {
    return TextStyle(
        fontSize: size,
        fontFamily: "Montserrat-Black",
        color: secondColor,
        letterSpacing: 1.2);
  }

  static dynamic sousTitre(double size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "LexendExa",
      color: colorSecondary,
    );
  }

  static dynamic sousTitreWelcome(double size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "LexendExa",
      color: colorWelcome,
    );
  }

  static dynamic titreEvent(double size) {
    return TextStyle(
      fontSize: size,
      letterSpacing: 1.6,
      fontFamily: "Montserrat-Black",
      color: secondColor,
    );
  }

  static dynamic sousTitreEvent(double size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "LexendExa",
      color: Colors.white60,
    );
  }

  static dynamic warning(double size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "LexendExa",
      color: Colors.red[300],
    );
  }

  static dynamic itemCustomFont() {
    return TextStyle(
      fontSize: 16.0,
      color: secondColor,
      fontWeight: FontWeight.w600,
    );
  }

  static dynamic itemNote() {
    return TextStyle(
      fontSize: 11.0,
      fontFamily: "PTsans",
      color: secondColor,
      fontWeight: FontWeight.w600,
    );
  }

  static dynamic titleOnBoardShadow() {
    return TextStyle(
      fontSize: 46.0,
      fontFamily: "Montserrat-Black",
      letterSpacing: 1.0,
      //fontWeight: FontWeight.w600,
    );
  }

  static dynamic titleOnBoard() {
    return TextStyle(
      fontSize: 35.0,
      fontFamily: "Montserrat-Black",
      letterSpacing: 2.0,
      //fontWeight: FontWeight.w600,
    );
  }

  static dynamic titleNews() {
    return TextStyle(
        fontSize: 18.0,
        fontFamily: "Montserrat-Black",
        letterSpacing: 2.0,
        color: Colors.white
        //fontWeight: FontWeight.w600,
        );
  }

  static dynamic simpleTextOnBoard() {
    return TextStyle(
      fontSize: 17.0,
      fontFamily: "Montserrat-Light",
      color: colorSecondary,
      letterSpacing: 1.1,
      //fontWeight: FontWeight.w600,
    );
  }

  static dynamic simpleTextOnNews() {
    return TextStyle(
      fontSize: 17.0,
      fontFamily: "Montserrat-Light",
      color: colorPrimary,
      letterSpacing: 1.1,
      //fontWeight: FontWeight.w600,
    );
  }

  static dynamic chatIsMe(double size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "Montserrat-Light",
      color: Colors.white,
      fontWeight: (size > 14) ? FontWeight.w400 : FontWeight.normal,
    );
  }

  static dynamic chatOutMe(double size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "Montserrat-Light",
      color: Colors.black,
      fontWeight: (size > 14) ? FontWeight.w400 : FontWeight.normal,
    );
  }

  //Style Of Deals

  static dynamic titleDealsProduct() {
    return TextStyle(
      fontSize: 13.0,
      fontFamily: "Montserrat-Black",
      color: colorPrimary,
      letterSpacing: 1.1,
    );
  }

  static dynamic location() {
    return TextStyle(
      fontSize: 13.0,
      fontFamily: "Montserrat-Light",
      color: colorPrimary,
      letterSpacing: 1.1,
    );
  }

  static dynamic contextNotif([double size = 15.0]) {
    return TextStyle(
      fontSize: size,
      fontFamily: "Montserrat-Light",
      color: colorPrimary,
    );
  }

  static dynamic numberOfLike() {
    return TextStyle(
      fontSize: 14.0,
      fontFamily: "Montserrat-Light",
      color: colorSecondary,
    );
  }

  static dynamic priceDealsProduct() {
    return TextStyle(
      fontSize: 13.0,
      fontFamily: "Montserrat-Light",
      color: colorText,
      letterSpacing: 1.0,
    );
  }

  static dynamic addressCrypto() {
    return TextStyle(
      fontSize: 16.0,
      fontFamily: "Montserrat-Black",
      color: colorText,
      letterSpacing: 1.0,
    );
  }

  static dynamic titleInSegment([double size = 14.0]) {
    return TextStyle(
      fontSize: size,
      fontFamily: "Montserrat-Light",
      color: colorPrimary,
      letterSpacing: 1.0,
    );
  }

  static dynamic titleInSegmentInTypeError() {
    return TextStyle(
      fontSize: 14.0,
      fontFamily: "Montserrat-Light",
      color: colorError,
      letterSpacing: 1.0,
    );
  }

  static dynamic priceOldDealsProduct() {
    return TextStyle(
        fontSize: 13.0,
        fontFamily: "Montserrat-Light",
        color: colorSecondary,
        letterSpacing: 1.0
        //decoration: TextDecoration.lineThrough
    );
  }

  static dynamic moreViews() {
    return TextStyle(
        color: colorText /*, decoration: TextDecoration.underline*/);
  }

  static dynamic priceOldDealsProductBiggest() {
    return TextStyle(
      fontSize: 16.0,
      fontFamily: "Montserrat-Light",
      color: colorSecondary,
      letterSpacing: 1.0,
    );
  }

  static dynamic enterChoiceHobie(size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "Montserrat-Light",
      color: colorPrimary,
      letterSpacing: 1.1,
    );
  }

  static dynamic enterChoiceHobieInSecondaryOption(size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "Montserrat-Light",
      color: colorSecondary,
      letterSpacing: 1.1,
    );
  }
}

Future<int> getLevel() async {
  try {
    final file = await _localLevel;
    String level = await file.readAsString() ?? '0';
    return int.parse(level);
  } catch (e) {
    return 0;
  }
}

Future<String> getPin() async {
  try {
    final file = await _localPin;
    String pin = await file.readAsString() ?? '';
    return pin;
  } catch (e) {
    return '';
  }
}

Future<File> setPin(String pin) async {
  final file = await _localPin;
  print('$pin saved');
  return file.writeAsString('$pin');
}

Future<File> setLevel(int level) async {
  final file = await _localLevel;
  return file.writeAsString('$level');
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localLevel async {
  final path = await _localPath;
  return File('$path/level.txt');
}

Future<File> get _localPin async {
  final path = await _localPath;
  return File('$path/pin.txt');
}

resetAllData() async {
  await DBProvider.db.delClient();
  await DBProvider.db.delAllHobies();
  setLevel(0);
}

String dateFormatForTimesAgo(dynamic registerDate) {
  String afficheDate = (DateTime.now()
              .difference(DateTime(
                  int.parse(registerDate.substring(0, 4)),
                  int.parse(registerDate.substring(5, 7)),
                  int.parse(registerDate.substring(8, 10))))
              .inDays <
          4)
      ? "il y ' a " +
          DateTime.now()
              .difference(DateTime(
                  int.parse(registerDate.substring(0, 4)),
                  int.parse(registerDate.substring(5, 7)),
                  int.parse(registerDate.substring(8, 10))))
              .inDays
              .toString() +
          " jr"
      : registerDate.substring(0, 10);
  afficheDate = (DateTime.now()
                  .difference(DateTime(
                      int.parse(registerDate.substring(0, 4)),
                      int.parse(registerDate.substring(5, 7)),
                      int.parse(registerDate.substring(8, 10))))
                  .inDays <
              4 &&
          DateTime.now()
                  .difference(DateTime(
                      int.parse(registerDate.substring(0, 4)),
                      int.parse(registerDate.substring(5, 7)),
                      int.parse(registerDate.substring(8, 10))))
                  .inDays >
              1)
      ? '${afficheDate}s'
      : afficheDate;
  afficheDate = (DateTime.now()
              .difference(DateTime(
                  int.parse(registerDate.substring(0, 4)),
                  int.parse(registerDate.substring(5, 7)),
                  int.parse(registerDate.substring(8, 10))))
              .inDays <
          1)
      ? "Aujourd'hui"
      : afficheDate;
  return afficheDate;
}

// Animation
const AnimationDuration = Duration(milliseconds: 200);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Email invalide";
const String kInvalidEmailError = "Email invalide";
const String kPassNullError = "Mot de passe invalide";
const String kShortPassError = "Mot de passe trop faible";
const String kMatchPassError =
    "Mot de passe et la confirmation \nne se corresponde pas";
const String kNamelNullError = "Nom invalide";
const String kPhoneNumberNullError = "Numero invalide";
const String kAddressNullError = "Adresse invalide";

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: colorText),
  );
}
Widget DialogCustomError(String title, String message, BuildContext context) {
  bool isIos = Platform.isIOS;
  return isIos
      ? new CupertinoAlertDialog(
    title: Text(title),
    content: Text(message),
    actions: <Widget>[
      CupertinoDialogAction(
          child: Text("Ok"),
          onPressed: () {
            Navigator.of(context).pop();
          })
    ],
  )
      : new AlertDialog(
    title: Text(title),
    content: Text(message),
    elevation: 20.0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)),
    actions: <Widget>[
      FlatButton(
          child: Text("Ok"),
          onPressed: () {
            Navigator.of(context).pop();
          })
    ],
  );
}

Widget DialogCustomForValidateAction(String title, String message, String titleValidateMessage, callback, BuildContext context) {
  bool isIos = Platform.isIOS;
  return isIos
      ? new CupertinoAlertDialog(
    title: Text(title),
    content: Text(message),
    actions: <Widget>[
      CupertinoDialogAction(
          child: Text("Annuler", style: Style.chatOutMe(15),),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      CupertinoDialogAction(
          child: Text(titleValidateMessage, style: Style.titleInSegmentInTypeError(),),
          onPressed: () async {
            await callback();
            Navigator.of(context).pop();
          }),
    ],
  )
      : new AlertDialog(
    title: Text(title),
    content: Text(message),
    elevation: 20.0,
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    actions: <Widget>[
      FlatButton(
          child: Text("Annuler", style: Style.chatOutMe(15),),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      FlatButton(
          child: Text(titleValidateMessage, style: Style.titleInSegmentInTypeError()),
          onPressed: () {
            callback();
            Navigator.of(context).pop();
          }),
    ],
  );
}

Widget LivraisonWidget(String assetFile, String title) {
  return Container(
    width: 120,
    height: 70,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 50,
          height: 50,
          child: Image.asset(assetFile, fit: BoxFit.contain),
        ),
        SizedBox(height: 5),
        Text(title, style: Style.chatIsMe(12))
      ],
    ),
  );
}

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double defaultSize;
  static Orientation orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
  }
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
  // 812 is the layout height that designer use
  return (inputHeight / 812.0) * screenHeight;
}

// Get the proportionate height as per screen size
double getProportionateScreenWidth(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designer use
  return (inputWidth / 375.0) * screenWidth;
}

// Style boutton in flutter
final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.white,
  primary: colorText,
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  ),
);
