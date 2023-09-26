import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum StorageEnum {
  data;
}

class Storage {
  Future<void> save<T>({required StorageEnum key, required T value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key.name, jsonEncode({'data': value}));
  }

  Future<T?> get<T>(StorageEnum key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key.name);
    if (data == null) return null;
    return jsonDecode(data)['data'];
  }
}
