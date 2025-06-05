import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/communication/table_handler.dart';
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:smartgridapp/view/shared/defines.dart';
import 'package:smartgridapp/view/shared/theme_constants.dart';
import 'package:smartgridapp/view/widgets/chart_widgets.dart';

/// Page containing a global view of the Smart Grid Table through graphs
class GlobalViewPage extends StatefulWidget {
  const GlobalViewPage({super.key});

  @override
  State<GlobalViewPage> createState() => _GlobalViewPageState();
}

class _GlobalViewPageState extends State<GlobalViewPage> {
  List<bool> lineStatuses = [];
  Map snapshot = {};
  SnapshotGraphs selected = SnapshotGraphs.transformerCapacity;

  @override
  void initState() {
    final TableHandler handler = Provider.of<TableHandler>(context, listen: false);
    snapshot = handler.snapshotsManager.getSnapshots(selected);
    lineStatuses = List.generate(snapshot.length, (index) => true);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final TableHandler handler = Provider.of<TableHandler>(context, listen: false);
    snapshot = handler.snapshotsManager.getSnapshots(selected);

    // Only update line selection when an update call is recieved
    // and the length of the line selections has changed.
    // Otherwise these would reset on every update of the graph.
    List<bool> newLineStatuses = List.generate(snapshot.length, (index) => true);
    if (newLineStatuses.length != lineStatuses.length) lineStatuses = newLineStatuses;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final TableHandler handler = Provider.of<TableHandler>(context);
    final ThemeManager themeManager = Provider.of<ThemeManager>(context);
    final Size size = MediaQuery.of(context).size;

    bool horizontalView = size.width > size.height;
    int sizeDivider = size.width > size.height * 0.75 ? 1 : 2;

    final dropDownMenu = Center(
      child: FittedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0 / sizeDivider),
          child: DropdownMenu(
            dropdownMenuEntries: const [
              DropdownMenuEntry(label: 'Transformer capacity', value: SnapshotGraphs.transformerCapacity),
              DropdownMenuEntry(label: 'Charts per voltage level', value: SnapshotGraphs.powerPerVoltageLevel),
              DropdownMenuEntry(label: 'Charts per table section', value: SnapshotGraphs.powerPerTableSection),
              DropdownMenuEntry(label: 'Total generation, load, and storage', value: SnapshotGraphs.powerTotal),
            ],
            textStyle: const TextStyle(color: Colors.white),
            inputDecorationTheme: const InputDecorationTheme(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            ),
            trailingIcon: const Icon(Icons.arrow_drop_down_outlined, color: Colors.white),
            initialSelection: SnapshotGraphs.transformerCapacity,
            onSelected: (value) => setState(() {
              selected = value ?? selected;
              snapshot = handler.snapshotsManager.getSnapshots(selected);
              lineStatuses = List.generate(snapshot.length, (index) => true);
            }),
          ),
        ),
      ),
    );

    final lineSelection = List.generate(
      snapshot.length,
      (index) => Center(
        child: FittedBox(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0 / sizeDivider),
            width: 400,
            child: SwitchListTile(
              title: Text(snapshot.keys.toList()[index], style: const TextStyle(color: Colors.white)),
              activeColor: Colors.greenAccent,
              secondary: Icon(
                handler.scenarioOptionsManager.isStatic ? Icons.bar_chart : Icons.line_axis,
                color: handler.scenarioOptionsManager.isStatic ? Colors.white : uniqueColors[index],
              ),
              value: lineStatuses[index],
              onChanged: (value) {
                setState(() {
                  lineStatuses[index] = value;
                });
              },
            ),
          ),
        ),
      ),
    );

    final graphContainer = Expanded(
      flex: 2 * sizeDivider,
      child: Padding(
        padding: EdgeInsets.only(top: horizontalView ? 0 : 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: themeManager.isDark ? Colors.grey[850] : Global.tertiary,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(60.0),
              topRight: horizontalView ? const Radius.circular(0.0) : const Radius.circular(60.0),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 40.0 / sizeDivider,
            vertical: 60.0 / sizeDivider,
          ),
          child: handler.scenarioOptionsManager.isStatic
              ? selected == SnapshotGraphs.transformerCapacity
                  ? CapacityBarChart(
                      groupDatas: snapshot.values.toList(),
                      groupTitles: snapshot.keys.toList(),
                      groupStatuses: lineStatuses,
                    )
                  : MultiDoubleBarGraph(
                      groupDatas: snapshot.values.toList(),
                      groupTitles: snapshot.keys.toList(),
                      groupStatuses: lineStatuses,
                    )
              : MultiDoubleLineGraph(
                  lineDatas: snapshot.values.toList(),
                  lineStatuses: lineStatuses,
                  lineTitles: snapshot.keys.toList(),
                ),
        ),
      ),
    );

    return Scaffold(
      body: Container(
        color: themeManager.isDark ? Colors.black38 : Global.primary,
        child: horizontalView
            ? Row(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 350,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          dropDownMenu,
                          Flexible(
                            child: ListView(
                              shrinkWrap: true,
                              children: lineSelection,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  graphContainer
                ],
              )
            : Column(
                children: [
                  dropDownMenu,
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 130,
                      maxWidth: 400,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: lineSelection,
                    ),
                  ),
                  graphContainer
                ],
              ),
      ),
    );
  }
}
