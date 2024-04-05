import 'dart:convert';

import 'package:parashara_hora/models/nakshatra.dart';
import 'package:parashara_hora/models/usersnew.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../models/grahas.dart';
import '../models/raasi.dart';
import '../models/users.dart';

class DatabaseHelper {
  static const _databaseName = 'ParasharaHora.db';
  static const _databaseVersion = 1;

  List<String> tables = [];
  static const SECRET_KEY = '2023_PRIVATE_KEY_ENCRYPT_2023';

  DatabaseHelper._();

  static final DatabaseHelper db = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory dbDirectory = await getApplicationDocumentsDirectory();
    String dbpath = join(dbDirectory.path, _databaseName);
    return await openDatabase(dbpath,
        version: _databaseVersion,
        onCreate: _onCreateDB,
        onUpgrade: _onUgradeDB);
  }

  Future _onCreateDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ${Users.tblUsers}(
      ${Users.colUserId} INTEGER PRIMARY KEY AUTOINCREMENT,   
      ${Users.colUserName} TEXT NOT NULL,
      ${Users.colUserSex} TEXT NOT NULL,
      ${Users.colUserLong} REAL,
      ${Users.colUserLat} REAL,
      ${Users.colUserBSRise} TEXT NOT NULL,
      ${Users.colUserBSSet} TEXT NOT NULL,
      ${Users.colUserDesc} TEXT NOT NULL,
      ${Users.colUserDateTime} TEXT NOT NULL,
      ${Users.colUserBPos} TEXT NOT NULL,
      ${Users.colUserBSpeed} TEXT NOT NULL, 
      ${Users.colUserTPos} TEXT NOT NULL,
      ${Users.colUserTSpeed} TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE ${Grahas.tblGrahas}(
      ${Grahas.colGrahaId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Grahas.colGrahaName} TEXT NOT NULL,
      ${Grahas.colGrahaSName} TEXT NOT NULL,
      ${Grahas.colGrahaDasaYears} INTEGER,
      ${Grahas.colGrahaDasaOrder} INTEGER,
      ${Grahas.colGrahaDosha} TEXT NOT NULL,
      ${Grahas.colGrahaAilment} TEXT NOT NULL,
      ${Grahas.colGrahaResults} TEXT NOT NULL,
      ${Grahas.colGrahaRelations} TEXT NOT NULL,
      ${Grahas.colGrahaDignity} TEXT NOT NULL,
      ${Grahas.colGrahaFillerOne} TEXT NOT NULL,
      ${Grahas.colGrahaFillerTwo} TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE ${Nakshatra.tblNakshatra}(
      ${Nakshatra.colNakId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Nakshatra.colNakName} TEXT NOT NULL,
      ${Nakshatra.colNakDegEnd} REAL,
      ${Nakshatra.colNakLord} TEXT NOT NULL,
      ${Nakshatra.colNakDeity} TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE ${UsersNew.tblUsersNew}(
      ${UsersNew.colUserNewId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${UsersNew.colUserNewName} TEXT NOT NULL,
      ${UsersNew.colUserNewLong} REAL,
      ${UsersNew.colUserNewLat} REAL,
      ${UsersNew.colUserNewDesc} TEXT NOT NULL,
      ${UsersNew.colUserNewDateTime} TEXT NOT NULL,
      ${UsersNew.colUserNewPos} TEXT NOT NULL,
      ${UsersNew.colUserNewSpeed} TEXT NOT NULL
    )
    ''');

    await db.execute('''

    CREATE TABLE ${Raasi.tblRaasi}(
      ${Raasi.colRaasiId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Raasi.colRaasiName} TEXT NOT NULL,
      ${Raasi.colRaasiDeg} INTEGER,
      ${Raasi.colRaasiLord} TEXT NOT NULL,
      ${Raasi.colRaasiShortName} TEXT NOT NULL,
      ${Raasi.colRaasiOrder} INTEGER,
      ${Raasi.colRaasiLSName} TEXT NOT NULL
    )
    ''');

    Batch batch = db.batch();
    //==============================================================
    String userDataJson =
        await rootBundle.loadString('assets/json/userlist.json');
    List userList = json.decode(userDataJson);

    for (var val in userList) {
      Users users = Users.fromMap(val);
      batch.insert(Users.tblUsers, users.toMap());
    }
    //==============================================================
    String grahaDataJson =
        await rootBundle.loadString('assets/json/grahas.json');
    List grahaList = json.decode(grahaDataJson);

    for (var val in grahaList) {
      Grahas grahas = Grahas.fromMap(val);
      batch.insert(Grahas.tblGrahas, grahas.toMap());
    }
    //==============================================================
    String nakDataJson =
        await rootBundle.loadString('assets/json/nakshatras.json');
    List nakList = json.decode(nakDataJson);

    for (var val in nakList) {
      Nakshatra nakshatra = Nakshatra.fromMap(val);
      batch.insert(Nakshatra.tblNakshatra, nakshatra.toMap());
    }
    //==============================================================
    String raasiDataJson =
        await rootBundle.loadString('assets/json/raasi.json');
    List raasiList = json.decode(raasiDataJson);

    for (var val in raasiList) {
      Raasi raasi = Raasi.fromMap(val);
      batch.insert(Raasi.tblRaasi, raasi.toMap());
    }

    batch.commit();
  }

  Future _onUgradeDB(Database db, int oldversion, int newversion) async {
    if (oldversion == 1) {
      await db.execute('''
      ''');
    }
    Batch batch = db.batch();

    /* String maasaDataJson =
        await rootBundle.loadString('assets/json/maasa_data.json');
    List maasaDataList = json.decode(maasaDataJson);

    maasaDataList.forEach((val) {
      MaasaData maasaData = MaasaData.fromMap(val);
      batch.insert(MaasaData.tblMaasaData, maasaData.toMap());
    }); */

    batch.commit();
  }
  //==============================================================
  //Query Start

  Future<List<Users>> getUserList() async {
    Database db = await database;
    var res = await db.rawQuery('''
     SELECT * FROM ${Users.tblUsers}
    ''');

    return res.isEmpty ? [] : res.map((e) => Users.fromMap(e)).toList();
  }

  //--------------------------------------------------------------

  Future<List<Users>> getUser(int id) async {
    Database db = await database;
    var res = await db.rawQuery('''
     SELECT * FROM ${Users.tblUsers}
     WHERE ${Users.colUserId}=?
    ''', [id]);

    return res.isEmpty ? [] : res.map((e) => Users.fromMap(e)).toList();
  }

  //--------------------------------------------------------------
  Future<int> insertUsers(Users user) async {
    Database db = await database;
    var res = await db.insert(Users.tblUsers, user.toMap());

    return res;
  }

  //--------------------------------------------------------------
  Future<int> updateUser(int id, String transitPos, String transitSpd) async {
    Database db = await database;
    int update = await db.rawUpdate('''
    UPDATE ${Users.tblUsers} 
    SET ${Users.colUserTPos} = ?, ${Users.colUserTSpeed} = ?
    WHERE ${Users.colUserId} = ?
    ''', [transitPos, transitSpd, id]);
    return update;
  }

  //--------------------------------------------------------------
  Future<int> deleteUser(int id) async {
    Database db = await database;

    var result = await db.delete(Users.tblUsers,
        where: '${Users.colUserId} =?', whereArgs: [id]);
    return result;
  }

  //======================Grahas========================================

  Future<List<Grahas>> getGrahaSorted() async {
    Database db = await database;
    var res = await db.rawQuery('''
    SELECT * FROM ${Grahas.tblGrahas}
    ORDER BY ${Grahas.colGrahaDasaOrder} 
    ''');
    return res.isEmpty ? [] : res.map((e) => Grahas.fromMap(e)).toList();
  }

  //=========================Nakshatras=====================================

  Future<List<Grahas>> getGraha() async {
    Database db = await database;
    var res = await db.rawQuery('''
    SELECT * FROM ${Grahas.tblGrahas}
    ''');
    return res.isEmpty ? [] : res.map((e) => Grahas.fromMap(e)).toList();
  }

  //=========================Nakshatras=====================================
  Future<List<Nakshatra>> getNakLord(double moondegree) async {
    Database db = await database;
    List<Map<String, dynamic>> nakshatra = [];
    List<Map<String, dynamic>> res = await db.rawQuery('''
    SELECT * FROM ${Nakshatra.tblNakshatra}
    ''');
    if (res.isNotEmpty) {
      for (int i = 0; i < res.length; i++) {
        if (moondegree < res[i]['degend']) {
          nakshatra.add(res[i]);
        }
      }
    }
    return nakshatra.isEmpty
        ? []
        : nakshatra.map((e) => Nakshatra.fromMap(e)).toList();
  }

  //=========================Raasi=====================================
  Future<List<Nakshatra>> getNakList() async {
    Database db = await database;

    List<Map<String, dynamic>> res = await db.rawQuery('''
    SELECT * FROM ${Nakshatra.tblNakshatra}
    ''');

    return res.isEmpty ? [] : res.map((e) => Nakshatra.fromMap(e)).toList();
  }

  //=========================Raasi=====================================
  Future<List<Raasi>> getRaasiList() async {
    Database db = await database;
    var res = await db.rawQuery('''
     SELECT * FROM ${Raasi.tblRaasi}
    ''');

    // print('From DB Raasi: $res');
    return res.isEmpty ? [] : res.map((e) => Raasi.fromMap(e)).toList();
  }
}
