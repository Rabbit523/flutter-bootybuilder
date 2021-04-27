import 'package:http/http.dart' as http;

class APIManager {
  static const APIURL = "https://api.appadmin.bootybuilder.com";

  static final APIManager _singleton = APIManager._internal();

  factory APIManager() {
    return _singleton;
  }

  APIManager._internal();

  Future<http.Response> getCategories(page, size) {
    return http.get(
        '$APIURL/api/get_categories?sort=title&page=$page&per_page=$size');
  }

  Future<http.Response> increaseView(id) {
    return http.get('$APIURL/api/increase_views?id=$id');
  }

  Future<http.Response> getExercisesFromTag(tag, page, size) {
    return http.get(
        '$APIURL/api/get_exercise_from_tag?tag_id=$tag&page=$page&per_page=$size');
  }

  Future<http.Response> getExercisesFromDay(day, page, size) {
    return http.get(
        '$APIURL/api/get_exercise_from_day?weekday_id=$day&page=$page&per_page=$size');
  }

  Future<http.Response> getExercisesFromQRCode(page, size) {
    return http.get(
        '$APIURL/api/get_categories_qrcode_checked?sort=title&page=$page&per_page=$size');
  }

  Future<http.Response> getWorkouts(hasTimer, category, page, size) {
    return http.get(
        '$APIURL/api/get_workouts?sort=title&page=$page&per_page=$size&has_timer=$hasTimer&category=$category');
  }

  Future<http.Response> getWorkoutCategories(hasTimer) {
    return http.get(
        '$APIURL/api/get_workout_categories?has_timer=$hasTimer');
  }

  Future<http.Response> getTimerCategories() {
    return http.get(
        '$APIURL/api/get_settings_app');
  }


  String getPath(path) {
    if (path != null) {
      return '$APIURL/$path';
    }
    return 'https://appadmin.bootybuilder.com/assets/img/bg.1d22c4f1.jpg';
  }
}
