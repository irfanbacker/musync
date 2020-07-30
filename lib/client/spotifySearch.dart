import 'package:flutter/material.dart';
import 'package:musync/models/queryModel.dart';
import 'package:musync/services/spotifyWebApi.dart';

class SpotifySearch extends SearchDelegate<String> {
  String token;

  SpotifySearch({@required this.token});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.copyWith(
            headline6: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontSize: 16.0, fontWeight: FontWeight.normal)));
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop());
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query != "")
        IconButton(icon: Icon(Icons.clear), onPressed: () => query = ""),
      IconButton(
          icon: Icon(Icons.search),
          onPressed: () => this.showResults(context))
    ];
  }

  Future<SpotifyQuery> getQuery(BuildContext context) async {
    SpotifyQuery q = await SpotifyWebApi.searchTrack(
        token: token, queryString: query, limit: 15);
    if (q == null)
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Error!")));
    return q;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query != "") {
      return FutureBuilder(
        future: getQuery(context),
        builder: (context, AsyncSnapshot<SpotifyQuery> snapshot) {
          if (snapshot.hasData) {
            SpotifyQuery q = snapshot.data;
            return ListView.builder(
              padding: const EdgeInsets.all(2.0),
              itemCount: q.tracks.items.length,
              itemBuilder: (context, index) {
                String artists = "";
                if (q.tracks.items[index].artists.length == 1)
                  artists =
                      q.tracks.items[index].artists.first.name;
                else
                  q.tracks.items[index].artists.forEach((element) {
                    if (element.name !=
                        q.tracks.items[index].artists.first.name)
                      return artists += (", " + element.name);
                    else
                      return artists += element.name;
                  });
                return Wrap(
                  children: [
                    Card(
                      child: ListTile(
                        key: Key(q.tracks.items[index].uri),
                        title: Text(q.tracks.items[index].name),
                        subtitle: Text(artists),
                        leading: Image.network(q.tracks.items[index].album.images.last.url),
                        onTap: () {
                          this.close(context, q.tracks.items[index].uri);
                        },
                      ),
                    )
                  ],
                );
              },
            );
          }else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      );
    }
    return Container();
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query != "") {
      return FutureBuilder(
        future: getQuery(context),
        builder: (context, AsyncSnapshot<SpotifyQuery> snapshot) {
          if (snapshot.hasData) {
            SpotifyQuery q = snapshot.data;
            return ListView.builder(
              padding: const EdgeInsets.all(2.0),
              itemCount: q.tracks.items.length,
              itemBuilder: (context, index) {
                String artists = "";
                if (q.tracks.items[index].artists.length == 1)
                  artists =
                      q.tracks.items[index].artists.first.name;
                else
                  q.tracks.items[index].artists.forEach((element) {
                    if (element.name !=
                        q.tracks.items[index].artists.first.name)
                      return artists += (", " + element.name);
                    else
                      return artists += element.name;
                  });
                return Wrap(
                  children: [
                    Card(
                      child: ListTile(
                        key: Key(q.tracks.items[index].uri),
                        title: Text(q.tracks.items[index].name),
                        subtitle: Text(artists),
                        leading: Image.network(q.tracks.items[index].album.images.last.url),
                        onTap: () {
                          this.close(context, q.tracks.items[index].uri);
                        },
                      ),
                    )
                  ],
                );
              },
            );
          }else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      );
    }
    return Container();
  }
}
