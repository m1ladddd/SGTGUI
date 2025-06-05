import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:io';
import 'dart:async';

/// Abstract Class for handling the Mqtt communication between the simulation and the App.
/// Composed of Abstract class [MqttClient].
abstract class MqttBaseHandler {
  final MqttClient client;
  final MqttQos qosLevel = MqttQos.atLeastOnce;
  bool subscriptionEstablished = false;
  String subscriptionTopic = '';

  /// Constructor for [MqttBaseHandler].
  /// Takes the broker address, port and an instance of a [MqttClient]
  MqttBaseHandler(this.client) {
    client.logging(on: false);
    client.setProtocolV311();
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 2000; // milliseconds
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = null;
  }

  /// Setter Function for broker address
  void setHost(String server) {
    client.server = server;
  }

  /// Setter Function for broker port
  void setPort(int port) {
    client.port = port;
  }

  /// Function for connecting to the defined broker using a username and a password.
  /// Waits for connection to be established, returns *1* on succesfull connection else *-1*.
  Future<int> connect(String? username, String? password) async {
    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await client.connect(username, password);
    } on NoConnectionException catch (e) {
      /// Raised by the client when connection fails.
      debugPrint('ERROR: client exception - $e');
      //client.disconnect();
      return -1;
    } on SocketException catch (e) {
      /// Raised by the socket layer.
      debugPrint('ERROR: socket exception - $e');
      //client.disconnect();
      return -1;
    }

    /// Check we are connected.
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('SUCCESS: MQTT client connected');
      return 1;
    } else {
      /// Use status here rather than state if you also want the broker return code.
      debugPrint('ERROR: ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      return -1;
    }
  }

  /// Function to disconnect client from broker
  void disconnect() {
    client.disconnect();
  }

  /// Getter Function for subscribtion status to the [subscriptionTopic].
  MqttSubscriptionStatus get isSubscribed {
    return client.getSubscriptionsStatus(subscriptionTopic);
  }

  /// Getter Function for connection status.
  MqttConnectionState get isConnected {
    return client.connectionStatus!.state;
  }

  /// Function for subscribing to a specific topic.
  void subscribe(String topic) {
    subscriptionTopic = topic;

    /// Subscribe to the new topic
    client.subscribe(topic, qosLevel);
  }

  /// Function for subscribing to a specific topic.
  void unsubscribe(String topic) {
    client.unsubscribe(topic);
  }

  /// Getter Function for returning the incoming message **stream** of the client.
  Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
    return client.updates;
  }

  /// Function for publishing a message to a specific topic.
  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, qosLevel, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    subscriptionEstablished = true;
    debugPrint('INFO: Subscription established');
  }

  /// The disconnect callback
  void onDisconnected() {
    debugPrint('INFO: OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
      debugPrint('SUCCESS: OnDisconnected callback is solicited, this is correct');
    } else {
      debugPrint('ERROR: OnDisconnected callback is unsolicited or none, this is incorrect');
    }
  }

  /// The successful connect callback
  void onConnected() {
    debugPrint('SUCCESS: OnConnected client callback - Client connection was successful');
  }

  /// Setter Function for disconnect callback
  void setDisconnectedCallback(void Function() callback) {
    client.onDisconnected = callback;
  }

  /// Setter Function for connect callback
  void setConnectedCallback(void Function() callback) {
    client.onConnected = callback;
  }

  /// Setter Function for subscribed callback
  void setSubscribedCallback(void Function(String) callback) {
    client.onSubscribed = callback;
  }

  /// Setter Function for pong callback
  void setPingedCallback(void Function() callback) {
    client.pongCallback = callback;
  }
}

// https://betterprogramming.pub/streaming-flutter-events-with-mosquitto-mqtt-broker-28998a3b81c2
// https://github.com/shamblett/mqtt_client/blob/master/example/mqtt_server_client.dart
