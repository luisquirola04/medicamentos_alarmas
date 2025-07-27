// lib/data/horario_dao.dart
import 'package:medicamentos_app/db/database_helper.dart';
import 'package:medicamentos_app/models/horario.dart';

class HorarioDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  static const String tableName = 'horarios';

  Future<int> insert(Horario horario) async {
    final db = await _databaseHelper.database;

    return await db.insert(tableName, horario.toMap());
  }

  /// Obtiene un Horario por su ID.
  Future<Horario?> getById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Horario.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Horario>> getByMedicamentoId(int medicamentoId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      tableName,
      where: 'medicamentoId = ?',
      whereArgs: [medicamentoId],
    );
    return maps.map((e) => Horario.fromMap(e)).toList();
  }

  Future<int> update(Horario horario) async {
    if (horario.id == null) {
      print(
        "Error: No se puede actualizar un Horario sin ID. Objeto: ${horario.toMap()}",
      );

      return 0;
    }

    final db = await _databaseHelper.database;
    return await db.update(
      tableName,
      horario.toMap(),
      where: 'id = ?',
      whereArgs: [horario.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
