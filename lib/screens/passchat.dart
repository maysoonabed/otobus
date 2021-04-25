import 'package:flutter/material.dart';

import '../main.dart';

class PassChat extends StatefulWidget {
  @override
  _PassChatState createState() => _PassChatState();
}

class _PassChatState extends State<PassChat> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, //لإخفاء شريط depug
        home: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Center(
              child: Text(
                "OtoBüs",
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Pacifico',
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: apcolor,
          ),
        ));
  }
}
