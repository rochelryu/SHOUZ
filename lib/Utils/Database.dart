import 'package:shouz/Models/User.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, "shouzLocal.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          '''CREATE TABLE Client (id INTEGER PRIMARY KEY autoincrement, ident TEXT, name TEXT, numero TEXT, prefix TEXT, images TEXT, recovery TEXT, position TEXT, email TEXT, pin TEXT, longitude REAL, lagitude REAL, wallet INTEGER,inscriptionIsDone INTEGER )''');
      await db.execute("CREATE TABLE HobiesActualite (name TEXT)");
      await db.execute("CREATE TABLE hobiesDeals (name TEXT)");
      await db.execute("CREATE TABLE hobiesEvents (name TEXT)");
      await db.execute("CREATE TABLE profil (name TEXT, base BLOB NULL)");
    });
  }

  static String join(directoryPath, file) {
    return '$directoryPath/$file';
  }

  newHobies(String type, dynamic hobies) async {
    final db = await database;
    var res = hobies
        .map((name) async =>
            await db.rawInsert("INSERT Into $type (name) VALUES (?)", [name]))
        .toList();
    //await db.insert(type, newClient.toMap());
    return res;
  }

  newProfil(String name, String data) async {
    final db = await database;
    db.delete("profil");
    var res = await db.rawInsert(
        "INSERT Into profil (name, base) VALUES (?,?)", [name, data]);
    //await db.insert(type, newClient.toMap());
    return res;
  }

  Future<int> updateName(String name) async {
    final db = await database;
    return await db.rawUpdate("UPDATE Client SET name = ?", [name]);
  }

  newClient(User newClient) async {
    final db = await database;
    var res = await db.rawInsert(
        "INSERT INTO Client (ident,name,numero,prefix,images,recovery, position, email, longitude, lagitude, pin, wallet, inscriptionIsDone) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
        [
          newClient.ident,
          newClient.name,
          newClient.numero,
          newClient.prefix,
          newClient.images,
          newClient.recovery,
          newClient.position,
          newClient.email,
          newClient.longitude,
          newClient.lagitude,
          newClient.pin,
          newClient.wallet,
          newClient.inscriptionIsDone
        ]);
    return res;
  }

  getClient() async {
    final db = await database;
    var res = await db.query("Client");
    List<User> list = res.map((c) => User.fromJsonLite(c)).toList();
    return list[list.length - 1];
  }

  getProfil() async {
    final db = await database;
    var res = await db.query("profil");
    return res[res.length - 1];
  }

  delClient() async {
    final db = await database;
    db.delete("Client");
  }

  delAllHobies() async {
    final db = await database;
    db.delete("HobiesActualite");
    db.delete("hobiesEvents");
    db.delete("hobiesDeals");
  }

  // update

  updateClient(String recovery, String id) async {
    final db = await database;
    var res = db.rawUpdate(
        "UPDATE Client SET recovery = ? WHERE ident = ?", [recovery, id]);
    return res;
  }

  updateClientWallet(int wallet, String id) async {
    final db = await database;
    var res = db.rawUpdate(
        "UPDATE Client SET wallet = ? WHERE ident = ?", [wallet, id]);
    return res;
  }

  getHobie(String type) async {
    final db = await database;
    var res = await db.query(type);
    List<String> list = res.map((c) => c["name"]).toList();
    return list;
  }
}

// insert
// newClient(Client newClient) async {
//     final db = await database;
//     var res = await db.insert("Client", newClient.toMap());
//     return res;
//   }

// newClient(Client newClient) async {
//     final db = await database;
//     //get the biggest id in the table
//     var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Client");
//     int id = table.first["id"];
//     //insert to the table using the new id
//     var raw = await db.rawInsert(
//         "INSERT Into Client (id,first_name,last_name,blocked)"
//         " VALUES (?,?,?,?)",
//         [id, newClient.firstName, newClient.lastName, newClient.blocked]);
//     return raw;
//   }

// read
// getClient(int id) async {
//     final db = await database;
//     var res =await  db.query("Client", where: "id = ?", whereArgs: [id]);
//     return res.isNotEmpty ? Client.fromMap(res.first) : Null ;
//   }

// getBlockedClients() async {
//     final db = await database;
//     var res = await db.rawQuery("SELECT * FROM Client WHERE blocked=1");
//     List<Client> list =
//         res.isNotEmpty ? res.toList().map((c) => Client.fromMap(c)) : null;
//     return list;
//   }
// blockOrUnblock(Client client) async {
//     final db = await database;
//     Client blocked = Client(
//         id: client.id,
//         firstName: client.firstName,
//         lastName: client.lastName,
//         blocked: !client.blocked);
//     var res = await db.update("Client", blocked.toMap(),
//         where: "id = ?", whereArgs: [client.id]);
//     return res;
//   }

// Delete
// deleteClient(int id) async {
//     final db = await database;
//     db.delete("Client", where: "id = ?", whereArgs: [id]);
//   }

// deleteAll() async {
//     final db = await database;
//     db.rawDelete("Delete * from Client");
//   }
