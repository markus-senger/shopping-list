import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project/pages/listPage.dart';
import 'package:flutter_project/pages/offlineListPage.dart';
import 'package:flutter_project/pages/planPage.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const List<Widget> _pages = <Widget>[
    ListPage(),
    OfflineListPage(),
    PlanPage(),
  ];

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      log('Signed in: ${userCredential.user?.email}');
    } catch (e) {
      log('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    login();
  }

  Future<void> login() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final List<String> credentials =
        await readCredentialsFromFile("assets/credentials.txt");
    signInWithEmailAndPassword(credentials[0], credentials[1]);
  }

  Future<List<String>> readCredentialsFromFile(String filePath) async {
    try {
      final string = await rootBundle.loadString(filePath);
      final lines = string.split(';');
      return lines;
    } catch (e) {
      log('Error reading data: $e');
      return List.empty();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return ListPage(key: UniqueKey());
      case 1:
        return OfflineListPage(key: UniqueKey());
      case 2:
        return PlanPage(key: UniqueKey());
      default:
        return ListPage(key: UniqueKey());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Einkaufsliste',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              Text(
                'v2.0.0 (06.2024)',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: _getSelectedPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Liste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_for_offline),
            label: 'Offline Liste',
          ),
          /*BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Speiseplan',
          ),*/
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        backgroundColor: Colors.black87,
      ),
    );
  }
}
