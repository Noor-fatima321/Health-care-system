import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _dbName = 'health_tracker.db';
  static final _dbVersion = 1;

  static final bloodPressureTable = 'blood_pressure';
  static final bloodSugarTable = 'blood_sugar';
  static final bmiTable = 'bmi';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // Blood Pressure Table
    await db.execute('''
      CREATE TABLE $bloodPressureTable (
        id INTEGER PRIMARY KEY,
        systolic INTEGER,
        diastolic INTEGER,
        date TEXT
      )
    ''');

    // Blood Sugar Table
    await db.execute('''
      CREATE TABLE $bloodSugarTable (
        id INTEGER PRIMARY KEY,
        level INTEGER,
        meal_time TEXT,
        date TEXT
      )
    ''');

    // BMI Table
    await db.execute('''
      CREATE TABLE $bmiTable (
        id INTEGER PRIMARY KEY,
        height REAL,
        weight REAL,
        bmi REAL,
        category TEXT,
        date TEXT
      )
    ''');
    await db.execute('''
  CREATE TABLE medication (
    id INTEGER PRIMARY KEY,
    name TEXT,
    dosage TEXT,
    time TEXT
  )
''');
  }

  // CRUD: Blood Pressure
  Future<int> insertBP(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(bloodPressureTable, row);
  }

  Future<List<Map<String, dynamic>>> getAllBP() async {
    Database db = await instance.database;
    return await db.query(bloodPressureTable, orderBy: 'date DESC');
  }

  // CRUD: Blood Sugar
  Future<int> insertSugar(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(bloodSugarTable, row);
  }

  Future<List<Map<String, dynamic>>> getAllSugar() async {
    Database db = await instance.database;
    return await db.query(bloodSugarTable, orderBy: 'date DESC');
  }

  // CRUD: BMI
  Future<int> insertBMI(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(bmiTable, row);
  }

  Future<List<Map<String, dynamic>>> getAllBMI() async {
    Database db = await instance.database;
    return await db.query(bmiTable, orderBy: 'date DESC');
  }
  Future<int> insertMedication(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('medication', row);
  }

  Future<List<Map<String, dynamic>>> getAllMedication() async {
    Database db = await instance.database;
    return await db.query('medication', orderBy: 'time ASC');
  }
}
