import 'package:flutter/material.dart';
import 'dart:convert';

/// Class for containing all components and properties of a module.
class Module {
  /// Module id.
  late String id;

  /// Module name.
  late String name;

  /// Module voltage level.
  late String voltageLevel;

  /// Module generator components.
  late List<dynamic> generators;

  /// Module load components.
  late List<dynamic> loads;

  /// Module transformer components.
  late List<dynamic> transformers;

  /// Module storage components.
  late List<dynamic> storages;

  /// Named Constructor for create a [Module] from a **Map**.
  Module.fromMap(this.id, Map data) {
    name = data["name"] ?? 'Unknown module';
    voltageLevel = data["voltage"] ?? 'LV';
    generators = data["generators"] ?? [];
    storages = data["storages"] ?? [];
    transformers = data["transformer"] ?? [];
    loads = data["loads"] ?? [];
  }

  /// Copy constructor for making deep copies.
  Module.clone(Module module) {
    id = module.id;
    name = module.name;
    voltageLevel = module.voltageLevel;
    generators = module.generators.map((map) => jsonDecode(jsonEncode(map))).toList();
    storages = module.storages.map((map) => jsonDecode(jsonEncode(map))).toList();
    transformers = module.transformers.map((map) => jsonDecode(jsonEncode(map))).toList();
    loads = module.loads.map((map) => jsonDecode(jsonEncode(map))).toList();
  }

  /// Function to convert object to a **Map**.
  Map toMap() {
    Map data = {
      id: {
        "name": name,
        "voltage": voltageLevel,
        "generators": generators,
        "storages": storages,
        "transformer": transformers,
        "loads": loads,
      }
    };

    return data;
  }
}

/// Class containing all properties and functions related to cables/lines.
class Line {
  bool state;

  Line(this.state);

  bool get isActive => state == true;
  bool get isNotActive => state == false;
}

/// Class containing all properties and functions related to a section of the [SGTable].
/// Composed of instances of the [Module] and [Cable] classes.
class TableSection {
  late final int _maxNumModules;
  late final int _numLines;
  late final int _tableIndex;

  final List<List> _moduleLocations = [];
  final List<List> _lineLocations = [];
  final List<double> _lineRotation = [];
  final List<Module?> _modules = [];
  final List<Line?> _lines = [];

  /// Named Constructor for creating a [TableSection] from a [Map] of data.
  TableSection.fromMap(Map data) {
    _tableIndex = data["tableIndex"];
    _maxNumModules = data["maxNumModules"];

    for (var i = 0; i < _maxNumModules; i++) {
      _modules.add(null);
      _moduleLocations.add(
        [
          data["moduleLocations"][i][0],
          data["moduleLocations"][i][1],
        ],
      );
    }

    _numLines = data["numLines"];

    for (var i = 0; i < _numLines; i++) {
      _lines.add(null);
      _lineLocations.add(
        [
          data["lineLocations"][i][0],
          data["lineLocations"][i][1],
        ],
      );
      _lineRotation.add(data["lineRotation"][i]);
    }
  }

  /// Getter Function for getting a [Module] by index.
  Module? getModule(int index) {
    return _modules[index];
  }

  /// Setter Function for setting a [Module] at a specific index
  void setModule(int index, Module? module) {
    _modules[index] = module;
  }

  /// Getter Function for getting a [Line] by index.
  Line? getLine(int index) {
    return _lines[index];
  }

  /// Setter Function for setting a [Line] at a specific index
  void setLine(int index, Line? module) {
    _lines[index] = module;
  }

  /// Getter Function for [_moduleLocations]
  List<List> get moduleLocations {
    return _moduleLocations;
  }

  /// Getter Function for [_lineLocations]
  List<List> get lineLocations {
    return _lineLocations;
  }

  /// Getter Function for [_lineRotation]
  List<double> get lineRotation {
    return _lineRotation;
  }

  /// Getter Function for [_maxNumModules]
  int get maxModules {
    return _maxNumModules;
  }

  /// Getter Function for [_numLines]
  int get numLines {
    return _numLines;
  }

  /// Function for returning the number of connected modules to the grid
  int get connectedModules {
    int cnt = 0;
    for (int i = 0; i < _maxNumModules; i++) {
      if (_modules[i] != null) {
        cnt++;
      }
    }
    return cnt;
  }

  /// Getter Function of [_tableIndex]
  int get getTableIndex {
    return _tableIndex;
  }
}

/// Class containing all [TableSection] instances.
class SGTable with ChangeNotifier {
  late final int _numTableSections;
  late final List<TableSection> tableSections;

  /// Named Constructor for creating a [SGTable] object from a list of [Map].
  SGTable.fromMaps(List tableSectionMaps) {
    tableSections = tableSectionMaps.map((item) => TableSection.fromMap(item)).toList();
    _numTableSections = tableSectionMaps.length;
  }

  /// Getter Function for returning a [TableSection] by index.
  TableSection getTableSection(int index) {
    return tableSections[index];
  }

  /// Getter Function for [_numTableSections].
  int get getNumTableSections {
    return _numTableSections;
  }

  /// Function for rebuilding the [SGTable] model from a new scenario.
  void rebuildModules(Map scenario) {
    for (TableSection tableSection in tableSections) {
      for (int i = 0; i < tableSection._maxNumModules; i++) {
        /// If module is not null, create new module from scenario.
        String? id = tableSection.getModule(i)?.id;
        tableSection.setModule(i, id == null ? null : Module.fromMap(id, scenario[id] ?? {}));
      }
    }
    notifyListeners();
  }
}
