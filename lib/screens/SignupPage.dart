import 'package:flutter/material.dart';
import '../main.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //لإخفاء شريط depug
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "إنشاء حساب جديد",
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'Pacifico',
              color: Colors.white,
            ),
          ),
          backgroundColor: apcolor,
          centerTitle: true,
        ),
        body: Container(
          alignment: Alignment.bottomCenter,
          color: bacolor,
          width: double.infinity,
        ),
      ),
    );
  }
}
