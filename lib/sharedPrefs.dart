import 'package:shared_preferences/shared_preferences.dart';

class Prefs{
  String deviceName;
  int port;
  SharedPreferences _data;

  Prefs(){
    initSharedPrefs();
  }

  void initSharedPrefs() async {
    _data = await SharedPreferences.getInstance();
    deviceName = _data.getString("deviceName") ?? "Device1";
    port = _data.getInt("port") ?? 1819;
  }

  void setPort(int newPort){
    port = newPort;
    _data.setInt("port", newPort);
  }

  void setDeviceName(String name){
    deviceName = name;
    _data.setString("deviceName", name);
  }
}