// ignore_for_file: avoid_print

import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APIHelper {
  static Future<String> apiGetRequest(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var response = await get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${prefs.getString("token")}",
      });
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '';
      }
    } on SocketException {
      print('SOCKET EXCEPTION OCCURRED');
      return '';
    } on FormatException {
      print('JSON FORMAT EXCEPTION OCCURRED');
      return '';
    } catch (e) {
      print('UNEXPECTED ERROR');
      print(e.toString());
      return '';
    }
  }

  static Future<String> apiPostRequest(String url, body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var response = await post(
        Uri.parse(url),
        body: body,
        headers: {
          "Authorization": "Bearer ${prefs.getString("token")}",
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '';
      }
    } on SocketException {
      log('SOCKET EXCEPTION OCCURRED');
      return '';
    } on FormatException {
      log('JSON FORMAT EXCEPTION OCCURRED');
      return '';
    } catch (e) {
      log('UNEXPECTED ERROR');
      log(e.toString());
      return '';
    }
  }
}
