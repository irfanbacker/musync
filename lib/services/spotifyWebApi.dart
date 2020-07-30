import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:musync/models/queryModel.dart';

class SpotifyWebApi {
//  static SpotifyQuery _query;
//
//  static get query => _query;

  static Future<SpotifyQuery> searchTrack({@required String token, @required String queryString, int limit}) async {
    var queryParams = {
      "q": queryString,
      "type":"track",
      "market": "IN",
      "limit": limit==null ? "15" : limit.toString(),
    };
    var uri = Uri.https("api.spotify.com","/v1/search", queryParams);
    http.Response res = await http.get(uri, headers: {HttpHeaders.acceptHeader:"application/json", HttpHeaders.contentTypeHeader:"application/json", HttpHeaders.authorizationHeader: "Bearer "+token});
    if(res.statusCode == 200){
      var queryMap = json.decode(res.body);
      return SpotifyQuery.fromJson(queryMap);
    }
    else return null;
  }

}