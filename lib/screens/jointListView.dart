import 'dart:async';

import 'package:OtoBus/dataProvider/currDriverInfo.dart';

import 'package:OtoBus/main.dart';
import 'package:OtoBus/screens/confirmJoin.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' show get;
import 'package:http/http.dart' as http;
import 'package:OtoBus/dataProvider/joined.dart';

import 'dart:convert';

String errmsg;
CurrDriverInfo dv = new CurrDriverInfo();

class JointListView extends StatefulWidget {
  final List<Joint> events;
  final String id;

  JointListView(this.events, this.id);

  @override
  _JointListViewState createState() => _JointListViewState();
}

class _JointListViewState extends State<JointListView> {
  Widget build(context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: widget.events.length,
      itemBuilder: (context, int currentIndex) {
        return createViewItem(widget.events[currentIndex], context);
      },
    );
  }

  Widget createViewItem(Joint evt, BuildContext context) {
    return widget.id == evt.id
        ? ListTile(
            trailing: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: Icon(
                        Icons.message,
                        color: apBcolor,
                      ),
                      iconSize: 20,
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        print(evt.passphone);
                      }),
                ]),
            title: new Container(
              padding: EdgeInsets.all(10.0),
              child: Row(children: <Widget>[
                Text(
                  evt.passname,
                  style: new TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ), Text(
               ', '+   evt.passengers,
                   textAlign: TextAlign.right,
                ),
                   
                    
              ]),
            ),
            onTap: () {})
        : Container(
            height: 0,
          );
  }
}

//Future is n object representing a delayed computation.
Future<List<Joint>> downJSON() async {
  final jsonEndpoint =
      "http://192.168.1.8/otobus/phpfiles/joint.php"; //10.0.0.9

  final response = await get(jsonEndpoint);

  if (response.statusCode == 200) {
    List spacecrafts = json.decode(response.body);

    return spacecrafts
        .map((spacecraft) => new Joint.fromJson(spacecraft))
        .toList();
  } else
    throw Exception('We were not able to successfully download the json data.');
}
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
