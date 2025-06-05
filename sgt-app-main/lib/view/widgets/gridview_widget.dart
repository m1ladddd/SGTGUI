import 'package:flutter/material.dart';
import 'package:smartgridapp/view/widgets/sectionview_widget.dart';

/// Grid widget build from set of [Row] and [Column] widgets.
/// Each field contains a [TableSectionView] widget.
class SmartGrid extends StatefulWidget {
  const SmartGrid({super.key});

  @override
  State<SmartGrid> createState() => _SmartGrid();
}

class _SmartGrid extends State<SmartGrid> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    bool fitWidth = size.width < size.height;
    /* Layout of grid is based on smallest axis
    Vertical layout is used when the width is the smallest axis
    Horizontal layout is used when the height is the smallest axis
    
    ------ Vertical Layout ---------
    |----|----|----|
    | 0  | 1  | 2  |
    | 3  | 4  | 5  |
    | 6  | 7  | 8  |
    | 9  | 10 | 11 |
    |----|----|----|
    
    ------ Horizontal Layout -------
    |----|----|----|----|
    | 2  | 5  | 8  | 11 |
    | 1  | 4  | 7  | 10 |
    | 0  | 3  | 6  | 9  |
    |----|----|----|----|

    */
    return SizedBox(
      width: fitWidth ? size.width : size.height + 110,
      child: Row(
        children: List.generate(
          fitWidth ? 3 : 4,
          (row) {
            return Expanded(
              child: Column(
                children: List.generate(
                  fitWidth ? 4 : 3,
                  (col) {
                    int currentTile = fitWidth ? (col * 3) + row : (row * 3) + (2 - col);
                    return TableSectionView(sectionIndex: currentTile, rotate: fitWidth, iconSizeMultiplier: 1);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
