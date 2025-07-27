import 'package:medicamentos_app/models/registro_toma.dart';
import 'package:sqflite/sqflite.dart';
import 'package:medicamentos_app/db/database_helper.dart';
import 'package:medicamentos_app/models/estado_toma.dart';

class RegistroTomaDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  static const String tableName = 'registros_toma';
  static const String columnId = 'id';
  static const String columnMedicamentoId = 'medicamentoId';
  static const String columnHorarioId = 'horarioId';
  static const String columnFechaHoraEsperada = 'fechaHoraEsperada';
  static const String columnFechaHoraReal = 'fechaHoraReal';
  static const String columnEstado = 'estado';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnMedicamentoId INTEGER NOT NULL,
        $columnHorarioId INTEGER NOT NULL,
        $columnFechaHoraEsperada TEXT NOT NULL,
        $columnFechaHoraReal TEXT,
        $columnEstado TEXT NOT NULL,
        FOREIGN KEY ($columnMedicamentoId) REFERENCES medicamentos(id) ON DELETE CASCADE,
        FOREIGN KEY ($columnHorarioId) REFERENCES horarios(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertRegistroToma(RegistroToma registro) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      tableName,
      registro.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateRegistroToma(RegistroToma registro) async {
    final db = await _databaseHelper.database;
    return await db.update(
      tableName,
      registro.toMap(),
      where: '$columnId = ?',
      whereArgs: [registro.id],
    );
  }

  Future<List<RegistroToma>> getRegistrosToma() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    return List.generate(maps.length, (i) {
      return RegistroToma.fromMap(maps[i]);
    });
  }

  Future<List<RegistroToma>> getRegistrosByMedicamentoId(
    int medicamentoId,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnMedicamentoId = ?',
      whereArgs: [medicamentoId],
      orderBy: '$columnFechaHoraEsperada DESC',
    );
    return List.generate(maps.length, (i) {
      return RegistroToma.fromMap(maps[i]);
    });
  }

  Future<RegistroToma?> getRegistroById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return RegistroToma.fromMap(maps.first);
    }
    return null;
  }
}
