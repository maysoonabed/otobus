import 'dart:async';
import 'package:OtoBus/dataProvider/Spacecraft.dart';
import 'package:OtoBus/dataProvider/currDriverInfo.dart';
import 'package:OtoBus/dataProvider/eventsList.dart';
import 'package:OtoBus/main.dart';
import 'package:OtoBus/screens/confirmJoin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' show get;
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/screens/botomsheetclone.dart';

String errmsg;
CurrDriverInfo dv = new CurrDriverInfo();

class EventsListView extends StatefulWidget {
  final List<EventsList> events;
  final String edt;

  EventsListView(this.events, this.edt);

  @override
  _EventsListViewState createState() => _EventsListViewState();
}

class _EventsListViewState extends State<EventsListView> {
  Widget build(context) {
    return Expanded(
      child: ListView.builder(
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
            evt.passengers != '0' &&
            evt.st != '0'
        ? ListTile(
            trailing: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: Icon(
                        Icons.person,
                        color: apBcolor,
                      ),
                      iconSize: 20,
                      padding: EdgeInsets.all(0),
                      onPressed: () async {
                        await getDriverInfo(evt.driverPhoneNumber);
                        await getRatings(evt.driverPhoneNumber);
                        showBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (BuildContext context) {
                              return BottomClone(
                                  dv: dv); // returns your BottomSheet widget
                            });
                      }),
                  IconButton(
                      icon: Icon(
                        Icons.message,
                        color: apBcolor,
                      ),
                      iconSize: 20,
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        print(evt.driverPhoneNumber);
                      }),
                ]),
            title: new Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Column(
                    children: [
                      Row(children: <Widget>[
                        Padding(
                            child: Text(
                              evt.eTime,
                              style: new TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                            padding: EdgeInsets.all(1.0)),
                      ]),
                      Padding(
                          child: Text(
                            evt.dest +
                                ' إلى ' +
                                evt.pick +
                                ', ' +
                                evt.passengers +
                                ' ركاب ',
                            style: new TextStyle(fontStyle: FontStyle.italic),
                            textAlign: TextAlign.right,
                          ),
                          padding: EdgeInsets.all(1.0)),
                    ],
                  ),
                  Divider(),
                ],
              ),
            ),
            onTap: () {
              print(evt.id);
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) =>
                      ConfJoin(pass: evt.passengers, id: evt.id));
            })
        : Container(
            height: 0,
          );
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Future<void> getDriverInfo(String phone) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String apiurl =
        "http://192.168.1.8/otobus/phpfiles/getDriverInfo.php"; //10.0.0.8//
    var response = await http.post(apiurl, body: {
      'phone': phone,
    });
    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"] == 1) {
        errmsg = jsondata["message"];
        Fluttertoast.showToast(
          context,
          msg: errmsg != null ? errmsg : 'hi',
        );
      } else {
        dv.phone = phone;
        dv.name = jsondata["name"];
        dv.pic = jsondata['profpic'];
        dv.begN = jsondata['begN'];
        dv.endN = jsondata['endN'];
        dv.busType = jsondata["busType"];

        var x = jsondata["rate"];
        dv.rate = double.parse(x);
        var xx = jsondata["numOfPass"];
        dv.numOfPass = int.parse(xx);
        errmsg = jsondata["message"];
      }
    } else {
      errmsg = "حدث خطأ أثناء الاتصال بالشبكة";
      Fluttertoast.showToast(
        context,
        msg: errmsg != null ? errmsg : 'hi',
      );
    }
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  getRatings(String phone) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String apiurl =
        "http://192.168.1.8/otobus/phpfiles/avgRatings.php"; //10.0.0.8//
    var response = await http.post(apiurl, body: {
      'phone': phone, //get the username text
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"] == 1) {
        errmsg = jsondata["message"];
        Fluttertoast.showToast(
          context,
          msg: errmsg,
        );
      } else {
        if (jsondata["success"] == 1) {
          print(jsondata['cou']);
          rateCount = int.parse(jsondata['cou']);
          s1 = int.parse(jsondata['cnt1']);
          s2 = int.parse(jsondata['cnt2']);
          s3 = int.parse(jsondata['cnt3']);
          s4 = int.parse(jsondata['cnt4']);
          s5 = int.parse(jsondata['cnt5']);

          errmsg = jsondata["message"];
        } else {
          errmsg = "حدث خطأ";
          Fluttertoast.showToast(
            context,
            msg: errmsg,
          );
        }
      }
    } else {
      errmsg = "حدث خطأ أثناء الاتصال بالشبكة";
      Fluttertoast.showToast(
        context,
        msg: errmsg,
      );
    }
  }

  //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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
