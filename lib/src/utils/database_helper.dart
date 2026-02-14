import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../ui/requestmoney/model/res_contact.dart';
import 'db_constant.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, DBConstant.dbName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE ${DBConstant.dbTableName} (
            ${DBConstant.dbColumnId} NUMBER,
            ${DBConstant.dbColumnFirstName} TEXT,
            ${DBConstant.dbColumnLastName} TEXT,
            ${DBConstant.dbColumnMobile} TEXT,
            ${DBConstant.dbColumnProfilePicture} TEXT
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(DBConstant.dbTableName, row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final db = await instance.database;
    return await db.query(DBConstant.dbTableName);
  }

  Future<int> queryRowCount() async {
    final db = await instance.database;
    return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM ${DBConstant.dbTableName}')) ??
        0;
  }

  Future<int> update(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row[DBConstant.dbColumnMobile];
    return await db.update(DBConstant.dbTableName, row,
        where: '${DBConstant.dbColumnMobile} = ?', whereArgs: [id]);
  }

  Future<int> delete() async {
    final db = await instance.database;
    return await db.delete(DBConstant.dbTableName,
        where: null, whereArgs: null);
  }

  Future<int> deleteRow(String id) async {
    final db = await instance.database;
    return await db.delete(DBConstant.dbTableName,
        where: '${DBConstant.dbColumnMobile} = ?', whereArgs: [id]);
  }

  Future<List<ContactResponseModel>> fetchAllContact() async {
    final dbClient = await instance.database;
    final list =
        await dbClient.rawQuery('Select * from ${DBConstant.dbTableName}');
    final List<ContactResponseModel> listContacts = <ContactResponseModel>[];
    if (list.isNotEmpty) {
      for (final row in list) {
        final temp = ContactResponseModel(
          id: row[DBConstant.dbColumnId] as int? ?? 0,
          firstName: row[DBConstant.dbColumnFirstName]?.toString() ?? '',
          lastName: row[DBConstant.dbColumnLastName]?.toString() ?? '',
          mobile: row[DBConstant.dbColumnMobile]?.toString() ?? '',
          profilePicture:
              row[DBConstant.dbColumnProfilePicture]?.toString() ?? '',
        );
        listContacts.add(temp);
      }
    }
    return listContacts;
  }
}
