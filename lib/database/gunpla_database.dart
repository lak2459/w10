import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/gunpla.dart';

const createGunplaTable = '''
CREATE TABLE gunpla (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 100),
  model_code TEXT NOT NULL CHECK(length(trim(model_code)) BETWEEN 1 AND 40),
  grade TEXT NOT NULL CHECK(grade IN ('HG','RG','MG','PG','SD')),
  status TEXT NOT NULL CHECK(status IN ('ยังไม่ประกอบ','กำลังประกอบ','ประกอบแล้ว')),
  price_satang INTEGER NOT NULL CHECK(price_satang BETWEEN 0 AND 999999999),
  notes TEXT NOT NULL DEFAULT '' CHECK(length(notes) <= 500)
)
''';

class GunplaDatabase {
  GunplaDatabase._();
  static final instance = GunplaDatabase._();
  Future<Database>? _opening;

  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    try {
      final directory = await getApplicationSupportDirectory();
      await Directory(directory.path).create(recursive: true);
      return await openDatabase(p.join(directory.path, 'gunpla.db'),
        version: 1,
        onCreate: (db, version) => db.execute(createGunplaTable),
      );
    } catch (_) {
      _opening = null; // Allow Retry after a failed open.
      rethrow;
    }
  }

  Future<List<Gunpla>> readAll() async {
    final db = await database;
    final rows = await db.query('gunpla', orderBy: 'id DESC');
    return rows.map(Gunpla.fromMap).toList();
  }

  Future<int> save(Gunpla item) async {
    final db = await database;
    if (item.id == null) return db.insert('gunpla', item.toMap());
    final values = item.toMap()..remove('id');
    final count = await db.update('gunpla', values,
      where: 'id = ?', whereArgs: [item.id]);
    if (count != 1) throw StateError('Record no longer exists');
    return item.id!;
  }

  Future<void> delete(int id) async {
    final db = await database;
    final count = await db.delete('gunpla', where: 'id = ?', whereArgs: [id]);
    if (count != 1) throw StateError('Record no longer exists');
  }
}
