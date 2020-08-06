import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musync/client/spotifySearch.dart';
import 'package:musync/host/musicPlayer.dart';
import 'package:musync/services/sharedPrefs.dart';
import 'package:musync/services/spotifyservice.dart';
import 'package:provider/provider.dart';
import 'package:bonsoir/bonsoir.dart';

class MusyncHost extends StatefulWidget {
  @override
  _MusyncHostState createState() => _MusyncHostState();
}

class _MusyncHostState extends State<MusyncHost> {
  BonsoirBroadcast nsdHost;
  SpotifyService _spotifyService;

  @override
  void initState() {
    nsdHost = BonsoirBroadcast(
      service: BonsoirService(
        name: Provider.of<Prefs>(context, listen: false).deviceName,
        type: '_musync._tcp',
        port: Provider.of<Prefs>(context, listen: false).port,
      ),
    );
    _spotifyService = SpotifyService();
    initSpotify();
    serviceBroadcast();
    super.initState();
  }

  void serviceBroadcast() async {
    await nsdHost.ready;
    await nsdHost.start();
  }

  void initSpotify() async {
    bool status = false;
    if (_spotifyService.authToken == null)
      status = await _spotifyService.getAuthenticationToken();
    if (status != true) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Authentication Error"),
            content: Text("The authentication has failed!"),
            actions: <Widget>[
              FlatButton(
                child: Text("Go Back"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      Navigator.of(context).pop();
    }
  }

  Future<bool> showConfirmation() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content: Text("The Host service will be stopped"),
          actions: <Widget>[
            FlatButton(
              child: Text("Yes"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            FlatButton(
              child: Text("No"),
              onPressed: () => Navigator.of(context).pop(false),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: showConfirmation,
      child: Provider<SpotifyService>.value(
        value: _spotifyService,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Music Host"),
            centerTitle: true,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(flex: 2, child: SpotifyLayout()),
              Flexible(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      RaisedButton(
                        elevation: 0.0,
                        child: Text("Select song"),
                        onPressed: () async {
                          String uri = await showSearch(
                              context: context,
                              delegate: SpotifySearch(
                                  token: this._spotifyService.authToken));
                          await _spotifyService.playUri(uri);
                        },
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _spotifyService?.logout();
    nsdHost.stop();
    super.dispose();
  }
}
