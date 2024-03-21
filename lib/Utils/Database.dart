import 'package:shouz/Models/User.dart';
import 'package:shouz/Utils/shared_pref_function.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, "shouzLocal.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          '''CREATE TABLE Client (id INTEGER PRIMARY KEY autoincrement, ident TEXT, name TEXT, numero TEXT, prefix TEXT, images TEXT, recovery TEXT, position TEXT, email TEXT, pin TEXT, longitude REAL, lagitude REAL, wallet REAL,inscriptionIsDone INTEGER,isActivateForfait INTEGER, currencies TEXT,isActivateForBuyTravel INTEGER, tokenNotification TEXT, serviceNotification TEXT)''');
      await db.execute("CREATE TABLE profil (name TEXT, base TEXT NULL)");

    });
  }

  static String join(directoryPath, file) {
    return '$directoryPath/$file';
  }

  newProfil(String name, String data) async {
    final db = await database;
    db.delete("profil");
    var res = await db.rawInsert(
        "INSERT Into profil (name, base) VALUES (?,?)", [name, data]);
    //await db.insert(type, newClient.toMap());
    return res;
  }

  delProfil() async {
    final db = await database;
    db.delete("profil");
  }

  Future<int> updateName(String name) async {
    final db = await database;
    return await db.rawUpdate("UPDATE Client SET name = ?", [name]);
  }

  Future<int> updateIdent(String ident) async {
    final db = await database;
    return await db.rawUpdate("UPDATE Client SET ident = ?", [ident]);
  }

  newClient(User newClient) async {
    final db = await database;
    var res = await db.rawInsert(
        "INSERT INTO Client (ident,name,numero,prefix,images,recovery, position, email, longitude, lagitude, pin, wallet, inscriptionIsDone, isActivateForfait, currencies, isActivateForBuyTravel, tokenNotification, serviceNotification) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
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
          'pin',
          newClient.wallet,
          newClient.inscriptionIsDone,
          newClient.isActivateForfait,
          newClient.currencies,
          newClient.isActivateForBuyTravel,
          newClient.tokenNotification,
          newClient.serviceNotification
        ]);
    return res;
  }

  getClient() async {
    final db = await database;
    var res = await db.query("Client");
    List<User> list = res.map((c) => User.fromJsonLite(c)).toList();
    if(list.isNotEmpty) {
      return list.last;
    }
    final anonymousUser = await getAnonymousUser() as Map;
    if(anonymousUser.isNotEmpty) {
      print("Is Not empty");
      return User.fromJson(anonymousUser);
    }
    return null;

  }

  getProfil() async {
    final db = await database;
    var res = await db.query("profil");

    return res[res.length - 1];
  }

  delClient() async {
    final db = await database;
    db.delete("Client");
    print("Delete Client");
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
        "UPDATE Client SET wallet = ? WHERE ident = ?", [double.parse(wallet.toString()), id]);
    return res;
  }
  updateClientIsActivateForfait(int isActivateForfait, String id) async {
    final db = await database;
    var res = db.rawUpdate(
        "UPDATE Client SET isActivateForfait = ? WHERE ident = ?", [isActivateForfait, id]);
    return res;
  }
  updateClientIsActivateForBuyTravel(int isActivateForBuyTravel, String id) async {
    final db = await database;
    var res = db.rawUpdate(
        "UPDATE Client SET isActivateForBuyTravel = ? WHERE ident = ?", [isActivateForBuyTravel, id]);
    return res;
  }
}
