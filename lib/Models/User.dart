class User {
  String name = '';
  String ident = '';
  String numero;
  String prefix;
  String images = '';
  String recovery = '';
  String position = '';
  String currencies = '';
  String email = '';
  double? longitude;
  double? lagitude;
  List? hobiesActualite;
  List? hobiesDeals;
  List? hobiesEvents;
  List? favoriteActualite;
  List? favoriteDeals;
  List? favoriteEvents;
  List? myDealsProducts;
  List? covoiturage;
  List? myEvents;
  List? myTravel;
  String pin = '';
  String tokenNotification = '';
  String serviceNotification = '';
  double wallet = 0;
  int inscriptionIsDone  = 0;
  int isActivateForfait  = 0;
  int isActivateForBuyTravel = 0;
  User(this.numero, this.prefix);

  Map<String, dynamic> toMap() => {
        "ident": ident,
        "name": name,
        "email": email,
        "numero": numero,
        "position": position,
        "pin": pin,
        "images": images,
        "longitude": longitude,
        "lagitude": lagitude,
        "hobiesActualite": hobiesActualite,
        "hobiesDeals": hobiesDeals,
        "recovery": recovery,
        "currencies": currencies,
        "hobiesEvents": hobiesEvents,
        "prefix": prefix,
        "wallet": wallet,
        "inscriptionIsDone": inscriptionIsDone,
        "isActivateForfait": isActivateForfait,
        "isActivateForBuyTravel": isActivateForBuyTravel,
        "tokenNotification": tokenNotification,
        "serviceNotification": serviceNotification,
      };

  User.fromJson(Map<dynamic, dynamic> json)
      : name = json["name"] ?? '',
        email = json["email"] ?? '',
        ident = json["_id"],
        position = json["position"] ?? '',
        pin = json["pin"] ?? '',
        numero = json["numero"],
        prefix = json["prefix"],
        images = json["images"] ?? '',
        lagitude = (json["positionRecently"] != null)
            ? json["positionRecently"]["latitude"]
            : 0,
        longitude = (json["positionRecently"] != null)
            ? json["positionRecently"]["longitude"]
            : 0,
        hobiesActualite = json["hobiesActualite"] ?? [],
        hobiesDeals = json["hobiesDeals"] ?? [],
        recovery = json["recovery"],
        currencies = json["currencies"],
        isActivateForBuyTravel = json["isActivateForBuyTravel"],
        wallet = double.parse(json["wallet"].toString()),
        inscriptionIsDone = json["inscriptionIsDone"] ? 1 : 0,
        isActivateForfait = json["isActivateForfait"] ? 1 : 0,
        tokenNotification = json["tokenNotification"] ?? '',
        serviceNotification = json["serviceNotification"] ?? '',
        hobiesEvents = json["hobiesEvents"] ?? [];

  // this method is used only my app call SQLite database;
  User.fromJsonLite(Map<dynamic, dynamic> json)
      : name = json["name"] ?? '',
        email = json["email"] ?? '',
        ident = json["ident"],
        position = json["position"] ?? '',
        pin = json["pin"] ?? '',
        wallet = double.parse(json["wallet"].toString()),
        numero = json["numero"],
        prefix = json["prefix"],
        images = json["images"] ?? '',
        lagitude = json["lagitude"],
        longitude = json["longitude"],
        hobiesActualite = [],
        hobiesDeals = [],
        recovery = json["recovery"],
        currencies = json["currencies"],
        isActivateForBuyTravel = json["isActivateForBuyTravel"],
        inscriptionIsDone = json["inscriptionIsDone"],
        isActivateForfait = json["isActivateForfait"],
        tokenNotification = json["tokenNotification"] ?? '',
        serviceNotification = json["serviceNotification"] ?? '',
        hobiesEvents = [];
}
