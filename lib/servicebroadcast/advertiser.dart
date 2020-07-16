import 'dart:async';
import 'dart:io' show RawDatagramSocket, RawSocketEvent, InternetAddress, Datagram;
import 'dart:async' show Timer;

class AdvertiseService{
  String _targetIP;
  int _targetPort;
  String _multicastMessage;
  FoundPeerCallback _foundPeerCallback;
  RawDatagramSocket _rawDatagramSocket;
  Timer _timer;

  AdvertiseService(this._targetIP, this._targetPort, this._multicastMessage, this._foundPeerCallback);

  advertise() {
    RawDatagramSocket.bind(InternetAddress.anyIPv6, 0).then((socket){
      this._rawDatagramSocket = socket;
      this._rawDatagramSocket.readEventsEnabled = true;
      this._rawDatagramSocket.listen((RawSocketEvent event) {
        if(event == RawSocketEvent.read){
          Datagram datagram = this._rawDatagramSocket.receive();
          if(datagram != null){
            _foundPeerCallback.foundPeer(datagram.address.address, datagram.port);
          }
        }
      });
    });
    
    this._timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(timer.isActive){
        this._rawDatagramSocket.send(this._multicastMessage.codeUnits, InternetAddress(this._targetIP), this._targetPort);
      }
    });
  }

  stopService() {
    this._timer.cancel();
    if(_rawDatagramSocket!=null) _rawDatagramSocket.close();
  }
}

abstract class FoundPeerCallback{
  foundPeer(String host, int port);
}