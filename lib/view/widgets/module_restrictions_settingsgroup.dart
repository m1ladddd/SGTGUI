import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';

import 'package:smartgridapp/core/communication/table_handler.dart';
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:smartgridapp/view/shared/defines.dart';

/// SettingsGroup widget containing all restrictions module restrictions.
class ModuleSettingsGroup extends StatefulWidget {
  const ModuleSettingsGroup({super.key});

  @override
  State<ModuleSettingsGroup> createState() => _ModuleSettingsGroupState();
}

class _ModuleSettingsGroupState extends State<ModuleSettingsGroup> {
  @override
  Widget build(BuildContext context) {
    final TableHandler handler = Provider.of<TableHandler>(context);
    final DifficultyManager difficultyManager = Provider.of<DifficultyManager>(context);

    List writeFieldKeys = [];
    List writeFieldValues = [];

    /// Convert Map to two lists. One for they keys and one for the values.
    handler.restrictionsManager.getUserWriteRestrictions(difficultyManager.stringDifficulty).forEach((key, value) {
      writeFieldKeys.add(key);
      writeFieldValues.add(value);
    });

    /// Generate unique list of keys to store the settings in cache.
    /// Naming for regular fields is `key-writerestrictions-<field name>`
    /// For [Map] type fields the naming convention is `key-writerestrictions-<main field name>-<sub field name>`.
    List writeKeys = List.generate(writeFieldKeys.length, (index) {
      return writeFieldValues[index] is Map
          ? List.generate(writeFieldValues[index].length, (idx) {
              return 'key-write_restrictions-${difficultyManager.stringDifficulty}-${writeFieldKeys[index]}-${writeFieldValues[index].keys.toList()[idx]}';
            })
          : 'key-write_restrictions-${difficultyManager.stringDifficulty}-${writeFieldKeys[index]}';
    });

    return SettingsGroup(
      title: 'Module Write Restrictions',
      children: List.generate(
        writeFieldKeys.length,
        (index) {
          /// If field is of type [Map], it is considered a collection
          /// of write restrictions like a component properties field.
          return writeFieldValues[index] is Map
              ? Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: SimpleSettingsTile(
                    title: '${writeFieldKeys[index]}',
                    leading: const Icon(Icons.list),

                    /// On press, creates a new settings screen.
                    child: StatefulBuilder(builder: (context, setState) {
                      /// Keys [k] and values [v] of [Map] object
                      List k = writeFieldValues[index].keys.toList();
                      List v = writeFieldValues[index].values.toList();

                      return SettingsScreen(
                        title: '${writeFieldKeys[index]}',
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: SettingsGroup(
                              title: 'Write restrictions ${writeFieldKeys[index]}',

                              /// For each field, a SwitchSettingsTile is generated.
                              children: List.generate(
                                writeFieldValues[index].keys.length,
                                (idx) => Container(
                                  // Wrapped in Container with UniqueKey
                                  // This way the widget updates on setState
                                  key: UniqueKey(),
                                  child: SwitchSettingsTile(
                                    defaultValue: v[idx],
                                    settingKey: writeKeys[index][idx],
                                    title: '${k[idx]}',
                                    leading: v[idx] ? const Icon(Icons.edit_off_outlined) : const Icon(Icons.edit_outlined),
                                    onChange: (newValue) {
                                      setState(() {
                                        v[idx] = newValue;
                                        writeFieldValues[index] = Map.fromIterables(k, v);
                                        handler.changeRestriction(RestrictionTypes.write, difficultyManager.stringDifficulty, writeFieldKeys[index], k[idx], v[idx]);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                )
              : Container(
                  key: UniqueKey(),
                  child: SwitchSettingsTile(
                    defaultValue: writeFieldValues[index],
                    settingKey: writeKeys[index],
                    title: '${writeFieldKeys[index]}',
                    leading: writeFieldValues[index] ? const Icon(Icons.edit_off_outlined) : const Icon(Icons.edit_outlined),
                    onChange: (newValue) {
                      setState(() {
                        writeFieldValues[index] = newValue;
                        handler.changeRestriction(RestrictionTypes.write, difficultyManager.stringDifficulty, writeFieldKeys[index], null, writeFieldValues[index]);
                      });
                    },
                  ),
                );
        },
      ),
    );
  }
}
