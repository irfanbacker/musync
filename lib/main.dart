import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musync/host/host.dart';
import 'package:musync/client/client.dart';
import 'package:musync/sharedPrefs.dart';
import 'package:provider/provider.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => Prefs(),
      lazy: false,
      child: MaterialApp(
        title: 'MuSync',
        theme: Theme.of(context).copyWith(
          cardColor: Colors.grey[300],
          primaryColor: Colors.amber,
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            color: Colors.amber[900],
          ),
          buttonTheme: ThemeData.dark().buttonTheme.copyWith(
                buttonColor: Colors.amber[900],
              ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData.dark().copyWith(
          appBarTheme: AppBarTheme(
            elevation: 0.0,
            color: Colors.black45,
            textTheme:
                ThemeData.dark().textTheme.apply(bodyColor: Colors.amberAccent),
            iconTheme:
                ThemeData.dark().iconTheme.copyWith(color: Colors.amberAccent),
          ),
          buttonTheme: ThemeData.dark().buttonTheme.copyWith(
                buttonColor: Colors.amber[900],
                textTheme: ButtonTextTheme.primary,
              ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        themeMode: ThemeMode.dark,
        home: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MuSync",
          style: TextStyle(fontSize: 20.0),
        ),
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
                  builder: (context) => MusyncHost(),
                ));
              },
              child: Text('Host'),
            ),
            SizedBox(
              height: 100,
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MusyncClient()));
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
                        initialValue: Provider.of<Prefs>(context).deviceName,
                        validator: (val) {
                          if (val.isEmpty) return "Device name cannot be empty";
                          return null;
                        },
                        onSaved: (val) => Provider.of<Prefs>(
                          context,
                          listen: false,
                        ).setDeviceName(val),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Service port"),
                        initialValue:
                            Provider.of<Prefs>(context).port.toString(),
                        keyboardType: TextInputType.numberWithOptions(
                            signed: false, decimal: false),
                        validator: (val) {
                          if (val.isEmpty) return "Port cannot be empty";
                          return null;
                        },
                        onSaved: (val) => Provider.of<Prefs>(
                          context,
                          listen: false,
                        ).setPort(int.parse(val)),
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
