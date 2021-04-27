import 'package:app/components/models/weekday_model.dart';

class Workout {
  int id;
  String title;
  String description;
  String file;
  int amountPerWeeks;
  List<Weekday> days;
  String productId;
  int subscribed;
  var key;

  int level1_work;
  int level1_rest;
  int level1_rounds;
  int level2_work;
  int level2_rest;
  int level2_rounds;
  int level3_work;
  int level3_rest;
  int level3_rounds;


  Workout();

  Workout.fromMap(Map<String, dynamic> map) {
    id = int.parse(map['id'].toString());
    title = map['title'];
    description = map['description'];
    file = map['file'];
    amountPerWeeks = int.parse(map['amount_weeks_program'].toString());

    level1_work = int.parse(map['level1_work'].toString());
    level1_rest = int.parse(map['level1_rest'].toString());
    level1_rounds = int.parse(map['level1_rounds'].toString());
    level2_work = int.parse(map['level2_work'].toString());
    level2_rest = int.parse(map['level2_rest'].toString());
    level2_rounds = int.parse(map['level2_rounds'].toString());
    level3_work = int.parse(map['level3_work'].toString());
    level3_rest = int.parse(map['level3_rest'].toString());
    level3_rounds = int.parse(map['level3_rounds'].toString());

    subscribed = int.parse(map['subscribed'].toString());
    productId = map['productId'];
    days = new List<Weekday>();
    var _days = map['weekdays'];
    if (_days != null) {
      for (var i = 0; i < _days.length; i++) {
        days.add(Weekday.fromMap(_days[i]));
      }
    }
  }

  bool isNeedPurchase() {
    return subscribed > 0 && productId != null && productId != "";
  }
}
