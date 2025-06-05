import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:smartgridapp/core/communication/table_handler.dart';
import 'package:smartgridapp/core/communication/udp/broadcast_listener.dart';
import 'package:smartgridapp/view/screens/broker_login_page.dart';
import 'package:smartgridapp/core/providers/scaler_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:smartgridapp/core/providers/managers.dart';
import 'package:smartgridapp/view/shared/defines.dart';
import 'package:smartgridapp/view/widgets/settings_app_bar.dart';
import 'package:asbool/asbool.dart';
import 'view/shared/theme_constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

void main() async {
  Settings.init(
    cacheProvider: SharePreferenceCache(),
  );
  // Disable portrait view on mobile phones
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GridScaler()),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => DifficultyManager()),
        ChangeNotifierProvider(create: (_) => TableHandler()),
        ChangeNotifierProvider(create: (_) => PageManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool clientConnected = false;
  bool isWaitingForIP = false;
  bool adminMode = false;

  /// Setup Function for initializing MQTT client
  void setupClient(String brokerIP) async {
    TableHandler handler = Provider.of<TableHandler>(context, listen: false);
    final pref = await SharedPreferences.getInstance();
    Object baseTopic = pref.get('key-basetopic') ?? 'SmartDemoTable0/GUI/';

    handler.init(
      host: kIsWeb ? 'ws://$brokerIP' : brokerIP,
      port: kIsWeb ? 9001 : 1883,
      user: null,
      passwd: null,
      baseTop: baseTopic.toString(),
      inTop: 'Ingoing',
      outTop: 'Outgoing',
    );

    // Set up callback functions
    handler.mqttHandler.setConnectedCallback(connected);
    handler.mqttHandler.setDisconnectedCallback(disconnected);
    handler.mqttHandler.setSubscribedCallback(subscribed);

    handler.connect().then((connectionEstablished) {
      if (connectionEstablished == 1) {
        handler.setupCallback();
        handler.subscribe();
        handler.requestConfigs();
      } else {
        /// Check if client was not connected in the mean time by a different thread
        if (!clientConnected) {
          handler.logManager.addLog(LogEntry(LogLevels.error, 'The connection to the broker failed.', 'Connection failed', DateTime.now().toString()));
          disconnected();
        }
      }
    });
  }

  /// Connected callback function
  void connected() {
    setState(() {
      TableHandler handler = Provider.of<TableHandler>(context, listen: false);
      handler.logManager.addLog(LogEntry(LogLevels.info, 'The connection to the broker was succesful.', 'Connection succeeded', DateTime.now().toString()));
      clientConnected = true;
    });
  }

  /// Disconnected callback functions
  void disconnected() {
    setState(() {
      TableHandler handler = Provider.of<TableHandler>(context, listen: false);
      handler.logManager.addLog(LogEntry(LogLevels.info, 'The client has disconnected from the broker.', 'Connection disconnected', DateTime.now().toString()));
      clientConnected = false;

      /// Check if UDP listener already exists
      if (!kIsWeb && !isWaitingForIP) {
        isWaitingForIP = true;
        getBrokerIp().then((brokerIP) {
          setupClient(brokerIP);
          isWaitingForIP = false;
        });
      }
    });
  }

  /// Subscribed callback function
  void subscribed(String topic) {
    TableHandler handler = Provider.of<TableHandler>(context, listen: false);
    handler.logManager.addLog(LogEntry(LogLevels.info, 'Subscription to $topic established.', 'Subscription established', DateTime.now().toString()));

    handler.requestConfigs();
    handler.getCurrentModules();
    handler.getLineStates();
  }

  @override
  void initState() {
    /// Theme mode is set to light theme by default.
    /// If saved in cache previous setting is applied.
    SharedPreferences.getInstance().then(
      (pf) {
        Provider.of<ThemeManager>(context, listen: false).toggleTheme(pf.get('key-darkmode')?.asBool ?? false);
      },
    );

    /// Broker IP is found through UDP for non browser applications.
    if (!kIsWeb) {
      getBrokerIp().then((brokerIP) {
        setupClient(brokerIP);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeManager>(context).themeMode,
      home: clientConnected

          /// Root page will be shown when client is connected.
          ? const RootPage()
          : kIsWeb

              /// Depending on platform, different screen will be shown.
              /// Browser versions cannot use UDP and must be manually logged in.
              /// Other versions can wait for a broadcast message while still
              /// having the option to log in manually
              ? LoginScreen(
                  clientSetup: setupClient,
                )
              : LoginWaitScreen(
                  clientSetup: setupClient,
                ),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  Widget build(BuildContext context) {
    final PageManager pageManager = Provider.of<PageManager>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: SettingsAppBar(
          title: pageManager.getCurrentPage.title,
        ),
      ),
      body: pageManager.getCurrentPage.page,
      bottomNavigationBar: NavigationBar(
        destinations: pageManager.getNavigationDestinations,
        selectedIndex: pageManager.currentPage,
        onDestinationSelected: (index) => setState(() {
          pageManager.currentPage = index;
        }),
      ),
    );
  }
}
