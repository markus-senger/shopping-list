import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import '../firebase_options.dart';
import 'pages/mainPage.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  runApp(const ShoppingApp());
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShoppingList',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Colors.black87,
          secondary: Colors.orangeAccent,
          surface: Colors.black54,
          background: Colors.grey,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}
