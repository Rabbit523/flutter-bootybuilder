import 'package:app/components/models/exercise_model.dart';
import 'package:sqflite/sqflite.dart';

class MyWorkoutModel {
  int id;
  String name;
  String file;
  List<ExerciseModel> exercises;
  var key;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'file': file,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  MyWorkoutModel();

  MyWorkoutModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    file = map['file'];
  }

  static Future<MyWorkoutModel> insert(Database db, MyWorkoutModel data) async {
    data.id = await db.insert('my_workouts', data.toMap());
    return data;
  }

  static Future<MyWorkoutModel> getItem(Database db, int id) async {
    List<Map> maps = await db.query('my_workouts',
        columns: ['id', 'name', 'file'], where: 'id = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return MyWorkoutModel.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> delete(Database db, int id) async {
    return await db.delete('my_workouts', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> update(Database db, MyWorkoutModel data) async {
    return await db.update('my_workouts', data.toMap(),
        where: 'id = ?', whereArgs: [data.id]);
  }

  static Future<List<MyWorkoutModel>> getItems(Database db) async {
    List<Map> maps =
        await db.query('my_workouts', columns: ['id', 'name', 'file']);
    if (maps.length > 0) {
      List<MyWorkoutModel> workouts = new List<MyWorkoutModel>();
      for (var i = 0; i < maps.length; i++) {
        var workout = MyWorkoutModel.fromMap(maps[i]);
        var exercises = await ExerciseModel.getItems(db, workout.id);
        if (exercises != null) {
          workout.exercises = exercises;
        } else {
          workout.exercises = [];
        }

        workouts.add(workout);
      }
      return workouts;
    }
    return null;
  }
}
