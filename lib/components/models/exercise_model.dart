import 'package:sqflite/sqflite.dart';

class ExerciseModel {
  int id;
  String title;
  String description;
  int series;
  int repetitions;
  String file;
  String thumbnail;
  int workoutId;
  int formatID;
  int videoLength;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'description': description,
      'series': series,
      'repetitions': repetitions,
      'format_id': formatID,
      'file': file,
      'thumbnail': thumbnail,
      'workout_id': workoutId,
      'video_length': videoLength,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  ExerciseModel();

  ExerciseModel.fromMap(Map<String, dynamic> map) {
    id = int.parse(map['id'].toString());
    title = map['title'];
    description = map['description'];
    series = int.parse(map['series'].toString());
    repetitions = int.parse(map['repetitions'].toString());
    formatID = int.parse(map['format_id'].toString());
    file = map['file'];
    thumbnail = map['thumbnail'];
    workoutId = map['workout_id'];
    var _videoLength = map['video_length'];

    if (_videoLength == null) {
      videoLength = 10;
    } else {
      try {
        videoLength = int.parse(_videoLength.toString());
      } catch(Exception) {
        videoLength = 10;
      }

    }
  }

  static Future<ExerciseModel> insert(Database db, ExerciseModel data) async {
    data.id = await db.insert('exercises', data.toMap());
    return data;
  }

  static Future<ExerciseModel> getItem(Database db, int id) async {
    List<Map> maps = await db.query('exercises',
        columns: [
          'id',
          'title',
          'description',
          'series',
          'repetitions',
          'format_id',
          'file',
          'thumbnail',
          'workout_id',
          'video_length'
        ],
        where: 'id = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return ExerciseModel.fromMap(maps.first);
    }
    return null;
  }

  static Future<bool> exist(Database db, int workout, int id) async {
    List<Map> maps = await db.query('exercises',
        columns: [
          'id',
          'title',
          'description',
          'series',
          'repetitions',
          'format_id',
          'file',
          'thumbnail',
          'workout_id',
          'video_length'
        ],
        where: 'workout_id = ? and id = ?',
        whereArgs: [workout, id]);
    if (maps.length > 0) {
      return true;
    }
    return false;
  }

  static Future<int> delete(Database db, int id, int workout) async {
    return await db.delete('exercises',
        where: 'id = ? and workout_id = ?', whereArgs: [id, workout]);
  }

  static Future<int> update(Database db, ExerciseModel data) async {
    return await db.update('exercises', data.toMap(),
        where: 'id = ?', whereArgs: [data.id]);
  }

  static Future<List<ExerciseModel>> getItems(Database db, int id) async {
    List<Map> maps = await db.query('exercises',
        columns: [
          'id',
          'title',
          'description',
          'series',
          'repetitions',
          'format_id',
          'file',
          'thumbnail',
          'workout_id',
          'video_length'
        ],
        where: 'workout_id = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      List<ExerciseModel> exercises = new List<ExerciseModel>();
      for (var i = 0; i < maps.length; i++) {
        exercises.add(ExerciseModel.fromMap(maps[i]));
      }
      return exercises;
    }
    return null;
  }
}
