import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum StorageEnum {
  data,
  host,
  proprietario;
}

abstract interface class Storage {
  Future<void> save<T>({required StorageEnum key, required T value});
  Future<T?> get<T extends Object>(StorageEnum key);
  Future<void> delete(StorageEnum key);
}

class StorageSharedPreferences implements Storage {
  @override
  Future<void> save<T>({required StorageEnum key, required T value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key.name, jsonEncode({'data': value}));
  }

  @override
  Future<T?> get<T extends Object>(StorageEnum key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key.name);
    if (data == null) return null;
    return jsonDecode(data)['data'];
  }

  @override
  Future<void> delete(StorageEnum key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key.name);
  }
}
