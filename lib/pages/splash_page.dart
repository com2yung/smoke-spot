import 'package:flutter/material.dart';
import 'package:smoke_spot/pages/pages.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(milliseconds: 2000), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Smoking Spot',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white, 
                  fontWeight: FontWeight.bold, 
                  fontStyle: FontStyle.italic,
                  )
                ),
          ],
        ),
      ),
    );
  }
}