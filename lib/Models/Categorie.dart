class Categorie {
  String name;
  String id;
  int popularity;
  List<dynamic> domaine;
  
  Categorie(this.name);
  
  Map<String, dynamic> toMap() => {
        "name": name,
      };

  Categorie.fromJson(Map<dynamic, dynamic> json) :
    name = json["name"],
    id = json["_id"],
    popularity = json["popularity"],
    domaine = json["domaine"];
}