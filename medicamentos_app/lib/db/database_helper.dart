import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'medicamentos.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicamentos ( -- Cambiado de 'medicamento' a 'medicamentos' para consistencia
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,       -- Asegurarse de NOT NULL si es requerido
        descripcion TEXT,
        cantidad INTEGER,
        dosis REAL,
        estado INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE horarios ( -- Cambiado de 'horario' a 'horarios' para consistencia
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        intervalo REAL NOT NULL, -- Asegurarse de NOT NULL
        hora TEXT NOT NULL,      -- Asegurarse de NOT NULL
        medicamentoId INTEGER NOT NULL, -- Asegurarse de NOT NULL
        FOREIGN KEY (medicamentoId) REFERENCES medicamentos(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE registros_toma ( -- Cambiado de 'registro_toma' a 'registros_toma' para consistencia
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicamentoId INTEGER NOT NULL,     -- ID del medicamento asociado
        horarioId INTEGER NOT NULL,         -- ID del horario asociado
        fechaHoraEsperada TEXT NOT NULL,    -- La hora a la que debía tomarse
        fechaHoraReal TEXT,                 -- La hora en que se registró (puede ser null para pendiente)
        estado TEXT NOT NULL,               -- 'Tomado', 'Omitido', etc. (TEXTO)
        FOREIGN KEY (medicamentoId) REFERENCES medicamentos(id) ON DELETE CASCADE,
        FOREIGN KEY (horarioId) REFERENCES horarios(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS registro_toma');
      await db.execute('DROP TABLE IF EXISTS medicamentos');
      await db.execute('DROP TABLE IF EXISTS horarios');

      await _onCreate(db, newVersion);
    }
  }
}
