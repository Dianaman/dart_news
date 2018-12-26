import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import '../models/item_model.dart';
import 'repository.dart';

class NewsDbProvider implements Cache, Source {
  Database db;

  NewsDbProvider() {
    init();
  }

  init() async {
    //await Sqflite.devSetDebugModeOn(true);

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, "items4.db");
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database newDb, int version) {
        newDb.execute("""
          CREATE TABLE Items
          (
            id INTEGER PRIMARY KEY,
            type TEXT,
            by TEXT,
            time INTEGER,
            text TEXT,
            parent INTEGER,
            kids BLOB,
            dead INTEGER,
            deleted INTEGER,
            url TEXT,
            score INTEGER,
            title TEXT,
            descendants INTEGER
          )
        """);
      }
    );
  }

  Future<ItemModel> fetchItem(int id) async {
    final maps = await db.query(
      "Items",
      columns: null,
      where: "id = ?",
      whereArgs: [id]
    );

    if(maps.length > 0) {
      final item = ItemModel.fromDb(maps.first);
      //print('item from db: ${item.id} - ${item.title}');
      return item;
    }

    return null;
  }

  Future<int> addItem(ItemModel item) {
    return db.insert("Items", 
      item.toMapforDb(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  //abstract - to do
  Future<List<int>> fetchTopIds() {
    return null;
  }

  Future<int> clear() {
    return db.delete("Items");
  }
}
  
final newsDbProvider = NewsDbProvider();