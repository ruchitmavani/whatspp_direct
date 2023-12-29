import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  late SharedPreferences _sharedPrefs;

  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  set updateLater(String value) => _sharedPrefs.setString('updateLater', value);

  String get updateLater => _sharedPrefs.getString('updateLater') ?? '';

  set versions(String value) => _sharedPrefs.setString('versions', value);

  String get versions => _sharedPrefs.getString('versions') ?? '';

}

final sharedPrefs = SharedPrefs();
