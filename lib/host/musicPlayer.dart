import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musync/spotifyservice.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:provider/provider.dart';

class SpotifyPlayer extends StatefulWidget {
  @override
  _SpotifyPlayerState createState() => _SpotifyPlayerState();
}

class _SpotifyPlayerState extends State<SpotifyPlayer> {
  SpotifyService _spotifyService;
  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    this._spotifyService = Provider.of<SpotifyService>(context);
    return Container(
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
            if (playerState == null) {
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
                      playerState.track.artist.name == null
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

class PlayerTimer extends StatefulWidget {
  final int currentTime;
  final int endTime;
  final bool isPlaying;

  PlayerTimer(this.currentTime, this.endTime, this.isPlaying);

  @override
  _PlayerTimerState createState() => _PlayerTimerState();
}

class _PlayerTimerState extends State<PlayerTimer> {
  int _time;
  int _changeInit;
  Timer playerTimer;

  @override
  void initState() {
    if (widget.endTime == null) {
      _time = null;
    } else {
      _time = widget.currentTime;
      startTimer();
    }
    super.initState();
  }

  void startTimer() {
    const period = const Duration(milliseconds: 100);
    playerTimer = Timer.periodic(
      period,
      (Timer timer) => setState(
        () {
          if (_time + 100 > widget.endTime) {
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
    if (_time == null) {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(),
                flex: 1,
              ),
              Text("00:00"),
              Expanded(
                child: Container(),
                flex: 9,
              ),
              Text("00:00"),
              Expanded(
                child: Container(),
                flex: 1,
              ),
            ],
          ),
          Slider(
            value: 0,
            onChanged: null,
            max: 100,
            min: 0.0,
          ),
        ],
      );
    }
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
          inactiveColor: Theme.of(context).primaryColor,
          activeColor: Theme.of(context).textTheme.caption.color,
          value: widget.isPlaying
              ? _time.toDouble()
              : widget.currentTime.toDouble(),
          onChanged: (change) {
            setState(() {
              _time = change.toInt();
            });
          },
          onChangeStart: (value) {
            setState(() {
              _changeInit = value.toInt();
            });
          },
          onChangeEnd: (value) async {
            bool status =
                await Provider.of<SpotifyService>(context, listen: false)
                    .playerSeekTo(value.toInt());
            if (!status) {
              setState(() {
                _time = _changeInit;
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text("Seek track error!")));
              });
            }
          },
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
