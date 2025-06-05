import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:smartgridapp/view/widgets/module_restrictions_settingsgroup.dart';

/// Page containing utility to change restrictions to certain parameters
class RestrictionsManagerPage extends StatefulWidget {
  const RestrictionsManagerPage({super.key});

  @override
  State<RestrictionsManagerPage> createState() => _RestrictionsManagerPageState();
}

class _RestrictionsManagerPageState extends State<RestrictionsManagerPage> {
  static const keyDifficultyLevel = 'key-difficultylevel';

  @override
  Widget build(BuildContext context) {
    final DifficultyManager difficultyManager = Provider.of<DifficultyManager>(context);
    final Size size = MediaQuery.of(context).size;
    int sizeDivider = size.width > 400 ? 1 : 2;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(24.0 / sizeDivider),
        children: [
          SettingsGroup(title: 'User specific', children: [
            DropDownSettingsTile(
              leading: const Icon(Icons.person),
              title: 'Difficulty',
              subtitle: 'Change the difficulty level',
              settingKey: keyDifficultyLevel,
              selected: difficultyManager.stringDifficulty,
              values: Map.fromIterable(difficultyManager.difficulties),
              onChange: (selectedValue) => setState(() {
                difficultyManager.stringDifficulty = selectedValue;
              }),
            ),
          ]),
          const SizedBox(
            height: 20,
          ),
          const ModuleSettingsGroup(),
        ],
      ),
    );
  }
}
