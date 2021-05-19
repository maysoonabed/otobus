import 'dart:async';
import 'package:OtoBus/dataProvider/Spacecraft.dart';
import 'package:OtoBus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' show get;
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:OtoBus/configMaps.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class CustomListView extends StatefulWidget {
  final List<Spacecraft> spacecrafts;

  CustomListView(this.spacecrafts);

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  Widget build(context) {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.spacecrafts.length,
        itemBuilder: (context, int currentIndex) {
          return createViewItem(widget.spacecrafts[currentIndex], context);
        },
      ),
    );
  }

  Widget createViewItem(Spacecraft spacecraft, BuildContext context) {
    if (spacecraft.driverid == theDriver.phone) {
      return new ListTile(
          title: new Card(
            elevation: 5.0,
            child: new Container(
              /*    decoration:
                  BoxDecoration(border: Border.all(color: Colors.orange)),
         */
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Column(
                    children: [
                      Row(children: <Widget>[
                        Padding(
                            child: Text(
                              spacecraft.passid,
                              style: new TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                            padding: EdgeInsets.all(1.0)),
                        Text(" | "),
                        SmoothStarRating(
                          color: apcolor,
                          borderColor: apcolor,
                          rating: double.parse(spacecraft.taq),
                          size: 20,
                          allowHalfRating: false,
                          starCount: 5,
                          spacing: 2.0,
                          onRated: (value) {},
                        ),
                      ]),
                      Padding(
                          child: Text(
                            spacecraft.comment,
                            style: new TextStyle(fontStyle: FontStyle.italic),
                            textAlign: TextAlign.right,
                          ),
                          padding: EdgeInsets.all(1.0)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          onTap: () {});
    }
  }
}

//Future is n object representing a delayed computation.
Future<List<Spacecraft>> downloadJSON() async {
  final jsonEndpoint =
      "http://192.168.1.7/otobus/phpfiles/feedbacK.php"; //10.0.0.9

  final response = await get(jsonEndpoint);

  if (response.statusCode == 200) {
    List spacecrafts = json.decode(response.body);

    return spacecrafts
        .map((spacecraft) => new Spacecraft.fromJson(spacecraft))
        .toList();
  } else
    throw Exception('We were not able to successfully download the json data.');
}
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
