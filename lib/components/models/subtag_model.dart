class SubTag {
  int id;
  String name;

  SubTag();

  SubTag.fromMap(Map<String, dynamic> map) {
    id = int.parse(map['id'].toString());
    name = map['name'];
  }
}
