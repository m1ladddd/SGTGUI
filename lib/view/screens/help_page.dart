import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

/// Page containing utility for troubleshooting
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FittedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              AutoSizeText(maxLines: 1, 'Setup Smart Grid Table', textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.visible),
              SizedBox(height: 10),
              AutoSizeText(maxLines: 1, 'Make sure the router is connected.'),
              AutoSizeText(maxLines: 1, 'Check the layout of the table sections. It should match:'),
              SizedBox(height: 10),
              AutoSizeText(maxLines: 1, '-----1-----'),
              AutoSizeText(maxLines: 1, '--5--2--6--'),
              AutoSizeText(maxLines: 1, '-----3-----'),
              AutoSizeText(maxLines: 1, '-----4-----'),
              SizedBox(height: 10),
              AutoSizeText(maxLines: 1, 'Click the simulation icon on the provided pc.'),
              AutoSizeText(maxLines: 1, 'If it does not work, close the application and replug the power of the Smart Grid Table.'),
              SizedBox(height: 50),
              AutoSizeText(maxLines: 1, 'Setup Smart Grid App', textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              AutoSizeText(maxLines: 1, 'Boot up the app.'),
              AutoSizeText(maxLines: 1, 'Check to see if the table number matches the number in the base topic in the settings menu.'),
              AutoSizeText(maxLines: 1, 'To do this, go to Settings -> Base Topic.'),
            ],
          ),
        ),
      ),
    );
  }
}
