import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musync/spotifyservice.dart';
import 'package:spotify_sdk/models/player_state.dart';

class SpotifyPlayer extends StatefulWidget {
  final SpotifyService _spotifyService;

  SpotifyPlayer(this._spotifyService) {
    if (_spotifyService.authToken == null)
      _spotifyService.getAuthenticationToken();
  }

  @override
  _SpotifyPlayerState createState() => _SpotifyPlayerState();
}

class _SpotifyPlayerState extends State<SpotifyPlayer> {
  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                  child: Text("Connect"),
                  onPressed: () async {
                    bool res = await widget._spotifyService.connectToSpotify();
                    setState(() {
                      _isConnected = res;
                    });
                  }),
              RaisedButton(
                child: Text("Logout"),
                onPressed: () async {
                  bool res = await widget._spotifyService.logout();
                  setState(() {
                    _isConnected = res;
                  });
                },
              ),
            ],
          ),
          _isConnected
              ? SpotifyPlayerInterface(widget._spotifyService)
              : Center(child: Text("Spotify not connected!")),
        ],
      ),
    );
  }
}

class SpotifyPlayerInterface extends StatefulWidget {
  final SpotifyService _spotifyService;

  SpotifyPlayerInterface(this._spotifyService) {
    if (_spotifyService.authToken == null)
      _spotifyService.getAuthenticationToken();
  }

  @override
  _SpotifyPlayerInterfaceState createState() => _SpotifyPlayerInterfaceState();
}

class _SpotifyPlayerInterfaceState extends State<SpotifyPlayerInterface> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: StreamBuilder<PlayerState>(
          stream: widget._spotifyService.getPlayerStateStream(),
          builder: (context, snapshot) {
            PlayerState playerState = snapshot.data;
            if (playerState.track.artist.name == null)
              return Container(
                child: Center(child: Text("Advertisement")),
              );
            else
              return Card(
                color: Colors.grey[300],
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        playerState.isPaused
                            ? IconButton(
                                icon: Icon(Icons.play_arrow),
                                hoverColor: Colors.grey[500],
                                onPressed: () async {
                                  await widget._spotifyService.resumePlayback();
                                },
                              )
                            : IconButton(
                                icon: Icon(Icons.pause),
                                hoverColor: Colors.grey[500],
                                onPressed: () async {
                                  await widget._spotifyService.pausePlayback();
                                },
                              ),
                      ],
                    ),
                    Wrap(
                      children: [Text(playerState.track.name)],
                    ),
                    Text(playerState.track.artist.name, style: Theme.of(context).textTheme.caption,),
                    Builder(
                        key: Key(playerState.playbackPosition.toString()),
                        builder: (context) {
                          return PlayerTimer(
                              playerState.playbackPosition,
                              playerState.track.duration,
                              !playerState.isPaused);
                        }),
                  ],
                ),
              );
          }),
    );
  }
}

class PlayerTimer extends StatefulWidget {
  int currentTime;
  int endTime;
  bool isPlaying;

  PlayerTimer(this.currentTime, this.endTime, this.isPlaying) {
    print("timer created");
  }

  @override
  _PlayerTimerState createState() => _PlayerTimerState();
}

class _PlayerTimerState extends State<PlayerTimer> {
  int _time;
  Timer playerTimer;

  @override
  void initState() {
    _time = widget.currentTime;
    startTimer();
    super.initState();
  }

  void startTimer() {
    const period = const Duration(milliseconds: 100);
    playerTimer = Timer.periodic(
      period,
      (Timer timer) => setState(
        () {
          if (_time > widget.endTime) {
            _time = widget.endTime;
            timer.cancel();
          } else {
            if (widget.isPlaying) _time = _time + 100;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    playerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(),
              flex: 1,
            ),
            widget.isPlaying
                ? Text(_printDuration(_time))
                : Text(_printDuration(widget.currentTime)),
            Expanded(
              child: Container(),
              flex: 9,
            ),
            Text(_printDuration(widget.endTime)),
            Expanded(
              child: Container(),
              flex: 1,
            ),
          ],
        ),
        Slider(
          value: widget.isPlaying
              ? _time.toDouble()
              : widget.currentTime.toDouble(),
          onChanged: null,
          max: widget.endTime.toDouble(),
          min: 0.0,
        ),
      ],
    );
  }

  String _printDuration(int ms) {
    Duration duration = Duration(milliseconds: ms);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes);
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
