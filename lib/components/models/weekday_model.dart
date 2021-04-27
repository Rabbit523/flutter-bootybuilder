class Weekday {
  int id;
  String name;

  Weekday();

  Weekday.fromMap(Map<String, dynamic> map) {
    id = int.parse(map['id'].toString());
    name = map['name'];
  }
}
