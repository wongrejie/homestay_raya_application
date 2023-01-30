import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'mainscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required String title});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    User user = User(
        id: "0",
        email: "unknown",
        name: "unregistered",
        address: "na",
        phone: "0123456789",
        regdate: "0",
        credit: "0");
    Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (content) => MainScreen(user: user))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/homestay_splashscreen.jpg'),
                        fit: BoxFit.cover))),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text(
                    "Homestay Raya",
                    style: TextStyle(
                        fontFamily: 'WinterSong',
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(
                      child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  )),
                  Text("Beta Version 0.1",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
