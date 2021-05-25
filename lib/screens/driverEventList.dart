import 'dart:async';
import 'package:OtoBus/dataProvider/Spacecraft.dart';
import 'package:OtoBus/dataProvider/currDriverInfo.dart';
import 'package:OtoBus/dataProvider/eventsList.dart';
import 'package:OtoBus/main.dart';
import 'package:OtoBus/screens/jointListView.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' show get;
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/dataProvider/joined.dart';

CurrDriverInfo dv = new CurrDriverInfo();
String errormsg;

class DEventsListView extends StatefulWidget {
  final List<EventsList> events;
  final String edt;

  DEventsListView(this.events, this.edt);

  @override
  _DEventsListViewState createState() => _DEventsListViewState();
}

class _DEventsListViewState extends State<DEventsListView> {
  Map<String, bool> lights = {};

  Widget build(context) {
    return Expanded(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.events.length,
        itemBuilder: (context, int currentIndex) {
          return createViewItem(widget.events[currentIndex], context);
        },
      ),
    );
  }

  Widget createViewItem(EventsList evt, BuildContext context) {
    return widget.edt.contains(evt.eDate) &&
            evt.driverPhoneNumber == thisUser.phone
        ? Card(
            elevation: 3.0,
            child: Theme(
              data: ThemeData(
                primaryColor: const Color(0xFF02BB9F),
                primaryColorDark: const Color(0xFF167F67),
                accentColor: const Color(0xFF167F67),
              ),
              child: ExpansionTile(
                title: new Container(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: <Widget>[
                      Column(
                        children: [
                          Row(children: <Widget>[
                            Padding(
                                child: Text(
                                  evt.eTime,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                                padding: EdgeInsets.all(1.0)),
                          ]),
                          Padding(
                              child: Text(
                                evt.pick +
                                    ' إلى ' +
                                    evt.dest +
                                    ', باقي ' +
                                    evt.passengers +
                                    ' ركاب ',
                                style:
                                    new TextStyle(fontStyle: FontStyle.italic),
                                textAlign: TextAlign.right,
                              ),
                              padding: EdgeInsets.all(1.0)),
                        ],
                      ),
                    ],
                  ),
                ),
                trailing: Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                      activeColor: apBcolor,
                      value: /*  lights[evt.id] != null ? lights[evt.id] : */ evt
                                  .st ==
                              '1'
                          ? true
                          : false,
                      onChanged: (bool value) {
                        setState(() {
                          evt.st = value ? '1' : '0';
                          changeSt(evt.id, evt.st);
                        });
                      }),
                ),
                children: [
                  Divider(),
                  FutureBuilder<List<Joint>>(
                    future: downJSON(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Joint> evts = snapshot.data;

                        return JointListView(evts, evt.id);
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }

                      return CircularProgressIndicator(
                        backgroundColor: apcolor,
                        valueColor: AlwaysStoppedAnimation<Color>(apBcolor),
                      );
                    },
                  ),
                ],
              ),
            ) /*    onTap: () {
              print(evt.id);
            } */
            )
        : Container(
            height: 0,
          );
  }

  changeSt(String id, String st) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String apiurl =
        "http://192.168.1.8/otobus/phpfiles/changeSt.php"; //10.0.0.8//
    var response = await http.post(apiurl, body: {
      'id': id,
      'status':st,
    });
  }
}

//Future is n object representing a delayed computation.
Future<List<EventsList>> downloadJSON() async {
  final jsonEndpoint =
      "http://192.168.1.8/otobus/phpfiles/events.php"; //10.0.0.9

  final response = await get(jsonEndpoint);

  if (response.statusCode == 200) {
    List spacecrafts = json.decode(response.body);

    return spacecrafts
        .map((spacecraft) => new EventsList.fromJson(spacecraft))
        .toList();
  } else
    throw Exception('We were not able to successfully download the json data.');
}

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
