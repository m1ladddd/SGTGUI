import 'package:flutter/cupertino.dart';
import 'package:smartgridapp/view/widgets/interactive_viewer_widget.dart';

/// Class containing the scaler value and controller for the [InteractiveGridViewer].
class GridScaler extends ChangeNotifier {
  double _scale = 1.0;
  TransformationController? _controller;

  /// Getter Function for [_scale].
  double get scale {
    return _scale;
  }

  /// Setter Function for [_scale].
  set scale(double newScale) {
    _scale = newScale;
    notifyListeners();
  }

  /// Setter Function for [_controller].
  set controller(TransformationController controller) {
    _controller = controller;
  }

  /// Function for resetting scale of the controller.
  void resetScale() {
    _controller?.value = Matrix4.identity();
    notifyListeners();
  }
}
