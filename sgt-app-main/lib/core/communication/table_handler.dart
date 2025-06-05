import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:smartgridapp/core/models/table.dart';
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:smartgridapp/core/blueprints/table_model.dart';
import 'package:smartgridapp/view/shared/defines.dart';

import 'mqtt/mqtt_mobile_handler.dart' if (dart.library.html) 'mqtt/mqtt_web_handler.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';

/// Class for handling incoming and outgoing changes for the simulation.
/// Composed of [SGTable], [ModuleRestrictor] and [MqttHandler] classes.
class TableHandler with ChangeNotifier {
  bool _pauseQueue = false;
  final Queue<Map> _messageQueue = Queue<Map>();

  SGTable sgTable = SGTable.fromMaps(TableFrame.tableSections);
  RestrictionsManager restrictionsManager = RestrictionsManager();
  MqttHandler mqttHandler = MqttHandler('', 0);
  ScenarioObjectsManager scenarioObjectsManager = ScenarioObjectsManager();
  ScenarioOptionsManager scenarioOptionsManager = ScenarioOptionsManager();
  SnapshotsManager snapshotsManager = SnapshotsManager();
  LogManager logManager = LogManager(entryLimit: 100);

  /// All Mqtt related settings.
  late String _host;
  late int _port;
  late String? _username;
  late String? _password;

  late String baseTopic;
  late String inTopic;
  late String outTopic;

  get host => _host;

  /// Function for initializing the [MqttHandler].
  void init({String host = '', int port = 0, String? user, String? passwd, int tableNum = 0, String baseTop = '', String inTop = '', String outTop = ''}) {
    _host = host;
    _port = port;
    _username = user;
    _password = passwd;

    baseTopic = baseTop;
    inTopic = inTop;
    outTopic = outTop;

    mqttHandler = MqttHandler(_host, _port);
  }

  /// Function for setting the restrictions config for the [RestrictionsManager].
  void setRestrictions(Map restrictionsJson) {
    restrictionsManager.setRestrictions(restrictionsJson);
    restrictionsManager.saveRestrictions();
  }

  /// Function for connecting the [MqttHandler] to the defined broker.
  Future<int> connect() async {
    int status = await mqttHandler.connect(_username, _password);
    return status;
  }

  /// Utility Function that waits for a bool to change.
  Future _waitWhile(bool Function() test, [Duration pollInterval = Duration.zero]) {
    var completer = Completer();
    check() {
      if (!test()) {
        completer.complete();
      } else {
        Timer(pollInterval, check);
      }
    }

    check();
    return completer.future;
  }

  /// Function for subscribing to the defined [_baseTopic] + [_inTopic].
  void subscribe() {
    logManager.addLog(LogEntry(
      LogLevels.info,
      'Setting up subscription to $baseTopic$inTopic.',
      'Subscription Setup',
      DateTime.now().toString(),
    ));
    mqttHandler.subscribe(baseTopic + inTopic);
  }

  /// Function for unsubscribing to the defined [_baseTopic] + [_inTopic].
  void unsubscribe() {
    logManager.addLog(LogEntry(
      LogLevels.info,
      'Removing subscription from $baseTopic$inTopic.',
      'Subscription Setup',
      DateTime.now().toString(),
    ));
    mqttHandler.unsubscribe(baseTopic + inTopic);
  }

  /// Function for setting up callback function to the message **stream**.
  void setupCallback() {
    /// Definition of callback function.
    mqttHandler.getMessagesStream()!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      try {
        _messageQueue.add(json.decode(pt));

        if (_pauseQueue) pausedCallback();

        /// Queue may be unpaused during previous callback.
        if (!_pauseQueue) handleCallback();
      } on FormatException {
        logManager.addLog(LogEntry(
          LogLevels.error,
          'Message received was not of format JSON.',
          'Format Exception',
          DateTime.now().toString(),
        ));
        notifyListeners();
      }
    });
    logManager.addLog(LogEntry(
      LogLevels.info,
      'Callback function has been setup.',
      'Callback Setup',
      DateTime.now().toString(),
    ));
  }

  /// Callback Function for when [_pauseQueue] is **true**.
  void pausedCallback() {
    Queue<Map> toBeRemoved = Queue<Map>();

    /// Only messages of type *SCENARIO_JSON* and *RESTRICTIONS_JSON* are handled.
    for (Map message in _messageQueue) {
      if (message['type'] == 'SCENARIO_JSON' || message['type'] == 'RESTRICTIONS_JSON' || message['type'] == 'SCENARIO_LIST') {
        bool isHandled = messageHandler(message);
        if (isHandled) {
          toBeRemoved.add(message);
        }
      }
    }

    /// Unpauses queue when required [_scenarioJson], [_moduleRestrictionsJson] and [_scenarioList] are received.
    if (scenarioObjectsManager.scenario.isNotEmpty && restrictionsManager.hasRestrictions && scenarioOptionsManager.isNotEmpty) {
      _pauseQueue = false;
    }

    /// If toBeRemoved is empty all element of [_messageQueue] would be deleted.
    if (toBeRemoved.isNotEmpty) {
      _messageQueue.removeWhere((message) => toBeRemoved.contains(message));
      toBeRemoved.clear();
    }
  }

  /// Regular Callback Function.
  void handleCallback() {
    Queue<Map> toBeRemoved = Queue<Map>();

    for (Map message in _messageQueue) {
      bool isHandled = messageHandler(message);
      if (isHandled) {
        toBeRemoved.add(message);
      }
    }

    _messageQueue.removeWhere((message) => toBeRemoved.contains(message));
  }

  /// Message Handler Function.
  /// Handles messages based of **type** property.
  bool messageHandler(Map message) {
    switch (message['type']) {
      case 'SCENARIO_JSON':
        logManager.addLog(LogEntry(
          LogLevels.info,
          'A new scenario JSON file was received.',
          'Scenario file received',
          DateTime.now().toString(),
        ));
        scenarioObjectsManager.setScenario(message['payload']['scenario_json']);
        scenarioObjectsManager.setOriginal(message['payload']['scenario_json']);
        scenarioOptionsManager.setScenario(message['payload']['is_static'], message['payload']['scenario_json']['name']);
        sgTable.rebuildModules(scenarioObjectsManager.scenario);
        notifyListeners();
        return true;

      case 'SCENARIO_LIST':
        logManager.addLog(LogEntry(
          LogLevels.info,
          'A new list of available ${message['payload']['is_static'] ? 'static' : 'dynamic'} scenarios was received.',
          'Scenario list received',
          DateTime.now().toString(),
        ));
        scenarioOptionsManager.setScenarioList(message['payload']['scenario_list'], message['payload']['is_static']);
        Settings.setValue('key-scenario', scenarioOptionsManager.activeScenarioName);
        notifyListeners();
        return true;

      case 'SCENARIO_UPDATE':
        logManager.addLog(LogEntry(
          LogLevels.info,
          'An update to the current active scenario was received.',
          'Scenario update received',
          DateTime.now().toString(),
        ));
        scenarioObjectsManager.updateScenario(message['payload']["scenario_updates"]);
        sgTable.rebuildModules(scenarioObjectsManager.scenario);
        notifyListeners();
        return true;

      case 'RESTRICTIONS_JSON':
        logManager.addLog(LogEntry(
          LogLevels.info,
          'A new restrictions JSON was file received.',
          'Restrictions file received',
          DateTime.now().toString(),
        ));
        setRestrictions(message['payload']);
        notifyListeners();
        return true;

      case 'RESTRICTIONS_UPDATE':
        logManager.addLog(LogEntry(
          LogLevels.info,
          'An update to the user restrictions was received.',
          'Restrictions update received',
          DateTime.now().toString(),
        ));
        updateRestrictions(message['payload']);
        notifyListeners();
        return true;

      case 'MODULE_UPDATE':
        // Check if configs are missing.
        checkConfigs();

        if (!_pauseQueue) {
          // Update grid if json has been received.
          updateModules(message['payload']);
        }
        // If queue is not paused, message is handled.
        return !_pauseQueue;

      case 'LINE_UPDATE':
        // Check if configs are missing.
        checkConfigs();

        if (!_pauseQueue) {
          // Update grid if json has been received.
          updateLines(message['payload']);
        }
        // If queue is not paused, message is handled.
        return !_pauseQueue;

      case 'NETWORK_SNAPSHOTS':
        logManager.addLog(LogEntry(
          LogLevels.info,
          'Snapshot data from the simulation was received.',
          'Snapshot data received',
          DateTime.now().toString(),
        ));
        snapshotsManager.setSnapshots(message['payload']);
        notifyListeners();
        return true;

      default:
        logManager.addLog(LogEntry(
          LogLevels.warning,
          'A message of an unknown format has been received.',
          'Unknown message received',
          DateTime.now().toString(),
        ));
        notifyListeners();
        return true;
    }
  }

  /// Function that paused queue when configs are missing.
  void checkConfigs() {
    if (scenarioObjectsManager.scenario.isEmpty) {
      requestScenarioJson();
      _pauseQueue = true;
    }

    if (!restrictionsManager.hasRestrictions) {
      requestRestrictionsConfig();
      _pauseQueue = true;
    }

    if (scenarioOptionsManager.isEmpty) {
      requestScenarioList();
      _pauseQueue = true;
    }
  }

  /// Function to request all required configurable files from simulation.
  void requestConfigs() async {
    await _waitWhile(() => !mqttHandler.subscriptionEstablished);
    if (mqttHandler.isConnected == MqttConnectionState.connected && mqttHandler.isSubscribed == MqttSubscriptionStatus.active) {
      requestScenarioJson();
      requestRestrictionsConfig();
      requestScenarioList();
    } else {
      logManager.addLog(LogEntry(
        LogLevels.error,
        'Connection was not established.',
        'Connection error.',
        DateTime.now().toString(),
      ));
    }
  }

  /// Function to request scenario JSON file from simulation.
  void requestScenarioJson() {
    Map message = {
      "type": "SEND_SCENARIO_JSON",
      "payload": {}
    };
    mqttHandler.publishMessage(baseTopic + outTopic, json.encode(message));
  }

  /// Function to request restrictions JSON file from simulation.
  void requestRestrictionsConfig() {
    Map message = {
      "type": "SEND_RESTRICTIONS",
      "payload": {}
    };
    mqttHandler.publishMessage(baseTopic + outTopic, json.encode(message));
  }

  /// Function to request scenario list from simulation
  void requestScenarioList() {
    Map message = {
      "type": "SEND_SCENARIO_LIST",
      "payload": {
        "is_static": true,
      }
    };
    mqttHandler.publishMessage(baseTopic + outTopic, json.encode(message));

    message["payload"]["is_static"] = false;
    mqttHandler.publishMessage(baseTopic + outTopic, json.encode(message));
  }

  /// Function to request network snapshots from simulation
  void requestNetworkSnapshots() {
    Map message = {
      "type": "SEND_SNAPSHOTS",
      "payload": {}
    };
    mqttHandler.publishMessage(baseTopic + outTopic, json.encode(message));
  }

  /// Function for refreshing the scenario and all connected modules
  void refreshScenario() {
    scenarioObjectsManager.resetManager();
    restrictionsManager.resetManager();
    scenarioOptionsManager.resetManager();
    snapshotsManager.resetManager();

    sgTable = SGTable.fromMaps(TableFrame.tableSections);

    getCurrentModules();
    getLineStates();
    requestNetworkSnapshots();

    notifyListeners();
  }

  /// Function to request all modules connected to grid from simulation.
  void getCurrentModules() {
    Map message = {
      "type": "SEND_ACTIVE_MODULES",
      "payload": {},
    };
    mqttHandler.publishMessage(baseTopic + outTopic, json.encode(message));
  }

  /// Function to request all modules connected to grid from simulation.
  void getLineStates() {
    Map message = {
      "type": "SEND_LINE_STATUSES",
      "payload": {},
    };
    mqttHandler.publishMessage(baseTopic + outTopic, json.encode(message));
  }

  /// Function for updating local restrictions with incoming changes
  void updateRestrictions(List updates) {
    for (var update in updates) {
      int index = stringRestrictionTypes.indexWhere((element) => element == update["restrictionField"]);

      restrictionsManager.changeRestriction(
        RestrictionTypes.values[index],
        update["userField"],
        update["mainField"],
        update["subField"],
        update["value"],
      );

      restrictionsManager.saveRestrictions();
    }

    notifyListeners();
  }

  /// Function to update the modules on the [SGTable] grid.
  void updateModules(Map message) {
    int sctIndex = message["table_section"];
    sctIndex = TableFrame.tableSections.indexWhere((element) => element["tableIndexRemapped"] == sctIndex);

    int moduleIndex = message["module_location"];
    moduleIndex = TableFrame.tableSections[sctIndex]["moduleIndexRemapped"].indexOf(moduleIndex);

    if (sctIndex != -1 && moduleIndex != -1) {
      String id = message["module_id"];

      if (id == "0") {
        sgTable.getTableSection(sctIndex).setModule(moduleIndex, null);
      } else {
        Map data = Map.from(scenarioObjectsManager.scenario[id] ?? {});
        Module module = Module.fromMap(id, data);
        sgTable.getTableSection(sctIndex).setModule(moduleIndex, module);

        if (data.isEmpty) {
          logManager.addLog(LogEntry(
            LogLevels.warning,
            'A module id was received that is not defined in the current scenario.',
            'Unknown module received',
            DateTime.now().toString(),
          ));
        }
      }
    } else {
      logManager.addLog(LogEntry(
        LogLevels.error,
        'A module update was received at an unknown location.',
        'Unknown module location',
        DateTime.now().toString(),
      ));
    }

    notifyListeners();
  }

  /// Function to update the lines on the [SGTable] grid.
  void updateLines(List updates) {
    for (Map update in updates) {
      int sctIndex = update["table"];
      sctIndex = TableFrame.tableSections.indexWhere((element) => element["tableIndexRemapped"] == sctIndex);

      int lineIndex = update["line"];
      bool state = update["active"];

      if (sctIndex != -1 && lineIndex != -1) {
        sgTable.getTableSection(sctIndex).setLine(lineIndex, Line(state));
      } else {
        logManager.addLog(LogEntry(
          LogLevels.error,
          'A line update was received at an unknown location.',
          'Unknown line location',
          DateTime.now().toString(),
        ));
      }
    }

    notifyListeners();
  }

  /// Function that publishes changes made to a specific module.
  void changeParameters(Module module) {
    Map message = {
      "type": "CHANGE_MODULE_PARAMETER",
      "payload": module.toMap(),
    };

    scenarioObjectsManager.updateScenario(module.toMap());
    sgTable.rebuildModules(scenarioObjectsManager.scenario);
    mqttHandler.publishMessage(baseTopic + outTopic, json.encode(message));
    notifyListeners();
  }

  /// Function that publishes changes made to a specific line.
  void changeLine(int sectionIndex, int lineIndex, bool state) {
    Map message = {
      "type": "CHANGE_LINE",
      "payload": {
        "table": TableFrame.tableSections[sectionIndex]['tableIndexRemapped'],
        "line": lineIndex,
        "active": state
      },
    };

    sgTable.getTableSection(sectionIndex).getLine(lineIndex)?.state = state;
    mqttHandler.publishMessage(baseTopic + outTopic, json.encode(message));
    notifyListeners();
  }

  /// Function for updating the local restriction settigns and those of other users
  void changeRestriction(RestrictionTypes restrictionType, String? userField, String mainField, String? subField, dynamic value) {
    Map message = {
      "type": "CHANGE_RESTRICTIONS",
      "payload": [
        {
          "restrictionField": stringRestrictionTypes[restrictionType.index],
          "userField": userField,
          "mainField": mainField,
          "subField": subField,
          "value": value,
        }
      ],
    };

    restrictionsManager.changeRestriction(restrictionType, userField, mainField, subField, value);
    mqttHandler.publishMessage(baseTopic + outTopic, json.encode(message));
    notifyListeners();
  }

  /// Function for updating other users with list of restriction changes
  void changeRestrictions(List updates) {
    Map message = {
      "type": "CHANGE_RESTRICTIONS",
      "payload": updates,
    };

    mqttHandler.publishMessage(baseTopic + outTopic, json.encode(message));
  }

  /// Function for changing the scenario
  void changeScenario(String scenarioName, bool isStatic) {
    Map message = {
      "type": "CHANGE_SCENARIO",
      "payload": {
        "scenario_name": scenarioName,
        "is_static": isStatic,
      },
    };

    mqttHandler.publishMessage(baseTopic + outTopic, json.encode(message));
  }
}
