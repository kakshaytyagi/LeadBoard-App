import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leadboard_app/reusable_widgets/reusable_widget.dart';
import 'package:leadboard_app/screens/home_screen.dart';
import 'package:leadboard_app/screens/signin_screen.dart';
import 'package:leadboard_app/utils/color_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var auth = FirebaseAuth.instance;
  var isLogin = false;

  checkifLogin() async {
    auth.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {
          isLogin = true;
        });
      }
    });
  }

  @override
  void initState() {
    checkifLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This Future.delayed method waits for a specified duration and then executes its callback
    Future.delayed(Duration(seconds: 2), () {
      // After 3 seconds, navigate to the SignInScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => isLogin ? HomeScreen() :SignInScreen(),
        ),
      );
    });

    // Return a widget for the splash screen UI
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4")
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logoWidget("assets/images/logo.png"),
            SizedBox(height: 90),
            Text(
              'Developed with ♥ by Akshay',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
