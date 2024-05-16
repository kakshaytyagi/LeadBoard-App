import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leadboard_app/screens/signin_screen.dart'; // Assuming the SignInScreen is imported here

class DrawerContent extends StatefulWidget {
  final String? userName; // Define userName as a parameter

  DrawerContent({Key? key, this.userName}) : super(key: key);

  @override
  State<DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends State<DrawerContent> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 250, 103, 203),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Welcome,',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.userName ?? 'User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            leading: Icon(
              Icons.logout,
              size: 24,
            ),
            onTap: () {
              // Sign out the user
              FirebaseAuth.instance.signOut().then((value) {
                print("Signed Out");
                // Navigate to the sign-in screen
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SignInScreen()));
              });
            },
          ),
          // Add more list items as needed
        ],
      ),
    );
  }
}
