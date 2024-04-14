class Event {
  late String title;
  late String id;
  late String imageCover;

  Event({required this.title});

  Map<String, dynamic> toMap() => {
    "title": title,
    "_id": id,
    "imageCover": imageCover,
  };

  Event.fromJson(Map<dynamic, dynamic> json) :
        title = json["title"],
        id = json["_id"],
        imageCover = json["imageCover"];
}