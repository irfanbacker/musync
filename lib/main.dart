import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musync/Pages/host.dart';
import 'package:musync/Pages/client.dart';
import 'package:musync/spotifyservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter NSD Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
            elevation: 0.0,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String deviceName;
  int port;
  SharedPreferences prefs;
  SpotifyService spotifyService;

  @override
  void initState() {
    initSharedPrefs();
    super.initState();
  }

  void initSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    loadSharedPrefs();
  }

  void loadSharedPrefs() {
    deviceName = prefs.getString("deviceName") ?? "Device1";
    port = prefs.getInt("port") ?? 1819;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Musync"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showSettings(context);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MusyncHost(
                          deviceName: deviceName,
                          port: port,
                        )));
              },
              child: Text('Host'),
            ),
            SizedBox(
              height: 100,
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => NsdClient()));
              },
              child: Text('Client'),
            ),
          ],
        ),
      ),
    );
  }

  void showSettings(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: "Device name"),
                        initialValue: deviceName,
                        validator: (val) {
                          if (val.isEmpty) return "Device name cannot be empty";
                          return null;
                        },
                        onSaved: (val) {
                          deviceName = val;
                          prefs.setString("deviceName", val);
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Service port"),
                        initialValue: port.toString(),
                        keyboardType: TextInputType.numberWithOptions(
                            signed: false, decimal: false),
                        validator: (val) {
                          if (val.isEmpty) return "Port cannot be empty";
                          return null;
                        },
                        onSaved: (val) {
                          port = int.parse(val);
                          prefs.setInt("port", int.parse(val));
                        },
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      RaisedButton(
                        child: Text("Save"),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            Navigator.pop(context);
                          }
                        },
                      ),
                      SizedBox(
                        height: 15,
                      )
                    ],
                  )),
            ),
          );
        });
  }
}
