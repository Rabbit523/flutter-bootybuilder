import 'package:app/components/models/tag_model.dart';

class WorkoutCategory {
  int id;
  String title;

  WorkoutCategory();

  WorkoutCategory.fromMap(Map<String, dynamic> map) {
    id = int.parse(map['id'].toString());
    title = map['title'];
  }
}
