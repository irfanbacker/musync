import 'package:flutter/material.dart';
import 'package:musync/host/playerTimer.dart';
import 'package:musync/services/spotifyservice.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:provider/provider.dart';

class SpotifyLayout extends StatefulWidget {
  @override
  _SpotifyLayoutState createState() => _SpotifyLayoutState();
}

class _SpotifyLayoutState extends State<SpotifyLayout> {
  SpotifyService _spotifyService;
  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    this._spotifyService = Provider.of<SpotifyService>(context);
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                      child: Text("Connect"),
                      onPressed: () async {
                        bool res = await _spotifyService.connectToSpotify();
                        setState(() {
                          _isConnected = res;
                        });
                        if (!res)
                          Scaffold.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Wrap(
                                alignment: WrapAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Connection Failed!",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                  Text(
                                    "Check your Internet connection and make sure Spotify is installed",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              )));
                      }),
                  RaisedButton(
                    child: Text("Logout"),
                    onPressed: () async {
                      bool res = await _spotifyService.logout();
                      setState(() {
                        _isConnected = res;
                      });
                    },
                  ),
                ],
              ),
            ),
            _isConnected
                ? SpotifyPlayerInterface()
                : Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(child: Text("Spotify not connected!")),
                    )),
          ],
        ),
      ),
    );
  }
}

class SpotifyPlayerInterface extends StatefulWidget {
  @override
  _SpotifyPlayerInterfaceState createState() => _SpotifyPlayerInterfaceState();
}

class _SpotifyPlayerInterfaceState extends State<SpotifyPlayerInterface> {
  SpotifyService _spotifyService;

  @override
  Widget build(BuildContext context) {
    _spotifyService = Provider.of<SpotifyService>(context);
    return Container(
      padding: EdgeInsets.all(10.0),
      child: StreamBuilder<PlayerState>(
          stream: _spotifyService.getPlayerStateStream(),
          builder: (context, snapshot) {
            PlayerState playerState = snapshot.data;
            if (!snapshot.hasData) {
              return Container(
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(child: CircularProgressIndicator()),
                    )),
              );
            } else
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        playerState.isPaused
                            ? IconButton(
                                icon: Icon(Icons.play_arrow),
                                onPressed: () async {
                                  await _spotifyService.resumePlayback();
                                },
                              )
                            : IconButton(
                                icon: Icon(Icons.pause),
                                onPressed: () async {
                                  await _spotifyService.pausePlayback();
                                },
                              ),
                      ],
                    ),
                    Wrap(
                      children: [
                        Text(
                          playerState.track == null
                              ? ""
                              : playerState.track.name,
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                    Text(
                      playerState.track?.artist?.name == null
                          ? ""
                          : playerState?.track?.artist?.name,
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                    Builder(
                        key: Key(playerState.playbackPosition.toString()),
                        builder: (context) {
                          return PlayerTimer(
                              playerState.playbackPosition,
                              playerState.track == null
                                  ? null
                                  : playerState.track.duration,
                              !playerState.isPaused);
                        }),
                  ],
                ),
              );
          }),
    );
  }
}
