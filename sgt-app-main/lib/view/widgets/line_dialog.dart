import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/communication/table_handler.dart';
import 'package:smartgridapp/core/models/table.dart';
import 'package:smartgridapp/view/shared/theme_constants.dart';

/// Custom [AlertDialog] widget containing all parameters of a certain [Module]
class LineDialog extends StatefulWidget {
  final int sectionIndex;
  final int lineIndex;
  final Line? line;

  const LineDialog({super.key, required this.sectionIndex, required this.lineIndex, required this.line});

  @override
  State<LineDialog> createState() => _LineDialogState();
}

class _LineDialogState extends State<LineDialog> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final TableHandler tableHandler = Provider.of<TableHandler>(context);

    return AlertDialog(
      // Dialog window contains controls for activating and deactivating lines.
      // The dialog window has the following structure:
      //
      //  Title:
      //  Text Widget
      //
      //  Content:
      //  Empty
      //
      //  Actions:
      //  Activate/Deactivate and close Buttons
      //

      title: const Text('Line controls'),
      contentPadding: const EdgeInsets.all(0),
      content: Icon(
        Icons.linear_scale,
        color: widget.line == null
            ? Colors.grey
            : widget.line!.isActive
                ? Colors.greenAccent
                : Colors.redAccent,
        size: 100,
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: <Widget>[
        Visibility(
          visible: widget.line != null,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                widget.line!.state = widget.line!.isActive ? false : true;
                tableHandler.changeLine(widget.sectionIndex, widget.lineIndex, widget.line!.state);
                showToast(
                  context: context,
                  'The line has been ${widget.line!.isActive ? 'activated' : 'deactivated'}!',
                  position: StyledToastPosition(align: Alignment.bottomCenter, offset: size.height / 1.5),
                );
                Navigator.of(context).pop();
              });
            },
            child: Text(
              widget.line != null
                  ? widget.line!.isActive
                      ? 'Deactivate'
                      : 'Activate'
                  : '',
              style: const TextStyle(color: Global.tertiary),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Global.tertiary),
          ),
        ),
      ],
    );
  }
}
