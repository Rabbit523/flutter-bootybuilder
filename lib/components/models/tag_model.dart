import 'package:app/components/models/subtag_model.dart';

class Tag {
  int id;
  String name;
  bool hasSubtag;
  List<SubTag> subtags;

  Tag();

  Tag.fromMap(Map<String, dynamic> map) {
    id = int.parse(map['id'].toString());
    name = map['name'];
    subtags = new List<SubTag>();
    hasSubtag = map['has_subtags'] as bool;
    var _subtags = map['subtags'];
    if (_subtags != null) {
      for (var i = 0; i < _subtags.length; i++) {
        subtags.add(SubTag.fromMap(_subtags[i]));
      }
    }
  }
}
