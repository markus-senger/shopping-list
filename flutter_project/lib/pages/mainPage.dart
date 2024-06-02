import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_project/pages/listPage.dart';
import 'package:flutter_project/pages/offlineListPage.dart';
import 'package:flutter_project/pages/planPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    ListPage(),
    OfflineListPage(),
    PlanPage(),
  ];

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
        preferredSize: Size.fromHeight(40.0), // Set this to your desired height
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Einkaufsliste',
                style: TextStyle(
                  fontSize: 14.0, // Change this to your desired size
                ),
              ),
              Text(
                'v2.0.0 (06.2024)',
                style: TextStyle(
                  fontSize: 12.0, // Change this to your desired size
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
