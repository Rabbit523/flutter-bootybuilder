import 'package:sqflite/sqflite.dart';

class Repository {
  static String dbName = "bootybuilder.db";
  Database db;

  static final Repository _singleton = Repository._internal();

  factory Repository() {
    return _singleton;
  }

  Repository._internal();

  Future open() async {
    db = await openDatabase(dbName, version: 2, onConfigure: onConfigure,
        onCreate: (db, version) async {
      var batch = db.batch();
      // We create all the tables
      _createTableMyWorkouts(batch);
      _createTableExercises(batch);
      await batch.commit();
    }, onUpgrade: (db, oldVersion, newVersion) {});
  }

  Future close() async {
    if (db != null) {
      await db.close();
    }
  }

  /// Let's use FOREIGN KEY constraints
  Future onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  void _createTableMyWorkouts(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS my_workouts');
    batch.execute('''CREATE TABLE my_workouts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    file TEXT
)''');
  }

  void _createTableExercises(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS exercises');
    batch.execute('''CREATE TABLE exercises (
    id INTEGER,
    title TEXT,
    description TEXT,
    series INTEGER,
    repetitions INTEGER,
    format_id INTEGER,
    file TEXT,
    thumbnail TEXT,
    workout_id INTEGER,
    video_length TEXT,
    FOREIGN KEY (workout_id) REFERENCES my_workouts(id) ON DELETE CASCADE
)''');
  }
}
