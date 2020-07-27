import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

Future<void> getAuthenticationToken() async {
  await DotEnv().load('.env');
  try {
    var authenticationToken = await SpotifySdk.getAuthenticationToken(
        clientId: DotEnv().env['CLIENT_ID'],
        redirectUrl: DotEnv().env['REDIRECT_URL'],
        scope:
        "app-remote-control, user-modify-playback-state, user-read-currently-playing");
    print("Got a token: $authenticationToken");
  } on PlatformException catch (e) {
    print("${e.code}, message: ${e.message}");
  } on MissingPluginException {
    print("not implemented");
  }
}