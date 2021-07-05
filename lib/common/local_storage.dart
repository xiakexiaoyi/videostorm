import 'package:shared_preferences/shared_preferences.dart';

///SharedPreferences 本地存储
class LocalStorage {

  static Future<bool> save(String key, value) async {
    print('SP保存：'+key+" "+value.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
   return prefs.setString(key, value);
  }

  static get(String key) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('SP获取：'+key+'   '+prefs.get(key).toString());
    return prefs.get(key);
  }

  static remove(String key) async {
    print('SP移除：'+key);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
