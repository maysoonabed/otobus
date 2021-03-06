import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class DriverMap extends StatefulWidget {
  @override
  _DriverMapState createState() => _DriverMapState();
}

int _page = 0;
GlobalKey _bottomNavigationKey = GlobalKey();

class _DriverMapState extends State<DriverMap> {
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, //لإخفاء شريط depug
        home: Scaffold(
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
          body: Container(
            alignment: Alignment.bottomCenter,
            color: ba1color,
            width: double.infinity,
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(_page.toString(), textScaleFactor: 10.0),
                  RaisedButton(
                    child: Text('Go To Page of index 1'),
                    onPressed: () {
                      //Page change using state does the same as clicking index 1 navigation button
                      final CurvedNavigationBarState navBarState =
                          _bottomNavigationKey.currentState;
                      navBarState.setPage(1);
                    },
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar: CurvedNavigationBar(
            color: apcolor,
            backgroundColor: ba1color,
            items: <Widget>[
              Icon(
                Icons.messenger,
                size: 30,
                color: Colors.white,
              ),
              Icon(
                Icons.notifications,
                size: 30,
                color: Colors.white,
              ),
              Icon(
                Icons.person,
                size: 30,
                color: Colors.white,
              ),
            ],
            onTap: (index) {
              _page = index;
            },
          ),
        ));
  }
}
