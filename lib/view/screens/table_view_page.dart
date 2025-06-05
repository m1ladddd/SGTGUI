import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/providers/scaler_provider.dart';
import 'package:smartgridapp/view/shared/theme_constants.dart';
import 'package:smartgridapp/view/widgets/gridview_widget.dart';
import 'package:smartgridapp/view/widgets/interactive_viewer_widget.dart';

/// Page containing a full view of the Smart Grid Table
class TableViewPage extends StatefulWidget {
  const TableViewPage({super.key});

  @override
  State<TableViewPage> createState() => _TableViewPageState();
}

class _TableViewPageState extends State<TableViewPage> {
  @override
  Widget build(BuildContext context) {
    final GridScaler gridScaler = Provider.of<GridScaler>(context);

    return Scaffold(
      /// InteractiveGridViewer Widget for ability to zoom and pan grid view
      body: const InteractiveGridViewer(
        child: SmartGrid(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => gridScaler.resetScale(),
        backgroundColor: Global.primary,
        child: const Icon(Icons.restore, color: Colors.white),
      ),
    );
  }
}
