import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/communication/table_handler.dart';
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:smartgridapp/view/shared/defines.dart';
import 'package:smartgridapp/view/shared/theme_constants.dart';

/// Page containing debug utility
class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  @override
  void initState() {
    final TableHandler tableHandler = Provider.of<TableHandler>(context, listen: false);
    tableHandler.logManager.selectLevel(null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeManager themeManager = Provider.of<ThemeManager>(context);
    final TableHandler tableHandler = Provider.of<TableHandler>(context);

    /// Function for creating a list card containing a log entry.
    Card createTile(String title, String description, LogLevels level, String timestamp) => Card(
          shadowColor: Colors.black,
          elevation: 12.0,
          child: ListTile(
            title: AutoSizeText(title, maxLines: 1),
            subtitle: AutoSizeText('$description\n$timestamp', maxLines: 2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () {},
            ),
            leading: Container(
              padding: const EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(width: 1.0, color: themeManager.isDark ? Colors.white24 : Colors.black45),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  level == LogLevels.info
                      ? Icons.info_outline
                      : level == LogLevels.warning
                          ? Icons.warning_amber
                          : Icons.error_outline,
                  color: level == LogLevels.info
                      ? Colors.blueAccent
                      : level == LogLevels.warning
                          ? Colors.orangeAccent
                          : Colors.redAccent,
                ),
              ),
            ),
          ),
        );

    return Scaffold(
      backgroundColor: themeManager.isDark ? Colors.black12 : Colors.white,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
              child: Visibility(
                visible: tableHandler.logManager.logs.isNotEmpty,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(60), color: themeManager.isDark ? Colors.black26 : Global.primary),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => tableHandler.logManager.selectLevel(null)),
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                        ),
                        child: AutoSizeText(
                          'All: ${tableHandler.logManager.logs.length}',
                          maxLines: 1,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => tableHandler.logManager.selectLevel(LogLevels.info)),
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                        ),
                        child: AutoSizeText(
                          'Info: ${tableHandler.logManager.levelCount(LogLevels.info)}',
                          maxLines: 1,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => tableHandler.logManager.selectLevel(LogLevels.warning)),
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                        ),
                        child: AutoSizeText(
                          'Warnings: ${tableHandler.logManager.levelCount(LogLevels.warning)}',
                          maxLines: 1,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => tableHandler.logManager.selectLevel(LogLevels.error)),
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                        ),
                        child: AutoSizeText(
                          'Errors: ${tableHandler.logManager.levelCount(LogLevels.error)}',
                          maxLines: 1,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
              child: tableHandler.logManager.selectedLogs.isEmpty
                  ? const Center(child: AutoSizeText('No log messages of this type have been created.'))
                  : ListView(
                      children: List.generate(tableHandler.logManager.selectedLogs.length, (index) {
                        LogEntry entry = tableHandler.logManager.getSelectedLog(tableHandler.logManager.selectedLogs.length - index - 1);
                        return createTile(entry.title, entry.description, entry.level, entry.timestamp);
                      }),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Visibility(
              visible: tableHandler.logManager.logs.isNotEmpty,
              child: ElevatedButton(
                onPressed: () {
                  tableHandler.logManager.clearLogs();
                  showToast(context: context, 'Logs have been cleared succesfully!', position: const StyledToastPosition(align: Alignment.center));
                  setState(() {});
                },
                child: const AutoSizeText(
                  'Clear Logs',
                  maxLines: 1,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
