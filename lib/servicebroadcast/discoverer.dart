import 'dart:io' show RawDatagramSocket, RawSocketEvent, InternetAddress, Datagram;
import 'dart:convert' show utf8;

class DiscoverService{
  String _targetIP;
  int _targetPort;
  String _multicastMessage;
  FoundServiceCallback _foundServiceCallback;
  RawDatagramSocket _rawDatagramSocket;

  DiscoverService(this._targetIP, this._targetPort, this._multicastMessage, this._foundServiceCallback);

  discoverAndReport(){
    RawDatagramSocket.bind(InternetAddress.anyIPv6, this._targetPort).then((socket){
      this._rawDatagramSocket = socket;
      this._rawDatagramSocket.readEventsEnabled = true;
      this._rawDatagramSocket.joinMulticast(InternetAddress(this._targetIP));
      this._rawDatagramSocket.listen((RawSocketEvent event) {
        if(event == RawSocketEvent.read){
          Datagram datagram = this._rawDatagramSocket.receive();
          if((datagram != null)&&(this._multicastMessage==utf8.decode(datagram.data))){
            this._rawDatagramSocket.send(datagram.data, datagram.address, datagram.port);
            _foundServiceCallback.foundService(datagram.address.address, datagram.port);
          }
        }
      });
    });
  }

  stopService() {
    if(this._rawDatagramSocket != null) {
      this._rawDatagramSocket.leaveMulticast(InternetAddress(this._targetIP));
      this._rawDatagramSocket.close();
    }
  }
}

abstract class FoundServiceCallback{
  foundService(String host,int port);
}

main() =>
    // UDP client
RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((datagramSocket) {
  datagramSocket.broadcastEnabled = true;
  datagramSocket.readEventsEnabled = true;
  datagramSocket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      Datagram dg = datagramSocket.receive();
      if (dg != null) {
        print('${dg.address.host}:${dg.port} -- ${utf8.decode(dg.data)}');
        //datagramSocket.close();
      }
    }
  });
  datagramSocket.send("io.irfan.musync.service".codeUnits,
      InternetAddress("255.255.255.255"), 1567);
});