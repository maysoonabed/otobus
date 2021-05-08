import 'package:cube_transition/cube_transition.dart';
import 'package:flutter/material.dart';
import 'PassMap.dart';
import 'PassengerPage.dart';
import '../main.dart';
import 'package:firebase_core/firebase_core.dart';

class MapTy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return Material(
        // debugShowCheckedModeBanner: false, //لإخفاء شريط depug
        type: MaterialType.transparency,
        child: new Container(
            alignment: Alignment.bottomCenter,
            width: double.infinity,
            child: Container(
                color: Colors.white,
                child: ListView(
                  children: [
                    SizedBox(
                      height: 200.0,
                    ),
                    //*********************************
                    Center(
                        child: Text(
                      ' نوع الخريطة المراد استخدامها ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Lemonada', //'ArefRuqaaR',
                          fontWeight: FontWeight.bold),
                    )),
                    //*********************************
                    Container(
                      height: 30,
                    ),
                    //*********************************
                    RawMaterialButton(
                      fillColor: apBcolor,
                      splashColor: Colors.greenAccent,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const <Widget>[
                            Icon(
                              Icons.zoom_out_map_outlined,
                              color: Colors.amber,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '   Google Map   ',
                              maxLines: 1,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          CubePageRoute(
                            enterPage: PassMap(),
                            exitPage: MapTy(),
                            duration: const Duration(milliseconds: 1300),
                          ),
                        );
                      },
                      shape: const StadiumBorder(),
                    ),
                    //*********************************
                    Container(
                      height: 30,
                    ),
                    //*********************************
                    RawMaterialButton(
                      fillColor: apBcolor,
                      splashColor: Colors.greenAccent,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const <Widget>[
                            Icon(
                              Icons.map_rounded,
                              color: Colors.amber,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Open Street Map',
                              maxLines: 1,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          CubePageRoute(
                            enterPage: PassengerPage(),
                            exitPage: MapTy(),
                            duration: const Duration(milliseconds: 1300),
                          ),
                        );
                      },
                      shape: const StadiumBorder(),
                    ),
                  ],
                ))));
  }
}
