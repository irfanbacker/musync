import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'advertiser.dart';
import 'discoverer.dart';

class NetworkService extends StatefulWidget {
  String type;

  NetworkService({Key key, @required this.type}): super(key: key);

  @override
  _NetworkServiceState createState() => _NetworkServiceState();
}

class _NetworkServiceState extends State<NetworkService> implements FoundPeerCallback, FoundServiceCallback {
  MethodChannel _platform;
  HostsList _hostsList;
  AdvertiseService _advertiseService;
  DiscoverService _discoverService;
  String _methodChannelName;
  String _targetIP;
  int _targetPort;
  String _multicastMessage;

  @override
  void initState() {
    super.initState();

    this._methodChannelName = "io.irfan.musync";
    this._targetIP = "224.0.0.1";
    this._targetPort = 8000;
    this._multicastMessage = "io.irfan.musync.service";
    this._platform = MethodChannel(this._methodChannelName);
    this._hostsList = HostsList(widget.type);

    if(widget.type == 'client'){
      this._discoverService = DiscoverService(this._targetIP, this._targetPort, this._multicastMessage, this);
      this._discoverService.discoverAndReport();
    }
    else{
      this._platform.invokeMethod('acquireMulticastLock');
      this._advertiseService = AdvertiseService(this._targetIP, this._targetPort, this._multicastMessage, this);
      this._advertiseService.advertise();
    }
  }

  @override
  void foundPeer(String host, int port){
    //No use as of now
  }

  @override
  void foundService(String host, int port){
    print(host);
    if((this._hostsList.getHosts().containsKey(host))&&(this._hostsList.getHosts()[host]==port)) return;
    else setState(() => this._hostsList.setHost(host, port));
  }

  @override
  void dispose() {
    super.dispose();
    if(widget.type == 'host') {
      this._advertiseService.stopService();
      this._platform.invokeMethod("releaseMulticastLock");
    }
    else this._discoverService.stopService();
  }

  @override
  Widget build(BuildContext context) {
    print(this._hostsList.getHosts());
    if(widget.type == 'client') return Scaffold(
      appBar: AppBar(
        title: Text("List of Hosts"),
        centerTitle: true,
        backgroundColor: Colors.grey[600],
      ),
      backgroundColor: Colors.grey[300],
      body: Container(
        padding: EdgeInsets.all(5),
        child: _hostsList.getHosts().length == 0?
        Center(child: Text("No Hosts Found"),) :
        ListView.builder(
            itemCount: _hostsList.getHosts().length,
            itemBuilder: (context, index){
              return Card(
                child: ListTile(
                  title: Text(_hostsList.getHosts().keys.toList()[index]),
                ),
              );
            },
        ),
      ),
    );
    else return Scaffold(
      appBar: AppBar(
        title: Text("List of Hosts"),
        centerTitle: true,
        backgroundColor: Colors.grey[600],
      ),
      backgroundColor: Colors.grey[300],
      body: Container(
        padding: EdgeInsets.all(5),
        child: Center(
          child: Column(
            children: <Widget>[
              Text("Hosting"),
              RaisedButton(onPressed: () async{
                dynamic text = await this._platform.invokeMethod("checkMulticast");
                this._platform.invokeMethod('showToast',{'message': text.toString(),'duration':'long'});
              },
                child: Text("Check multicast"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HostsList {
  String type;
  Map<String, int> _hosts;

  HostsList(this.type) {
    _hosts = {};
  }
  Map<String, int> getHosts() => _hosts;
  setHost(String host, int port) => _hosts[host]=port;
}
