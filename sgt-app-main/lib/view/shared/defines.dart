import 'package:flutter/material.dart';

/// Enum containing all different types of restrictions for modules.
enum RestrictionTypes {
  type,
  write,
  range,
  visibility,
  parameterName,
}

/// Set containing all different [RestrictionTypes] for modules in [String] format.
const List<String> stringRestrictionTypes = [
  "type_restrictions",
  "write_restrictions",
  "range_restrictions",
  "visibility_restrictions",
  "alternative_parameter_names",
];

/// Enum containing all available difficulty options
enum Difficulty {
  beginner,
  advanced,
}

/// Enum containing all available pages
enum PageReference {
  globalPage,
  tablePage,
  iterationPage,
  scenarioManager,
  restrictionsManager,
  troubleshootingPage,
  debugPage,
}

/// Enum containing all available graphs
enum SnapshotGraphs {
  transformerCapacity,
  powerPerVoltageLevel,
  powerPerTableSection,
  powerTotal,
}

/// List containing 36 unique colors
const List<Color> uniqueColors = [
  Color(0xFFdc143c),
  Color(0xFF0000ff),
  Color(0xFF00ff7f),
  Color(0xFF000080),
  Color(0xFFffff00),
  Color(0xFF9ACD32),
  Color(0xFFFF8C00),
  Color(0xFF40e0d0),
  Color(0xFFa020f0),
  Color(0xFFff00ff),
  Color(0xFF1e90ff),
  Color(0xFFDAA520),
  Color(0xFF7F007F),
  Color(0xFF7cfc00),
  Color(0xFF8FBC8F),
  Color(0xFFB03060),
  Color(0xFFFF4500),
  Color(0xFFf0e68c),
  Color(0xFFfa8072),
  Color(0xFFdda0dd),
  Color(0xFFff1493),
  Color(0xFFA9A9A9),
  Color(0xFF2F4F4F),
  Color(0xFF556B2F),
  Color(0xFFA0522D),
  Color(0xFF228B22),
  Color(0xFF808000),
  Color(0xFF483D8B),
  Color(0xFF008B8B),
  Color(0xFF4682B4),
  Color(0xFF7b68ee),
  Color(0xFFee82ee),
  Color(0xFF98fb98),
  Color(0xFF87cefa),
  Color(0xFFffe4c4),
  Color(0xFFffb6c1),
];

enum LogLevels {
  info,
  warning,
  error,
}
