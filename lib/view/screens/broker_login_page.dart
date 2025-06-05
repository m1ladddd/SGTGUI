import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:smartgridapp/view/screens/help_page.dart';
import 'package:smartgridapp/view/widgets/entry_widgets.dart';

/// Wait page for when the client is waiting for a connection to the broker
class LoginWaitScreen extends StatelessWidget {
  final void Function(String) clientSetup;
  const LoginWaitScreen({super.key, required this.clientSetup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: const Text('Please wait...'),
          actions: [
            IconButton(
              tooltip: 'Manual Login',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(clientSetup: clientSetup)));
              },
              icon: const Icon(Icons.network_check),
            ),
            IconButton(
              tooltip: 'Help',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Help'),
                        automaticallyImplyLeading: false,
                        leading: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'Back',
                        ),
                      ),
                      body: const HelpPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.help_outline),
            )
          ],
        ),
      ),
      body: const Center(
        child: Text('Waiting for Smart Grid Application to start...'),
      ),
    );
  }
}

/// Login page for connecting to a specific host address
class LoginScreen extends StatefulWidget {
  final void Function(String) clientSetup;
  const LoginScreen({super.key, required this.clientSetup});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(title: const Text('Broker Login')),
      ),
      body: Center(
        child: SizedBox(
          width: size.width - 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please provide the broker IP address.'),
              TextFieldWidget(prefix: 'IP Address', hintText: '192.168.1.1', inputController: controller),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    String brokerIP = controller.text;
                    if (brokerIP.isNotEmpty) {
                      widget.clientSetup(brokerIP);
                    } else {
                      showToast('Please provide a broker IP', context: context);
                    }
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Connect'))
            ],
          ),
        ),
      ),
    );
  }
}
