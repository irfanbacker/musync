import 'package:flutter/material.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:musync/models/hostinfo.dart';

class MusyncClient extends StatefulWidget {

  @override
  _MusyncClientState createState() => _MusyncClientState();
}

class _MusyncClientState extends State<MusyncClient> {
  bool _isRefresh;
  BonsoirDiscovery nsdClient;
  List<HostInfo> hostsList;

  @override
  void initState() {
    hostsList=[];
    _isRefresh = true;
    nsdClient = BonsoirDiscovery(type: '_musync._tcp');
    startDiscovery();
    super.initState();
  }

  void startDiscovery() async{
    await nsdClient.ready;
    await nsdClient.start();
    nsdClient.eventStream.listen((event) {
      if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_FOUND) {
        print("NEW FOUND: "+event.service.toString());
        HostInfo host = HostInfo(event.service.name, event.service.ip, event.service.port);
        if (this._checkHostExists(host) == -1) this.hostsList.add(host);
      } else if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_LOST) {
        print("LOST: "+event.service.toString());
        HostInfo host = HostInfo(event.service.name, event.service.ip, event.service.port);
        int p = this._checkHostExists(host);
        if (p != -1) this.hostsList.removeAt(p);
      }
    });
  }

  int _checkHostExists(HostInfo host) {
    for (var i = 0; i < hostsList.length; ++i) {
      if ((hostsList[i].name == host.name) &&
          (hostsList[i].host == host.host) &&
          (hostsList[i].port == host.port)) return i;
    }
    return -1;
  }

  Future<bool> showConfirmation() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content: Text("The discover service will be stopped"),
          actions: <Widget>[
            FlatButton(
              child: Text("Yes"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            FlatButton(
              child: Text("No"),
              onPressed: () => Navigator.of(context).pop(false),
            )
          ],
        );
      },
    );
  }

  void refreshList() async {
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      _isRefresh = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isRefresh) refreshList();
    return WillPopScope(
      onWillPop: showConfirmation,
      child: Scaffold(
        appBar: AppBar(
          title: Text("List of Hosts"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isRefresh = true;
              });
            }),
        body: _isRefresh
            ? Center(child: CircularProgressIndicator())
            : Container(
                padding: EdgeInsets.all(5.0),
                child: (hostsList==null)||(hostsList.isEmpty)
                    ? Center(
                        child: Text("No Hosts Found!"),
                      )
                    : ListView.builder(
                        itemCount: hostsList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: Icon(Icons.devices),
                              title: Text(hostsList[index].name),
                              subtitle: Text(hostsList[index].host +
                                  " : " +
                                  hostsList[index].port.toString()),
                            ),
                          );
                        }),
              ),
      ),
    );
  }

  @override
  void dispose() {
    nsdClient.stop();
    super.dispose();
  }
}
