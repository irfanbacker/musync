import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyService {
  String _clientID;
  String _redirectURL;
  String _authToken;
  bool _isConnected = false;

  String get clientID => _clientID;
  String get redirectURL => _redirectURL;
  String get authToken => _authToken;

  Future<bool> getAuthenticationToken() async {
    await DotEnv().load('.env');
    _clientID = DotEnv().env['CLIENT_ID'];
    _redirectURL = DotEnv().env['REDIRECT_URL'];
    bool status = false;
    try {
      _authToken = await SpotifySdk.getAuthenticationToken(
          clientId: _clientID,
          redirectUrl: _redirectURL,
          scope: "app-remote-control, user-modify-playback-state, user-read-currently-playing"
      );
      print(_authToken);
      status = true;
    } on PlatformException catch (e) {
      print("${e.code}, message: ${e.message}");
    } on MissingPluginException {
      print("Function not implemented");
    }
    return status;
  }

  Future<bool> connectToSpotify() async {
      try{
        _isConnected = await SpotifySdk.connectToSpotifyRemote(clientId: _clientID, redirectUrl: _redirectURL);
      } on PlatformException catch(e){
        print("${e.code}, message: ${e.message}");
      } on MissingPluginException {
        print("Function not implemented");
      }
      return _isConnected;
  }

  Stream<PlayerState> getPlayerStateStream() {
    return SpotifySdk.subscribePlayerState();
  }

  Future<void> playUri(String uri) async {
    await SpotifySdk.play(spotifyUri: uri);
  }

  Future<void> resumePlayback() async {
    if(_isConnected){
      try{
        await SpotifySdk.resume();
      } on PlatformException catch(e){
        print("${e.code}, message: ${e.message}");
      } on MissingPluginException {
        print("Function not implemented");
      }
    }
    else print("Not connected!");
  }

  Future<void> pausePlayback() async {
    if(_isConnected){
      try{
        await SpotifySdk.pause();
      } on PlatformException catch(e){
        print("${e.code}, message: ${e.message}");
      } on MissingPluginException {
        print("Function not implemented");
      }
    }
    else print("Not connected!");
  }

  Future<bool> playerSeekTo(int value) async {
    bool status = false;
    if(_isConnected){
      try{
        await SpotifySdk.seekTo(positionedMilliseconds: value);
        status=true;
      } on PlatformException catch(e){
        print("${e.code}, message: ${e.message}");
      } on MissingPluginException {
        print("Function not implemented");
      }
    }
    else print("Not connected!");
    return status;
  }

  Stream<PlayerContext> subscribePlayerContext() {
    if(_isConnected){
      try{
        return SpotifySdk.subscribePlayerContext();
      } on PlatformException catch(e){
        print("${e.code}, message: ${e.message}");
      } on MissingPluginException {
        print("Function not implemented");
      }
    }
    else print("Not connected!");
    return null;
  }

  Future<bool> logout() async {
    if(_isConnected){
      await pausePlayback();
      try{
        await SpotifySdk.logout();
        _isConnected = false;
      } on PlatformException {
        print("Logout error");
      } on MissingPluginException{
        print("Function not implemented");
      }
    }
    else print("Not already connected!");
    return _isConnected;
  }

}