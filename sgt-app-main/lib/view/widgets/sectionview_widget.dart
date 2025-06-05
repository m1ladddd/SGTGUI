import 'dart:math';
import 'package:flutter/material.dart';
import 'package:invert_colors/invert_colors.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/communication/table_handler.dart';
import 'package:smartgridapp/core/models/table.dart';
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:smartgridapp/view/widgets/line_dialog.dart';
import 'package:smartgridapp/view/widgets/parameter_dialog.dart';

/// Widget for viewing a [TableSection]
class TableSectionView extends StatefulWidget {
  final int sectionIndex;
  final bool rotate;
  final double iconSizeMultiplier;
  const TableSectionView({super.key, required this.sectionIndex, required this.rotate, required this.iconSizeMultiplier});

  @override
  State<TableSectionView> createState() => _TableSectionViewState();
}

class _TableSectionViewState extends State<TableSectionView> {
  @override
  Widget build(BuildContext context) {
    final TableHandler handler = Provider.of<TableHandler>(context, listen: true);
    final ThemeManager themeManager = Provider.of<ThemeManager>(context);
    TableSection tableSection = handler.sgTable.getTableSection(widget.sectionIndex);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double smallestAxis = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight;
        // Factor for scaling the images to the correct size depending on the size of the screen
        // Tells the ratio from the available space (logical pixels) compared to the image size (360).
        double screenToImgFactor = smallestAxis / 360;
        double cableSize = screenToImgFactor * 24;
        double moduleSize = screenToImgFactor * 40;

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform.rotate(
              angle: widget.rotate ? 0 : 270 * pi / 180,
              child: themeManager.isDark
                  ? InvertColors(
                      child: Image.asset(
                        'images/grid_section_${widget.sectionIndex + 1}.png',
                        scale: 1 / screenToImgFactor,
                      ),
                    )
                  : Image.asset(
                      'images/grid_section_${widget.sectionIndex + 1}.png',
                      scale: 1 / screenToImgFactor,
                    ),
            ),
            Stack(
              children: List.generate(tableSection.maxModules, (idx) {
                    // Calculation for finding the exact position of a module within the screen
                    // location[0] is the 'x' (width) position
                    // location[1] is the 'y' (height) position
                    // On rotate 'x' and 'y' are swapped and all elements are rotated 90 degrees

                    double posX = (tableSection.moduleLocations[idx][widget.rotate ? 0 : 1] - 180) * screenToImgFactor;
                    double posY = (widget.rotate ? (tableSection.moduleLocations[idx][1] - 180) : (-tableSection.moduleLocations[idx][0] + 180)) * screenToImgFactor;

                    Module? module = tableSection.getModule(idx);
                    return Container(
                      // Size of grid is based on max width
                      width: smallestAxis,
                      height: smallestAxis,
                      alignment: Alignment.center,
                      // Puts the widgets on the screen at the exact location calculated
                      child: Transform.translate(
                        offset: Offset(posX, posY),
                        child: IconButton(
                          color: tableSection.getModule(idx) != null ? Colors.greenAccent : Colors.grey,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(0),
                          iconSize: moduleSize * 2,
                          icon: Icon(Icons.home_work, size: moduleSize),
                          splashRadius: moduleSize,
                          tooltip: module?.name ?? 'No Module',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => ParameterDialog(
                                module: module,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }) +
                  List.generate(
                    tableSection.numLines,
                    (idx) {
                      // Calculation for finding the exact position of a module within the screen
                      // location[0] is the 'x' (width) position
                      // location[1] is the 'y' (height) position
                      // On rotate 'x' and 'y' are swapped
                      double posX = (tableSection.lineLocations[idx][widget.rotate ? 0 : 1] - 180) * screenToImgFactor;
                      double posY = (tableSection.lineLocations[idx][widget.rotate ? 1 : 0] - 180) * screenToImgFactor;
                      double initialRotation = tableSection.lineRotation[idx];
                      double rotation = !widget.rotate && initialRotation != 45 && initialRotation != 135 ? initialRotation + 90 : initialRotation;
                      Line? line = tableSection.getLine(idx);

                      return Container(
                        // Size of grid is based on max width
                        width: smallestAxis,
                        height: smallestAxis,
                        alignment: Alignment.center,
                        // Puts the widgets on the screen at the exact location calculated
                        child: Transform.translate(
                          transformHitTests: true,
                          offset: Offset(posX, posY),
                          child: Transform.rotate(
                            angle: rotation * pi / 180,
                            child: IconButton(
                              iconSize: cableSize * 2,
                              color: Colors.grey,
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(0),
                              icon: Icon(Icons.linear_scale,
                                  size: cableSize,
                                  color: line == null
                                      ? Colors.grey
                                      : line.isActive
                                          ? Colors.greenAccent
                                          : Colors.redAccent),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => LineDialog(
                                    line: line,
                                    lineIndex: idx,
                                    sectionIndex: widget.sectionIndex,
                                  ),
                                );
                              },
                              splashRadius: cableSize,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        );
      },
    );
  }
}
