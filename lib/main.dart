import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:leadboard_app/screens/home_screen.dart';
import 'package:leadboard_app/screens/signin_screen.dart';


//Add you own Constants to add your firebase
class Constants {
  static String appId = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
  static String apiKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
  static String messagingSenderId = "XXXXXXXXX";
  static String projectId = "XXXXXXXXXXXXXXXXXXXXXX";
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Constants.apiKey,
      appId: Constants.appId,
      messagingSenderId: Constants.messagingSenderId,
      projectId: Constants.projectId,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final auth = FirebaseAuth.instance;
  late bool isLogin;

  @override
  void initState() {
    super.initState();
    isLogin = auth.currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Future.delayed(Duration(seconds: 2)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return isLogin ? HomeScreen() : SignInScreen();
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
