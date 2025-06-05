import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:smartgridapp/view/shared/theme_constants.dart';
import 'package:smartgridapp/view/widgets/entry_widgets.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/communication/table_handler.dart';

/// Page containing utility for troubleshooting
class ScenarioManagerPage extends StatefulWidget {
  const ScenarioManagerPage({super.key});

  @override
  State<ScenarioManagerPage> createState() => _ScenarioManagerPageState();
}

class _ScenarioManagerPageState extends State<ScenarioManagerPage> {
  @override
  Widget build(BuildContext context) {
    final handler = Provider.of<TableHandler>(context);
    final ThemeManager themeManager = Provider.of<ThemeManager>(context);
    final Size size = MediaQuery.of(context).size;
    int sizeDivider = size.width > 450 ? 1 : 2;

    return Scaffold(
      backgroundColor: themeManager.isDark ? const Color.fromARGB(255, 70, 53, 92) : Global.primary,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 60,
                    maxWidth: 300,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeManager.isDark ? Colors.grey[850] : Global.tertiary,
                      borderRadius: const BorderRadius.all(Radius.circular(60.0)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText('Current Scenario: ${handler.scenarioOptionsManager.activeScenarioName}', maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold)),
                          AutoSizeText(handler.scenarioOptionsManager.isStatic ? 'Mode: Static' : 'Mode: Dynamic', maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: size.width,
                padding: EdgeInsets.only(left: 30 / sizeDivider, right: 30 / sizeDivider),
                decoration: BoxDecoration(
                  color: themeManager.isDark ? Colors.grey[850] : Global.tertiary,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(60.0), topRight: Radius.circular(60.0)),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AutoSizeText('Scenario\'s', maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, color: themeManager.isDark ? Global.tertiary : Global.secondary)),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeManager.isDark ? Colors.grey[800] : Global.tertiary,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                      ),
                      padding: EdgeInsets.all(20 / sizeDivider),
                      child: handler.scenarioOptionsManager.isEmpty
                          ? const AutoSizeText('Scenario Lists have not been received yet.', maxLines: 1)
                          : Column(children: [
                              DropDownWidget(
                                items: handler.scenarioOptionsManager.getScenarioList(true),
                                callback: (value) {
                                  handler.changeScenario(value, true);
                                },
                                initialValue: handler.scenarioOptionsManager.isStatic ? handler.scenarioOptionsManager.activeScenarioName : null,
                                prefixText: 'Static Scenario: ',
                                disabled: handler.scenarioOptionsManager.isEmpty || handler.scenarioOptionsManager.activeScenarioName.isEmpty,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropDownWidget(
                                items: handler.scenarioOptionsManager.getScenarioList(false),
                                callback: (value) {
                                  handler.changeScenario(value, false);
                                },
                                initialValue: handler.scenarioOptionsManager.isStatic ? null : handler.scenarioOptionsManager.activeScenarioName,
                                prefixText: 'Dynamic Scenario: ',
                                disabled: handler.scenarioOptionsManager.isEmpty || handler.scenarioOptionsManager.activeScenarioName.isEmpty,
                              ),
                            ]),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
