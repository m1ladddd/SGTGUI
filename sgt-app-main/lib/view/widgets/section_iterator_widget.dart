import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/communication/table_handler.dart';
import 'package:smartgridapp/core/blueprints/table_model.dart';
import 'package:smartgridapp/view/shared/theme_constants.dart';
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:smartgridapp/view/widgets/entry_widgets.dart';
import 'package:smartgridapp/view/widgets/sectionview_widget.dart';

/// Widget for iterating over all table sections individually
class SectionIterator extends StatefulWidget {
  const SectionIterator({super.key});

  @override
  State<SectionIterator> createState() => _SectionIteratorState();
}

class _SectionIteratorState extends State<SectionIterator> {
  int currentSection = 0;
  List<String> tableIndexes = [];

  @override
  void initState() {
    final TableHandler handler = Provider.of<TableHandler>(context, listen: false);

    /// All table sections containing cables and modules are added to the list.
    for (int i = 0; i < handler.sgTable.getNumTableSections; i++) {
      if (handler.sgTable.getTableSection(i).maxModules > 0 || handler.sgTable.getTableSection(i).numLines > 0) {
        tableIndexes.add(TableFrame.tableSections[i]["tableIndexRemapped"].toString());
      }
    }

    /// Set current section to the first table section.
    currentSection = TableFrame.tableSections.indexWhere((element) => element["tableIndexRemapped"] == 1);
    tableIndexes.sort();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeManager themeManager = Provider.of<ThemeManager>(context);
    /* The following structure is used:
        Container
        ---Column Widget
        ------ConstrainedBox
        ---------Padding
        ------------Container
        ---------------DropDownWidget
        ------Container
        ---------TableSectionView
    */
    return Center(
      child: Container(
        color: themeManager.isDark ? Colors.black38 : Global.primary,
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
                maxHeight: 90,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: themeManager.isDark ? Colors.grey[850] : Global.tertiary,
                    borderRadius: const BorderRadius.all(Radius.circular(60.0)),
                  ),
                  child: DropDownWidget(
                    items: tableIndexes,
                    callback: (value) {
                      /// Find the original index of the table from the remapped index.
                      int nextSection = TableFrame.tableSections.indexWhere((element) => element["tableIndexRemapped"] == int.parse(value));
                      currentSection = nextSection;

                      showToast('Table section switched to $value!', context: context, axis: Axis.horizontal, alignment: Alignment.center, position: StyledToastPosition.center);
                    },
                    parentSetState: setState,
                    initialValue: tableIndexes[0],
                    prefixText: 'Table Section: ',
                    disabled: false,
                    underlineEnabled: false,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: themeManager.isDark ? Colors.grey[850] : Global.tertiary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: TableSectionView(
                  sectionIndex: currentSection,
                  rotate: true,
                  iconSizeMultiplier: 1.5,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
