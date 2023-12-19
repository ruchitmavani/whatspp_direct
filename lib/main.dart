import 'dart:developer';
import 'dart:io';

import 'package:call_log/call_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:whatspp_direct/Providers/phone_provider.dart';
import 'package:whatspp_direct/Providers/state_provider.dart';
import 'package:whatspp_direct/constants.dart';
import 'package:whatspp_direct/ui/call_logs.dart';
import 'package:whatspp_direct/ui/direct_messaage.dart';
import 'package:whatspp_direct/ui/local_contacts.dart';
import 'package:workmanager/workmanager.dart';

import 'Providers/name_provider.dart';
import 'models/hive_contact.dart';

void callbackDispatcher() {
  Workmanager().executeTask((dynamic task, dynamic inputData) async {
    log('Background Services are Working!');
    try {
      final Iterable<CallLogEntry> cLog = await CallLog.get();
      log(' call log entries');
      return true;
    } on PlatformException catch (e, s) {
      log(e.toString());
      log(s.toString());
      return true;
    }
  });
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ContactAdapter());
  await Hive.openBox<Contact>(StringConstants.contacts);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<StateProvider>(
      create: (_) => StateProvider(),
    ),
    ChangeNotifierProvider<PhoneProvider>(
      create: (context) => PhoneProvider(),
    ),
    ChangeNotifierProvider<NameProvider>(
      create: (context) => NameProvider(),
    )
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Whatsapp Direct",
      theme: ThemeData.dark().copyWith(
          primaryColor: Colors.greenAccent,
          colorScheme: ColorScheme.dark(primary: green, secondary: green)),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;
  String number = "";

  static final List<Widget> _pages = <Widget>[
    const DirectMessage(),
    // Contacts(),
    if (Platform.isAndroid) const CallLogs(),
    const RecentTransactions(),
  ];

  @override
  void dispose() {
    super.dispose();
    Hive.box(StringConstants.contacts).close();
  }

  void _onItemTapped(int index) {
    context.read<StateProvider>().toIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _pages.elementAt(context.watch<StateProvider>().getCurrentIndex()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.paperplane_fill),
            label: 'Direct Message',
          ),
          if (Platform.isAndroid)
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.phone_arrow_down_left),
              label: 'Call Logs',
            ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.rectangle_expand_vertical),
            label: 'Recents',
          ),
        ],
        currentIndex: context.watch<StateProvider>().getCurrentIndex(),
        onTap: _onItemTapped,
      ),
    );
  }
}
