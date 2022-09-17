class Categorie {
  String name;
  late String id;
  late int popularity;
  late List<dynamic> domaine;
  bool isHobie = false;

  Categorie(this.name);
  
  Map<String, dynamic> toMap() => {
        "name": name,
      };

  Categorie.fromJson(Map<dynamic, dynamic> json) :
    name = json["name"],
    id = json["_id"],
        popularity = json["popularity"],
        isHobie = json["isHobie"] ?? false,
    domaine = json["domaine"];
}