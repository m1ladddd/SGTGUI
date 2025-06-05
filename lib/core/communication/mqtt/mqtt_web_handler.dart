import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:uuid/uuid.dart';
import 'mqtt_base_handler.dart';

/// Implementation of [MqttBaseHandler] for Browser applications
class MqttHandler extends MqttBaseHandler {
  @override
  MqttHandler(String host, int port) : super(MqttBrowserClient.withPort(host, const Uuid().v4(), port));
}
