import 'dart:io';
import 'package:udp/udp.dart';

/// Function that returns the broadcasted broker IP when received.
Future<String> getBrokerIp() async {
  var receiver = await UDP.bind(Endpoint.any(port: const Port(5005)));
  Stream source = receiver.asStream();
  Datagram datagram = await source.first;
  return String.fromCharCodes(datagram.data, 8, datagram.data.length - 1);
}
