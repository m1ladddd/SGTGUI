import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';
import 'mqtt_base_handler.dart';

/// Implementation of [MqttBaseHandler] for Mobile and Desktop applications
class MqttHandler extends MqttBaseHandler {
  @override
  MqttHandler(String host, int port) : super(MqttServerClient.withPort(host, const Uuid().v4(), port));
}
