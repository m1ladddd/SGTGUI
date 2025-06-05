import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/providers/scaler_provider.dart';
import 'package:smartgridapp/view/widgets/gridview_widget.dart';

/// Widget for making [SmartGrid] interactive
class InteractiveGridViewer extends StatefulWidget {
  final Widget child;
  const InteractiveGridViewer({super.key, required this.child});

  @override
  State<InteractiveGridViewer> createState() => _InteractiveGridViewerState();
}

class _InteractiveGridViewerState extends State<InteractiveGridViewer> {
  final TransformationController _transformationController = TransformationController();
  double correctScaleValue = 1.0;

  @override
  void initState() {
    final scaler = Provider.of<GridScaler>(context, listen: false);
    scaler.controller = _transformationController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scaler = Provider.of<GridScaler>(context);

    return InteractiveViewer(
      scaleFactor: 1000,
      minScale: 0.1,
      maxScale: 10.0,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      constrained: false,
      transformationController: _transformationController,
      onInteractionEnd: (details) {
        // Details.scale can give values below 0.5 or above 2.0 and resets to 1
        // Use the Controller Matrix4 to get the correct scale.
        correctScaleValue = _transformationController.value.getMaxScaleOnAxis();
        scaler.scale = correctScaleValue;
      },
      child: widget.child,
    );
  }
}
