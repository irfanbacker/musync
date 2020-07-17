import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:musync/servicebroadcast/service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final platform = const MethodChannel('io.irfan.musync');

  @override
  Widget build(BuildContext context) {
    platform.invokeMethod('acquireMulticastLock');
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: myHome(),
    );
  }
}

class myHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>NetworkService(type: 'host')));
              },
              child: Text('Host'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>NetworkService(type: 'client')));
              },
              child: Text('Client'),
            ),
          ],
        ),
      ),
    );
  }
}

