import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musync/host/musicPlayer.dart';
import 'package:musync/nsd_service.dart';
import 'package:musync/sharedPrefs.dart';
import 'package:musync/spotifyservice.dart';
import 'package:provider/provider.dart';

class MusyncHost extends StatefulWidget {
  final String serviceName = "io.irfan.NSD.musync";

  @override
  _MusyncHostState createState() => _MusyncHostState();
}

class _MusyncHostState extends State<MusyncHost> {
  NetworkDiscovery nsdHost;
  SpotifyService _spotifyService;

  @override
  void initState() {
    nsdHost = NetworkDiscovery();
    //Passing NULL values for non-required fields takes default value
    nsdHost.startAdvertise(
        deviceName: Provider.of<Prefs>(context, listen: false).deviceName,
        port: Provider.of<Prefs>(context, listen: false).port,
        serviceNameNSD: widget.serviceName,
    );
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => initSpotify());
  }


  void initSpotify() async {
    bool status=false;
    if (Provider.of<SpotifyService>(context, listen: false).authToken == null)
      status = await Provider.of<SpotifyService>(context, listen: false)
          .getAuthenticationToken();
    if (status == false){
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Authentication Error"),
            content: Text("The authentication has failed!"),
            actions: <Widget>[
              RaisedButton(
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
            RaisedButton(
              child: Text("Yes"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            RaisedButton(
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
    _spotifyService = Provider.of<SpotifyService>(context);
    return WillPopScope(
      onWillPop: showConfirmation,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Music Host"),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(flex: 2,child: SpotifyPlayer()),
            Flexible(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Placeholder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _spotifyService?.logout();
    nsdHost.stopAdvertise();
    super.dispose();
  }
}
