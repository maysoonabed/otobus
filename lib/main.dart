import 'package:flutter/material.dart';

Color apcolor = const Color(0xFF1ABC9C);
Color apBcolor = const Color(0xFF00796B);
Color bacolor = const Color(0xFFBDBDBD);

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openEndDrawer() {
    _scaffoldKey.currentState.openEndDrawer();
  }

  // void _closeEndDrawer() {Navigator.of(context).pop(); } For close the drawer

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //لإخفاء شريط depug
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "OtoBüs",
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'Pacifico',
              color: Colors.white,
            ),
          ),
          backgroundColor: apcolor,
        ),
        body: Container(
          //alignment: Alignment.bottomCenter,
          color: bacolor,
          width: double.infinity,
          child: Column(
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed))
                        return apBcolor;
                      return apcolor; // Use the component's default.
                    },
                  ),
                ),
                onPressed: _openEndDrawer,
                child: Text('Your information'),
              ),
            ],
          ),
        ),
        endDrawer: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                
              ),
              ListTile(

              ),
              ListTile(
                
              ),
              ListTile(
                
              ),

            ],
          ),
        ),
      ),
    );
  }
}
