import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musync/services/spotifyservice.dart';
import 'package:provider/provider.dart';

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
          SliderTheme(
            data: Theme.of(context).sliderTheme.copyWith(
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.0, disabledThumbRadius: 7.0),
            ),
            child: Slider(
              value: 0,
              onChanged: null,
              max: 100,
              min: 0.0,
            ),
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
        SliderTheme(
          data: Theme.of(context).sliderTheme.copyWith(
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.0, disabledThumbRadius: 7.0),
          ),
          child: Slider(
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
