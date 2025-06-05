import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/communication/table_handler.dart';
import 'package:smartgridapp/view/screens/settings_page.dart';

/// Custom [AppBar] for navigation to the [SettingsPage]
class SettingsAppBar extends StatelessWidget {
  const SettingsAppBar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final TableHandler tableHandler = Provider.of<TableHandler>(context);
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          onPressed: () {
            tableHandler.refreshScenario();
          },
          icon: const Icon(Icons.restart_alt_outlined),
          tooltip: 'Refresh',
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const SettingsPage();
                },
              ),
            );
          },
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
        ),
      ],
      elevation: 0.0,
    );
  }
}
