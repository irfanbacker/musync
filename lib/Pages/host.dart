import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musync/nsd_service.dart';
import 'package:musync/spotifyservice.dart';
import 'package:musync/widgets/musicPlayer.dart';

class MusyncHost extends StatefulWidget {
  final String deviceName;
  final int port;
  final String serviceType;
  final String serviceName;

  MusyncHost(
      {@required this.deviceName,
      @required this.port,
      this.serviceType,
      this.serviceName});

  @override
  _MusyncHostState createState() => _MusyncHostState();
}

class _MusyncHostState extends State<MusyncHost> {
  NetworkDiscovery nsdHost;
  SpotifyService _spotifyService;

  @override
  void initState() {
    nsdHost = NetworkDiscovery();
    _spotifyService = SpotifyService();
    //Passing NULL values for non-required fields takes default value
    nsdHost.startAdvertise(
        deviceName: widget.deviceName,
        port: widget.port,
        serviceNameNSD: widget.serviceName,
        serviceTypeNSD: widget.serviceType);
    super.initState();
  }

  Future<bool> showConfirmation() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content: Text("The Host service will be stopped"),
          actions: <Widget>[
            OutlineButton(
              child: Text("Yes"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            OutlineButton(
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
      child: Scaffold(
        appBar: AppBar(
          title: Text("Service Host"),
          centerTitle: true,
        ),
        body: SpotifyPlayer(_spotifyService),
      ),
    );
  }

  @override
  void dispose() {
    _spotifyService.logout();
    nsdHost.stopAdvertise();
    super.dispose();
  }
}
