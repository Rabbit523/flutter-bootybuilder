import 'package:app/components/models/tag_model.dart';

class Category {
  int id;
  String title;
  String description;
  String file;
  int checkedQRCode;
  List<Tag> tags;
  int totalExercises;

  var key;

  Category();

  Category.fromMap(Map<String, dynamic> map) {
    id = int.parse(map['id'].toString());
    title = map['title'];
    description = map['description'];
    file = map['file'];
    checkedQRCode = int.parse(map['checked_qrcode'].toString());
    totalExercises = int.parse(map['total_exercise'].toString());
    tags = new List<Tag>();
    var _tags = map['tags'];
    if (_tags != null) {
      for (var i = 0; i < _tags.length; i++) {
        tags.add(Tag.fromMap(_tags[i]));
      }
    }
  }
}
