// lib/data/medicamento_dao.dart
import 'package:sqflite/sqflite.dart';
import 'package:medicamentos_app/db/database_helper.dart';
import 'package:medicamentos_app/models/medicamento.dart';

class MedicamentoDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  static const String tableName = 'medicamentos';

  Future<int> insert(Medicamento medicamento) async {
    final db = await _databaseHelper.database;
    return await db.insert(tableName, medicamento.toMap());
  }

  Future<Medicamento?> getById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Medicamento.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Medicamento>> getAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((map) => Medicamento.fromMap(map)).toList();
  }

  Future<int> update(Medicamento medicamento) async {
    final db = await _databaseHelper.database;
    return await db.update(
      tableName,
      medicamento.toMap(),
      where: 'id = ?',
      whereArgs: [medicamento.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
