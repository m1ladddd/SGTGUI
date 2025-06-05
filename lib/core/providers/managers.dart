import 'package:asbool/asbool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartgridapp/view/screens/debug_page.dart';
import 'package:smartgridapp/view/screens/global_view_page.dart';
import 'package:smartgridapp/view/screens/parameter_restrictions_editor_page.dart';
import 'package:smartgridapp/view/screens/scenario_manager_page.dart';
import 'package:smartgridapp/view/screens/table_iteration_page.dart';
import 'package:smartgridapp/view/screens/table_view_page.dart';
import 'package:smartgridapp/view/screens/help_page.dart';
import 'package:smartgridapp/view/shared/defines.dart';

/// Class for managing modes within the application
class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  /// Getter Function for [_themeMode].
  get themeMode => _themeMode;

  /// Getter Function that returns if **true** [_themeMode] is set to dark else **false**.
  get isDark => _themeMode == ThemeMode.dark;

  /// Function for toggling [_themeMode]
  toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class ScenarioOptionsManager {
  String _selectedScenario = '';
  bool _isStatic = true;
  List _dynamicList = [];
  List _staticList = [];

  /// Function for setting a scenario list.
  void setScenarioList(List scenarioList, bool isStatic) {
    isStatic ? _staticList = scenarioList : _dynamicList = scenarioList;
  }

  /// Function for getting a scenario list.
  List getScenarioList(bool isStatic) {
    return isStatic ? _staticList : _dynamicList;
  }

  /// Setter Function for [_selectedScenario] and [_isStatic].
  void setScenario(bool isStatic, String scenarioName) {
    _selectedScenario = scenarioName;
    _isStatic = isStatic;
  }

  /// Function for resetting the scenario options.
  void resetManager() {
    _selectedScenario = '';
    _isStatic = true;
    _dynamicList = [];
    _staticList = [];
  }

  /// Getter Function for [_selectedScenario].
  String get activeScenarioName => _selectedScenario;

  /// Getter Function for [_isStatic]
  bool get isStatic => _isStatic;

  /// Function that returns if the lists are empty.
  bool get isEmpty => _dynamicList.isEmpty && _staticList.isEmpty;

  /// Function that returns if the lists are not empty.
  bool get isNotEmpty => _dynamicList.isNotEmpty && _staticList.isNotEmpty;
}

/// Class for managing the scenario's and config objects.
class ScenarioObjectsManager {
  Map _originalScenario = {};
  Map _scenarioJson = {};

  /// Function for setting [_scenarioJson].
  void setScenario(Map scenario) {
    _scenarioJson = Map.from(scenario);
  }

  /// Setter Function for [_originalScenario]
  void setOriginal(Map scenario) {
    _originalScenario = Map.from(scenario);
  }

  /// Function to update the active scenario.
  void updateScenario(Map scenarioUpdates) {
    scenarioUpdates.forEach((key, value) {
      _scenarioJson[key] = value;
    });
  }

  /// Function for resetting the scenario manager.
  void resetManager() {
    _originalScenario = {};
    _scenarioJson = {};
  }

  /// Getter Function for [_scenarioJson].
  Map get scenario => Map.from(_scenarioJson);

  /// Getter Function for [_originalScenario].
  Map get originalScenario {
    return Map.from(_originalScenario);
  }
}

/// Class for handling the difficulty levels of the application.
class DifficultyManager with ChangeNotifier {
  Difficulty _difficulty = Difficulty.beginner;

  final List<String> _difficulties = [
    'Beginner',
    'Advanced',
  ];

  /// Constructor for [DifficultyManager].
  /// Reloads previous setting on boot from cache.
  DifficultyManager() {
    String? value = Settings.getValue('key-difficultylevel');
    stringDifficulty = value ?? 'Beginner';
  }

  /// Setter Function for [_difficulty].
  /// Updates [StatefulWidget] on call.
  set difficulty(Difficulty difficulty) {
    _difficulty = difficulty;
    notifyListeners();
  }

  /// Setter Function for [_difficulty].
  /// Updates [StatefulWidget] on call.
  /// Matches String value to [Difficulty].
  set stringDifficulty(String difficulty) {
    int index = _difficulties.indexWhere((element) => element == difficulty);
    _difficulty = Difficulty.values[index];
    notifyListeners();
  }

  /// Getter Function for [_difficulty].
  Difficulty get difficulty {
    return _difficulty;
  }

  /// Getter Function for [_difficulty] as [String].
  String get stringDifficulty {
    return _difficulties[_difficulty.index];
  }

  /// Getter Function for [_difficulties].
  List<String> get difficulties {
    return _difficulties;
  }
}

/// Class for containing information related to a page
class Page {
  final Widget page;
  String title;
  bool isEnabled;
  Page(this.page, this.title, this.isEnabled);
}

/// Class for managing available pages within the application
class PageManager with ChangeNotifier {
  int currentPage = 0;

  /// Map containing all available objects of [Page] referenced by [PageReference]
  final Map<PageReference, Page> _allPages = {
    PageReference.tablePage: Page(const TableViewPage(), 'Table View', false),
    PageReference.iterationPage: Page(const TableIteratorPage(), 'Iterative View', true),
    PageReference.globalPage: Page(const GlobalViewPage(), 'Global View', true),
    PageReference.scenarioManager: Page(const ScenarioManagerPage(), 'Scenario Manager', false),
    PageReference.restrictionsManager: Page(const RestrictionsManagerPage(), 'Restrictions Manager', false),
    PageReference.troubleshootingPage: Page(const HelpPage(), 'Help', false),
    PageReference.debugPage: Page(const DebugPage(), 'Debug', false),
  };

  /// Map containing all available objects of [NavigationDestination] referenced by [PageReference]
  final Map<PageReference, NavigationDestination> _allDestinations = {
    PageReference.tablePage: const NavigationDestination(icon: Icon(Icons.table_restaurant_sharp), label: 'Table'),
    PageReference.iterationPage: const NavigationDestination(icon: Icon(Icons.arrow_forward), label: 'Iterative'),
    PageReference.globalPage: const NavigationDestination(icon: Icon(Icons.stacked_line_chart_sharp), label: 'Overview'),
    PageReference.scenarioManager: const NavigationDestination(icon: Icon(Icons.list), label: 'Scenario'),
    PageReference.restrictionsManager: const NavigationDestination(icon: Icon(Icons.lock), label: 'Restrictions'),
    PageReference.troubleshootingPage: const NavigationDestination(icon: Icon(Icons.troubleshoot), label: 'Help'),
    PageReference.debugPage: const NavigationDestination(icon: Icon(Icons.output), label: 'Debug'),
  };

  /// List containing all enabled pages
  List<Page> _activePages = [];

  /// List containing all enabled destinations
  List<NavigationDestination> _activeDestinations = [];

  /// Constructor for [PageManager].
  PageManager() {
    refreshActivePages();
    reloadCache();
  }

  /// Function for reloading stored settings from the user's cache
  void reloadCache() async {
    final pref = await SharedPreferences.getInstance();
    Set<String> storedKeys = pref.getKeys();
    for (String k in storedKeys) {
      if (k == 'key-tableview') {
        setPageState(PageReference.tablePage, pref.get(k).asBool);
      }

      if (k == 'key-usermode') {
        setPageState(PageReference.globalPage, !pref.get(k).asBool);
        setPageState(PageReference.iterationPage, !pref.get(k).asBool);
        setPageState(PageReference.scenarioManager, pref.get(k).asBool);
        setPageState(PageReference.restrictionsManager, pref.get(k).asBool);
        setPageState(PageReference.troubleshootingPage, pref.get(k).asBool);
        setPageState(PageReference.debugPage, pref.get(k).asBool);
      }
    }
  }

  /// Getter Function for returning the widgets of all active pages
  List<Widget> get activePageWidgets {
    List<Widget> pages = [];
    for (var page in _activePages) {
      pages.add(page.page);
    }
    return pages;
  }

  /// Function for refreshing the list of active pages and destinations
  void refreshActivePages() {
    _activePages = [];
    _activeDestinations = [];

    _allPages.forEach((ref, page) {
      if (page.isEnabled) {
        _activePages.add(page);
        _activeDestinations.add(_allDestinations[ref]!);
      }
    });
  }

  /// Setter Function for changing the enabled state of a page
  void setPageState(PageReference ref, bool state) {
    _allPages[ref]?.isEnabled = state;
    refreshActivePages();

    if (currentPage >= _activePages.length && _activePages.isNotEmpty) {
      currentPage = _activePages.length - 1;
    }
    notifyListeners();
  }

  /// Getter Function for receiving the current selected page
  Page get getCurrentPage {
    return _activePages[currentPage];
  }

  /// Getter Function for getting the list of active destinations
  List<NavigationDestination> get getNavigationDestinations {
    return _activeDestinations;
  }
}

/// Class containing all type, range, and write restrictions for all [Module] objects.
class RestrictionsManager {
  Map _moduleRestrictionsJson = {};

  /// Function that returns if [_moduleRestrictionsJson] is empty.
  bool get hasRestrictions => _moduleRestrictionsJson.isNotEmpty;

  /// Function for setting [_moduleRestrictionsJson].
  void setRestrictions(Map restrictionsJson) {
    _moduleRestrictionsJson = restrictionsJson;
  }

  /// Function for resetting the [RestrictionsManager]
  void resetManager() {
    _moduleRestrictionsJson = {};
  }

  /// Function for getting the range restrictions of a specific field
  dynamic getRangeRestrictions(String mainField, String? subField) {
    String type = stringRestrictionTypes[RestrictionTypes.range.index];
    return (subField != null ? _moduleRestrictionsJson[type][mainField][subField] : _moduleRestrictionsJson[type][mainField]) ?? [];
  }

  /// Function for getting the type restrictions of a specific field
  Type getTypeRestrictions(String mainField, String? subField) {
    String type = stringRestrictionTypes[RestrictionTypes.type.index];
    String typeRestrictions = subField != null ? _moduleRestrictionsJson[type][mainField][subField] : _moduleRestrictionsJson[type][mainField];

    /// Converts string to a **Type**
    if (typeRestrictions == 'string') return String;
    if (typeRestrictions == 'list') return List;
    if (typeRestrictions == 'double') return double;
    if (typeRestrictions == 'doublelist') return List<double>;
    if (typeRestrictions == 'int') return int;
    if (typeRestrictions == 'intlist') return List<int>;

    return Null;
  }

  /// Getter Function that returns the 'nicer' parameter name from the config file.
  String? getNicerParameterName(String userField, String mainField, String? subField) {
    String type = stringRestrictionTypes[RestrictionTypes.parameterName.index];
    return subField == null ? _moduleRestrictionsJson[type][userField][mainField] : _moduleRestrictionsJson[type][userField][mainField][subField];
  }

  /// Getter Function that returns the full set of write restrictions for a specific user.
  Map getUserWriteRestrictions(String userField) {
    String type = stringRestrictionTypes[RestrictionTypes.write.index];
    return _moduleRestrictionsJson.isNotEmpty ? _moduleRestrictionsJson[type][userField] : {};
  }

  /// Function for getting the write restrictions of a specific field
  bool getWriteRestrictions(String? userField, String mainField, String? subField) {
    String type = stringRestrictionTypes[RestrictionTypes.write.index];
    return userField == null
        ? subField == null
            ? _moduleRestrictionsJson[type][mainField]
            : _moduleRestrictionsJson[type][mainField][subField]
        : subField == null
            ? _moduleRestrictionsJson[type][userField][mainField]
            : _moduleRestrictionsJson[type][userField][mainField][subField];
  }

  /// Function for getting the write restrictions of a specific field
  bool getVisibilityRestrictions(String? userField, String mainField, String? subField) {
    String type = stringRestrictionTypes[RestrictionTypes.visibility.index];
    return userField == null
        ? subField == null
            ? _moduleRestrictionsJson[type][mainField]
            : _moduleRestrictionsJson[type][mainField][subField]
        : subField == null
            ? _moduleRestrictionsJson[type][userField][mainField]
            : _moduleRestrictionsJson[type][userField][mainField][subField];
  }

  List<String> getParameterNames(String userField, String mainField) {
    List<String> names = [];
    String type = stringRestrictionTypes[RestrictionTypes.visibility.index];
    if (_moduleRestrictionsJson[type][userField][mainField] is Map) {
      names.addAll(_moduleRestrictionsJson[type][userField][mainField].keys);
    }

    return names;
  }

  /// Function for setting the restrictions of a specific field
  void changeRestriction(RestrictionTypes restrictionType, String? userField, String mainField, String? subField, dynamic value) {
    String type = stringRestrictionTypes[restrictionType.index];
    userField == null
        ? subField == null
            ? _moduleRestrictionsJson[type][mainField] = value
            : _moduleRestrictionsJson[type][mainField][subField] = value
        : subField == null
            ? _moduleRestrictionsJson[type][userField][mainField] = value
            : _moduleRestrictionsJson[type][userField][mainField][subField] = value;
  }

  /// Function for saving the current restrictions to cache
  void saveRestrictions() {
    String k;

    String type = stringRestrictionTypes[RestrictionTypes.write.index];
    _moduleRestrictionsJson[type].forEach((user, restrictions) {
      restrictions.forEach((key, value) {
        if (value is Map) {
          value.forEach((subkey, subvalue) {
            k = 'key-$type-$user-$key-$subkey';
            Settings.setValue(k, subvalue);
          });
        } else {
          k = 'key-$type-$user-$key';
          Settings.setValue(k, value);
        }
      });
    });
  }

  /// Function for loading saved restrictions from cache.
  /// Returns [List] of saved restrictions.
  List loadRestrictions() {
    String k;
    List updates = [];

    String type = stringRestrictionTypes[RestrictionTypes.write.index];
    // Loops over user types.
    _moduleRestrictionsJson[type].forEach((user, restrictions) {
      // Loops over restrictions.
      restrictions.forEach((key, value) {
        if (value is Map) {
          // Loop over subrestrictions.
          value.forEach((subkey, subvalue) {
            k = 'key-$type-$user-$key-$subkey';
            bool? restriction = Settings.getValue(k, defaultValue: null);
            // If restrictions was saved in cache.
            if (restriction != null) {
              updates.add({
                "restriction_type": type,
                "userField": user,
                "mainField": key,
                "subField": subkey,
                "value": restriction,
              });
            }
          });
        } else {
          k = 'key-$type-$user-$key';
          bool? restriction = Settings.getValue(k, defaultValue: null);
          // If restrictions was saved in cache.
          if (restriction != null) {
            updates.add({
              "restriction_type": type,
              "userField": user,
              "mainField": key,
              "subField": null,
              "value": restriction,
            });
          }
        }
      });
    });

    return updates;
  }

  /// Function for creating an empty component parameter field based on restrictions.
  Map cmptParamsFromRestrictions(String componentType, List<bool> includes) {
    Map params = {};

    String type = stringRestrictionTypes[RestrictionTypes.type.index];
    for (int i = 0; i < _moduleRestrictionsJson[type][componentType].keys.length; i++) {
      if (includes[i]) {
        String key = _moduleRestrictionsJson[type][componentType].keys.toList()[i];
        Type fieldType = getTypeRestrictions(componentType, key);

        if (fieldType == String) {
          params[key] = 'empty';
        }

        if (fieldType == int || fieldType == List<int>) {
          params[key] = 0;
        }

        if (fieldType == double || fieldType == List<double>) {
          params[key] = 0.0;
        }

        if (fieldType == List) {
          params[key] = getRangeRestrictions(componentType, key)[0];
        }
      }
    }

    return params;
  }
}

/// Class for managing snapshot data.
/// Consists of four different [SnapshotGraphs].
class SnapshotsManager {
  Map _transformerCapacityGraphs = {};
  Map _powerPerTableSection = {};
  Map _powerPerVoltageLevel = {};
  Map _powerTotal = {};

  // Function for setting the snapshots
  void setSnapshots(Map payload) {
    _transformerCapacityGraphs = payload['transformerCapacityGraphs'] ?? {};
    _powerPerTableSection = payload['powerPerTableSection'] ?? {};
    _powerPerVoltageLevel = payload['powerPerVoltageLevel'] ?? {};
    _powerTotal = payload['powerTotal'] ?? {};
  }

  // Function for returning a specific graph
  Map getSnapshots(SnapshotGraphs graph) {
    switch (graph) {
      case SnapshotGraphs.transformerCapacity:
        return _transformerCapacityGraphs;
      case SnapshotGraphs.powerPerTableSection:
        return _powerPerTableSection;
      case SnapshotGraphs.powerPerVoltageLevel:
        return _powerPerVoltageLevel;
      case SnapshotGraphs.powerTotal:
        return _powerTotal;
      default:
        return {};
    }
  }

  /// Function for resetting the snapshot data.
  void resetManager() {
    _transformerCapacityGraphs = {};
    _powerPerTableSection = {};
    _powerPerVoltageLevel = {};
    _powerTotal = {};
  }
}

/// Data class for logs.
class LogEntry {
  final LogLevels level;
  final String description;
  final String title;
  final String timestamp;

  LogEntry(this.level, this.description, this.title, this.timestamp);
}

/// Class for managing all log entries.
/// Stores up to 100 [LogEntry] at a time.
class LogManager {
  final int entryLimit;
  LogLevels? selectedLevel;
  List<LogEntry> logs = [];
  List<LogEntry> selectedLogs = [];

  LogManager({required this.entryLimit});

  void selectLevel(LogLevels? level) {
    selectedLevel = level;

    selectedLogs = [];
    if (selectedLevel == null) {
      selectedLogs = logs;
    } else {
      for (LogEntry entry in logs) {
        if (entry.level == selectedLevel) {
          selectedLogs.add(entry);
        }
      }
    }
  }

  /// Function for adding logs to the list.
  void addLog(LogEntry entry) {
    logs.add(entry);

    if (logs.length > entryLimit) {
      logs.removeAt(0);
    }

    selectLevel(selectedLevel);
  }

  /// Function for removing logs from the list.
  void removeLog(int index) {
    if (logs.length > index) {
      logs.removeAt(index);
    }

    selectLevel(selectedLevel);
  }

  /// Function for clearing the logs.
  void clearLogs() {
    logs.clear();
    selectedLogs.clear();
  }

  /// Getter function for a specific [LogEntry].
  LogEntry getLog(int index) => logs.elementAt(index);

  /// Getter function for a specific selected [LogEntry].
  LogEntry getSelectedLog(int index) => selectedLogs.elementAt(index);

  /// Function for returning the number of entries for specific [LogLevels].
  int levelCount(LogLevels level) => logs.where((element) => element.level == level).length;
}
