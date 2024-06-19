import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:smoke_spot_dev/providers/bookmark_provider.dart';
import 'providers/providers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/pages.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestWritePermission();


  // Load JSON data
  String jsonString = await rootBundle.loadString('assets/data/smokeSpots.json');

  runApp(
    MyApp(jsonString: jsonString),
  );
}

Future<void> requestWritePermission() async {
  if (!(await Permission.storage.request().isGranted)) {
    await Permission.storage.request();
  }
}

class MyApp extends StatelessWidget {
  final String jsonString;

  const MyApp({super.key, required this.jsonString});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SmokeSpotProvider()..loadSmokeSpots(jsonString),
        ),
        ChangeNotifierProvider(
          create: (_) => BookmarkProvider()
        ),
      ],
      child: MaterialApp(
        title: 'SmokingSpot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: SplashPage(),
      ),
    );
  }
}
