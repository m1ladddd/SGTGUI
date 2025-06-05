import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/communication/table_handler.dart';
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:smartgridapp/view/shared/defines.dart';

/// Page for modifying settings related to the application
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const keyDarkmode = 'key-darkmode';
  static const keyTableview = 'key-tableview';
  static const keyUsermode = 'key-usermode';
  static const keyBaseTopic = 'key-basetopic';
  static const keyDifficultyLevel = 'key-difficultylevel';

  @override
  Widget build(BuildContext context) {
    final ThemeManager themeManager = Provider.of<ThemeManager>(context);
    final DifficultyManager difficultyManager = Provider.of<DifficultyManager>(context);
    final PageManager pageManager = Provider.of<PageManager>(context);
    TableHandler handler = Provider.of<TableHandler>(context);

    final Size size = MediaQuery.of(context).size;
    int sizeDivider = size.width > 600 ? 1 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(24.0 / sizeDivider),
        children: [
          SettingsGroup(title: 'Theme', children: <Widget>[
            SwitchSettingsTile(
              settingKey: keyDarkmode,
              title: 'Dark mode',
              leading: const Icon(Icons.dark_mode_rounded),
              onChange: (newValue) {
                themeManager.toggleTheme(newValue);
              },
            ),
          ]),
          const SizedBox(height: 20),
          SettingsGroup(title: 'Configuration', children: <Widget>[
            SwitchSettingsTile(
              settingKey: keyTableview,
              title: 'Table View',
              subtitle: 'Enable Table View for a complete view of the table',
              leading: const Icon(Icons.table_restaurant),
              onChange: (newValue) {
                setState(() {
                  pageManager.setPageState(PageReference.tablePage, newValue);
                });
              },
            ),
            DropDownSettingsTile(
              leading: const Icon(Icons.person),
              title: 'Difficulty',
              subtitle: 'Change the difficulty level',
              settingKey: keyDifficultyLevel,
              selected: difficultyManager.stringDifficulty,
              values: Map.fromIterable(difficultyManager.difficulties),
              onChange: (selectedValue) => difficultyManager.stringDifficulty = selectedValue,
            ),
            TextInputSettingsTile(
              title: 'Base Topic',
              settingKey: keyBaseTopic,
              initialValue: handler.baseTopic,
              helperText: 'For example: ${handler.baseTopic}',
              onChange: (String? value) {
                handler.unsubscribe();
                handler.baseTopic = value ?? handler.baseTopic;
                handler.subscribe();
              },
            ),
            SimpleSettingsTile(
              title: 'Broker IP Address',
              subtitle: handler.host,
            ),
            SimpleSettingsTile(
              title: 'Clear Cache',
              subtitle: 'Clear stored cache memory',
              onTap: () {
                Settings.clearCache();
              },
            ),
            ModalSettingsTile(title: 'Advanced settings', subtitle: 'Extra utilities for developers', children: [
              SwitchSettingsTile(
                settingKey: keyUsermode,
                title: 'Admin mode',
                subtitle: 'Enable Admin mode for extra utilities',
                leading: const Icon(Icons.admin_panel_settings),
                onChange: (newValue) {
                  setState(() {
                    pageManager.setPageState(PageReference.globalPage, !newValue);
                    pageManager.setPageState(PageReference.iterationPage, !newValue);

                    pageManager.setPageState(PageReference.scenarioManager, newValue);
                    pageManager.setPageState(PageReference.restrictionsManager, newValue);
                    pageManager.setPageState(PageReference.troubleshootingPage, newValue);
                    pageManager.setPageState(PageReference.debugPage, newValue);
                  });
                },
              ),
            ])
          ]),
        ],
      ),
    );
  }
}
