import 'dart:async';
import 'package:http/http.dart' as http;

const baseUrl = "https://api.sledilnik.org/api";

class API {
  static Future getStats() {
    var url = baseUrl + "/stats";
    return http.get(url);
  }
}
