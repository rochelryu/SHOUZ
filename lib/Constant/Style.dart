import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shouz/ServicesWorker/ConsumeAPI.dart';
import 'package:shouz/Utils/Database.dart';

import 'my_flutter_app_second_icons.dart';

Color colorOne = tint;
Color colorTwo = backgroundColorSec;
Color colorThree = colorText;
enum TypePayement { bitcoin, ethereum, orange, mtn, moov, wave, visa }


bool primaryTheme = true;
final Color backgroundColor = (!primaryTheme) ? Colors.white : Color(0xFF2d3447);
final Color backgroundColorSec = Color(0xFF4A4A58);
final Color tint = Color(0xFF4A4A65);
final Color colorText = Color(0xFF0288D1);
final Color colorTextShadow = Color(0xFF2979FF);
final Color colorError = Color(0xFFB71C1C);
final Color colorWarning = Color(0xFFDEB31C);
final Color colorSuccess = Color(0xFF4CAF50);
const Color colorPrimary = Colors.white;
const Color colorSecondary = Colors.grey;
const Color colorWelcome = Colors.white70;
final Color secondColor =
    (!primaryTheme) ? Color(0xFFFFFFFF) : Color(0xFFFFFFFF);
final transitionMedium = new Duration(milliseconds: 400);
final transitionLong = new Duration(milliseconds: 800);
final transitionSuperLong = new Duration(milliseconds: 1200);

final String channelKey = "shouz_channel";
final String channelName = "Shouz Notifications";
final String channelDescription = "Shouz, Social Department of CLUB12";

class DealsSkeletonData {
  List<dynamic> imageUrl;
  var title;
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
  var archive;
  var level;
  var categorieName;
  var video;
  DealsSkeletonData(
      {required this.imageUrl,
        required this.title,
        required this.price,
        required this.numero,
        required this.autor,
        required this.describe,
        required this.numberFavorite,
        required this.lieu,
        required this.registerDate,
        required this.id,
        required this.profil,
        required this.quantity,
        required this.archive,
        required this.level,
        required this.onLine, required this.authorName, required this.categorieName, required this.video});
}

int channelId() {
  return DateTime.now().millisecondsSinceEpoch;
}

var pageList = [
  PageModel(
      imageUrl: "images/actu.png",
      title: "ACTUALITES",
      body: "Suivez l'actualité d'ici et d'ailleurs. De plus soyez informés des dernières offres d'emploi et appel d'offres de votre localité.",
      titleGradient: gradient[0]),
  PageModel(
      imageUrl: "images/deals.png",
      title: "DEALS",
      body:
          "Vendez gratuitement ou achetez un produit en ayant la possibilité de discuter du prix d'achat et s'assurer de la qualité. Nous vous livrons le produit, satisfait ou remboursé.",
      titleGradient: gradient[1]),
  PageModel(
      imageUrl: "images/event.png",
      title: "EVENEMENTS",
      body: "Créez vos évènements et gagnez 100% sur la vente de vos billets. Une personne qui achète des billets peut les partager au besoin.",
      titleGradient: gradient[2]),
  PageModel(
      imageUrl: "images/voyage.png",
      title: "VOYAGES",
      body: "Le covoiturage simplifie vos trajets. Voyagez de ville en ville dans un véhicule personnelle confortable à bas prix et à tout moment.",
      titleGradient: gradient[3]),
  PageModel(
      imageUrl: "images/publi.png",
      title: "PUBLICITES",
      body: "Une présence, qui devient une visibilité pour les marchands et les entreprises.",
      titleGradient: gradient[4]),
  PageModel(
      imageUrl: "images/choice.png",
      title: "PREFERENCES",
      body: "Et tout ça selon vos préférences.",
      titleGradient: gradient[5]),
];
var pageExplicationEventList = [
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}hello.svg",
      body: "Salut à vous et bienvenue dans les explications de la rubrique événement.\nSans plus tarder nous allons rentrer dans le vif du sujet."),
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}surveillance.svg",
      body: "1- Cette rubrique existe pour tous ceux qui veulent organiser des événements et pouvoir vendre leurs tickets directement dans SHOUZ.\nLes tickets sont des codes QR que vos acheteurs auront et qui seront décodés par une ou plusieurs personnes à qui vous aurez donné la permission (des vigils ou autres agents de sécurité).\nVotre décodeur doit avoir un compte SHOUZ car c'est avec son compte sous la rubrique décodage de ticket qu'il pourra décoder vos tickets."),
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}allInOneExplainEvent.jpeg",
      body: "2- N'importe qui peut créer son événement afin de pouvoir vendre ses tickets et n'importe quel type d'événement peut être créé. Des événements à tickets gratuits comme payant. Il suffit de choisir un abonnement qui correspond au mieux à votre événement (en fonction du type de ticket ainsi qu'au nombre maximal de ticket)."),
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}ConsultingEvent.svg",
      body: "3- Les clients qui achètent les tickets sont tout comme vous nos priorités donc nous travaillons afin d'améliorer leur cadre et possibilités d'actions dans SHOUZ.\nPar exemple un client qui achète un ticket de plusieurs places peut partager des places à d'autres membres dans l'application ce qui fera qu'eux aussi auront des tickets du nombre de places qui leur seront allouées.\nCeci est la fonctionnalité de partage de ticket qui est utilisé en cas d'indisponibilité ou de retard de celui qui a acheté les tickets et sert également à faciliter l'achat de tickets par des mentors afin de les distribuer aux membres intéressés."),
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}cashIn.svg",
      body: "4- Les clients qui achètent les tickets peuvent annuler l'achat de leur ticket s'ils trouvent qu'ils ne seront plus disponibles pour participer à l'événement, ainsi ils récupèrent 90% du montant du ticket acheté, les autres 10% vont sur le solde cumule du créateur de l'événement ainsi que le ticket qui redevient à nouveau disponible pour achat.\nMais l'annulation de ticket peut se faire si l'acheteur est pris un ticket d'au plus 2 places et durant un temps, si on arrive à 24h avant le début de l'événement, aucun ticket ne peut être annulé."),
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}CancelledEvent.svg",
      body: "5- Pour toutes annulations de l'événement par le créateur de l'événement, le client récupère son argent dans l'intégralité. Pendant l'achat des tickets le créateur de l'événement ne perçoit pas immédiatement l'argent des tickets vendus, l'argent est déposé sur son solde cumul.\nCe n'est qu'une fois que l'événement commencé que le promoteur reçoit immédiatement tout l'argent de sa vente de tickets directement dans son compte SHOUZPAY."),
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}notification.svg",
      body: "6 - Nous notifions le créateur de l'événement lorsqu'un ticket est acheté, affichhons toutes les statistiques de l'évènement.\nNous assurons au créateur de l'événement une totale sécurité concernant l'achat, la gestion et le décodage de ticket pour ses événements et nous assurons aussi une large communauté intéressée.\nNous tenons à rappeler que les événements ne sont visibles que chez ceux qui sont intéressés par la même catégorie qu'à l'événement."),
];

var pageExplicationTravelList = [
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}tranquile.png",
      body: "Salut à vous et bienvenue dans les explications de la rubrique Voyage.\nSans plus tarder nous allons rentrer dans le vif du sujet."),
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}conducteur.svg",
      body: "1- Cette rubrique existe pour tous ceux qui veulent rémunérer leurs voyages en vendant des places de leur vehicule lors de leurs differents voyage entre ville.\nLes tickets sont des codes QR que vos acheteurs auront et qui seront décodés par vous-même lors de l'embarcation. Au moment d'embarquer il vous suffit de vous rendre sous la rubrique Outils>Vérifications Tickets>decoder ticket de voyage."),
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}driving.svg",
      body: "2- N'importe qui ne peut créer un voyage et le rémunérer. Pour pouvoir créer un voyage il vous faut faire une demande conductrice auprès de Shouz en envoyant des images de la carte grise, carte de visite technique, permis de conduire, assurance, et aussi une photo de votre véhicule et une autre image de vous.\nCette demande peut se faire sous la rubrique Outils>Devenir Conducteur. Nos robots analyseront vos documents de façon minutieuse et avec les supports de vérification adéquate car il en va de la sécurité de nos utilisateurs intéressés."),
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}secondvoyage.png",
      body: "3- N'importe qui ne peut être passager d'un voyage. Pour pouvoir être passager il faut débloquer son compte en envoyant des images d'une pièce d'identité(CNI, PASSPORT, PERMIS ou ATTESTATION) aussi une image de soi ayant attrapé la pièce en question de par la main.\nCette demande peut se faire sous la rubrique Paramètre>compte>Information Voyage. Nos robots analyseront vos documents de façon minutieuse et avec les supports de vérification adéquate car il en va de la sécurité de nos conducteurs."),
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}voyage.png",
      body: "4- Le prix du ticket est donné par le conducteur. lors de l'achat des tickets le conducteur ne reçoit pas immédiatement l'argent. s'est après avoir decoder le ticket du passager à l'arrivée que le conducteur reçoit ainsi l'argent du ticket. Il reçoit 90% de la vente du ticket et SHOUZ reçoit les 10% restant.\nPar contre si lors de son voyage l'administration SHOUZ l'appelle pour récupérer un colis dans sa ville de départ pour remettre à une tierce personne sur son trajet, le conducteur bénéficiera d'un avantage commission ce qui lui permettra de gagner 95% au lieu de 90% sur chaque ticket."),
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}wait_vehicule.svg",
      body: "5- En résumé, le principe est simple, pour devenir conducteur et gagner 90% ou 95% de chaque ticket vendu vous devez faire une demande conductrice.\nPour pouvoir acheter une place pour un voyage il faut que votre compte soit authentifié et pour cela vous deviez envoyer des informations vous concernant à l'administration SHOUZ. "),
  PageExplicationModel(
      imageUrl: "${ConsumeAPI.AssetPublicServer}notime.svg",
      body: "6 - Tout traitement de demande conducteur ou voyageur par l'administration SHOUZ prend moins de 48h"),
];
List<List<Color>> gradient = [
  [Color(0xFF9CCC64), Color(0xFF33691E)],
  [Color(0xFFE2859F), Color(0xFFFCCF31)],
  [Color(0xFF5EFCE8), Color(0xFF736EFE)],
  [Color(0xFFFFCDD2), Color(0xFFFF1744)],
  [Color(0xFF9708CC), Color(0xFF43CBFF)],
  [backgroundColorSec, backgroundColor],
];
List<Color> colorsForStats = [Color(0xFF33691E), Color(0xFFE2859F),Color(0xFFFFCDD2), Color(0xFFFCCF31), Color(0xFFFF1744), Color(0xFF9708CC), Color(0xFF736EFE)];

class PageModel {
  var imageUrl;
  var title;
  var body;
  List<Color> titleGradient = [];
  PageModel({this.imageUrl, this.title, this.body, required this.titleGradient});
}


class PageExplicationModel {
  var imageUrl;
  var body;
  PageExplicationModel({this.imageUrl, this.body});
}

class DealsModel {
  var imageUrl;
  var title;
  var favorite;
  var price;
  var numero;
  var autor;
  var registerDate;
  DealsModel(
      {this.imageUrl,
      this.title,
      this.favorite,
      this.price,
      this.numero,
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
      required this.placeTotal,
      required this.placeDisponible,
      this.dateVoyage,
      this.chauffeurName,
      this.id,
      this.levelName,
      this.nextLevel,
      this.numberTravel,
      required this.hobiesCovoiturage});
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

  static dynamic grandTitreBlue(double size) {
    return TextStyle(
        color: colorText,
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

  static dynamic titreBlue(double size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "LexendExa",
      color: colorText,
    );
  }

  static dynamic secondTitre(double size) {
    return TextStyle(
        fontSize: size,
        fontFamily: "Montserrat-Black",
        color: secondColor,
        letterSpacing: 1.2);
  }

  static dynamic sousTitre(double size, [Color color = colorSecondary]) {
    return TextStyle(
      fontSize: size,
      fontFamily: "LexendExa",
      color: color,
    );
  }

  static dynamic sousTitreBlack(double size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "LexendExa",
      color: Colors.black,
    );
  }

  static dynamic sousTitreBlackOpacity(double size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "LexendExa",
      color: Colors.black45,
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
      fontSize: 42.0,
      fontFamily: "Montserrat-Black",
      letterSpacing: 1.0,
      //fontWeight: FontWeight.w600,
    );
  }

  static dynamic titleOnBoard() {
    return TextStyle(
      fontSize: 34.0,
      fontFamily: "Montserrat-Black",
      letterSpacing: 2.0,
      //fontWeight: FontWeight.w600,
    );
  }

  static dynamic titleNews([double size = 18.0]) {
    return TextStyle(
        fontSize: size,
        fontFamily: "Montserrat-Black",
        letterSpacing: 2.0,
        color: Colors.white
        //fontWeight: FontWeight.w600,
        );
  }

  static TextStyle simpleTextOnBoard([double size = 17.0, Color color = colorSecondary]) {
    return TextStyle(
      fontSize: size,
      fontFamily: "Montserrat-Light",
      color: color,
      letterSpacing: 1.1,
    );
  }
  static TextStyle skipedMessage([double size = 17.0, Color color = colorSecondary]) {
    return TextStyle(
      fontSize: size,
      fontFamily: "Montserrat-Black",
      color: color,
      decoration: TextDecoration.underline
    );
  }

  static dynamic simpleTextOnBoardWithBolder([double size = 17.0]) {
    return TextStyle(
      fontSize: size,
      fontFamily: "Montserrat-Light",
      color: colorSecondary,
      letterSpacing: 1.1,
      fontWeight: FontWeight.w900,
    );
  }

  static dynamic simpleTextWithSizeAndColors([double size = 17.0, Color color = colorSecondary]) {
    return TextStyle(
      fontSize: size,
      fontFamily: "Montserrat-Light",
      color: color,
      letterSpacing: 1.1,
      fontWeight: FontWeight.w900,
    );
  }

  static dynamic simpleTextBlack() {
    return TextStyle(
      fontSize: 17.0,
      fontFamily: "Montserrat-Light",
      color: Colors.grey,
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

  static dynamic copyRight() {
    return TextStyle(
      fontSize: 13.0,
      fontFamily: "Montserrat-Light",
      color: colorPrimary,
      decoration: TextDecoration.underline,
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

  static dynamic titleDealsProduct([double size = 13.0]) {
    return TextStyle(
      fontSize: size,
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
      fontSize: 12.0,
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

  static dynamic mobileMoneyMtn() {
    return TextStyle(
      fontSize: 16.0,
      fontFamily: "Montserrat-Black",
      color: Colors.yellow,
      letterSpacing: 1.0,
    );
  }

  static dynamic mobileMoneyWave() {
    return TextStyle(
      fontSize: 16.0,
      fontFamily: "Montserrat-Black",
      color: Colors.blue,
      letterSpacing: 1.0,
    );
  }

  static dynamic mobileMoneyMoov() {
    return TextStyle(
      fontSize: 16.0,
      fontFamily: "Montserrat-Black",
      color: Colors.blueAccent,
      letterSpacing: 1.0,
    );
  }

  static dynamic mobileMoneyOrange() {
    return TextStyle(
      fontSize: 16.0,
      fontFamily: "Montserrat-Black",
      color: Colors.deepOrangeAccent,
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

  static dynamic titleInSegmentInTypeRequest() {
    return TextStyle(
      fontSize: 14.0,
      fontFamily: "Montserrat-Light",
      color: colorText,
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
  static dynamic textBeginCity(double size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "Montserrat-Black",
      color: Colors.redAccent,
      letterSpacing: 1.0,
    );
  }

  static dynamic textEndCity(double size) {
    return TextStyle(
      fontSize: size,
      fontFamily: "Montserrat-Black",
      color: colorText,
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

  static dynamic simpleTextInContainer([Color color = colorPrimary]) {
    return TextStyle(
      fontFamily: "Montserrat-Light",
      color: color,
      fontSize: 11,
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
    String level = await file.readAsString();
    return int.parse(level);
  } catch (e) {
    return 0;
  }
}

Future<String> getPin() async {
  try {
    final file = await _localPin;
    String pin = await file.readAsString();
    return pin;
  } catch (e) {
    return '';
  }
}

Future<int> getExplainEvent() async {
  try {
    final file = await _localExplainEvent;
    String explainEvent = await file.readAsString();
    return int.parse(explainEvent);
  } catch (e) {
    return 0;
  }
}

Future<int> getExplainCovoiturage() async {
  try {
    final file = await _localExplainCovoiturage;
    String explainCovoiturage = await file.readAsString();
    return int.parse(explainCovoiturage);
  } catch (e) {
    return 0;
  }
}
Future<File> setExplain(int pin, String categorieExplain) async {
  final file = categorieExplain == "event" ? await _localExplainEvent: await _localExplainCovoiturage;
  return file.writeAsString('$pin');
}

Future<File> setPin(String pin) async {
  final file = await _localPin;
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

Future<File> get _localExplainEvent async {
  final path = await _localPath;
  return File('$path/explainEvent.txt');
}

Future<File> get _localExplainCovoiturage async {
  final path = await _localPath;
  return File('$path/explainCovoiturage.txt');
}

Future<File> get _localPin async {
  final path = await _localPath;
  return File('$path/pin.txt');
}

resetAllData() async {
  await DBProvider.db.delClient();
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
  return afficheDate.replaceAll('-', '/');
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

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double defaultSize = 0;
  static late Orientation orientation;

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
  foregroundColor: Colors.white,
  backgroundColor: colorText,
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);

final ButtonStyle raisedButtonLockedStyle = ElevatedButton.styleFrom(
  foregroundColor: Colors.white,
  backgroundColor: colorSecondary,
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);


final ButtonStyle raisedButtonStyleError = ElevatedButton.styleFrom(
  foregroundColor: Colors.white,
  backgroundColor: colorError,
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);

final ButtonStyle raisedButtonStyleSuccess = ElevatedButton.styleFrom(
  foregroundColor: Colors.white,
  backgroundColor: colorSuccess,
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);

final ButtonStyle raisedButtonStyleMtnMoney = ElevatedButton.styleFrom(
  foregroundColor: Colors.black,
  backgroundColor: Colors.yellowAccent,
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);

final ButtonStyle raisedButtonStyleOrangeMoney = ElevatedButton.styleFrom(
  foregroundColor: Colors.black, backgroundColor: Colors.deepOrangeAccent,
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);
final ButtonStyle raisedButtonStyleWave = ElevatedButton.styleFrom(
  foregroundColor: Colors.white,
  backgroundColor: Colors.blue,
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);
final ButtonStyle raisedButtonStyleMoovMoney = ElevatedButton.styleFrom(
  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
  minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),
);

final ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
  foregroundColor: colorText, minimumSize: Size(88, 36),
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(20)),
  ),

);


//AlertType Modal
Future<Null> askedToLead(String message, bool success, BuildContext context) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: success
              ? Icon(MyFlutterAppSecond.checked,
              size: 120, color: colorSuccess)
              : Icon(MyFlutterAppSecond.cancel,
              size: 120, color: colorError),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(children: [
                Text(message,
                    textAlign: TextAlign.center,
                    style: Style.sousTitre(13)),
                ElevatedButton(
                    child: Text('Ok'),
                    style:
                    success ? raisedButtonStyleSuccess : raisedButtonStyleError,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ]),
            )
          ],
        );
      },
    barrierDismissible: false
  );
}

Future<Null> modalForExplain(String assetLink, String text, BuildContext context, [bool isSvg = false]) async {
  
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(

          children: <Widget>[
            if(!isSvg) Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(assetLink),
                  fit: BoxFit.contain
                )
              ),
            
            ),
            if(isSvg) SvgPicture.network(assetLink,
              semanticsLabel: text.substring(0, 20),
              height: 250,
            ),
            SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(text, style: Style.simpleTextOnBoardWithBolder(13.0)),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45),
                child: ElevatedButton(
                    child: Text('Ok'),
                    style: raisedButtonStyle,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              )
          ],
        );
      },
      barrierDismissible: false
  );
}
