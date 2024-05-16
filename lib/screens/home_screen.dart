import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leadboard_app/screens/Dashboard/call_screen.dart';
import 'package:leadboard_app/screens/Dashboard/dashboard_screen.dart';
import 'package:leadboard_app/screens/Dashboard/important_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _user; // variable to store the current user
  int _selectedIndex = 0; // index of the selected tab

  static final List<Widget> _widgetOptions = <Widget>[
    DashboardPage(),
    CallsPage(),
    ImportantPage(),
  ];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!; // get the current user
  }

  // Function to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex), // Show the selected tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Set the current index
        onTap: _onItemTapped, // Handle tab selection
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Important',
          ),
        ],
      ),
    );
  }
}

