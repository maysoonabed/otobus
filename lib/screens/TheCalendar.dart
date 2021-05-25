import 'dart:convert';

import 'package:OtoBus/dataProvider/eventsList.dart';
import 'package:OtoBus/main.dart';
import 'package:OtoBus/screens/calender.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:OtoBus/screens/driverEventList.dart';

Map<DateTime, List<dynamic>> events = new Map();
List<dynamic> selectedEvents;
SharedPreferences prefs;
String edt;

class TheCalendar extends StatefulWidget {
  @override
  _TheCalendarState createState() => _TheCalendarState();
}

class _TheCalendarState extends State<TheCalendar> {
  CalendarController calCont;

  @override
  void initState() {
    super.initState();
    calCont = CalendarController();
    edt = DateTime.now().toString();

    events = {};
    selectedEvents = [];
    initPrefs();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(prefs.getString('events') ?? "{}")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   //   backgroundColor: myG,
      appBar: AppBar(
        actions: <Widget>[
          new Container(),
        ],
        title: Text(
          "      OtoBüs Calendar",
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'Pacifico',
            color: Colors.white,
          ),
        ),
        backgroundColor: apcolor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          children: [
            TableCalendar(
              events: events,
              calendarController: calCont,
              calendarStyle: CalendarStyle(
                // contentDecoration: BoxDecoration(color:ba1color),
                todayColor: Color(0xFF93f1df),
                selectedColor: apcolor,
              ),
              startingDayOfWeek: StartingDayOfWeek.saturday,
              onDaySelected: (date, events, e) {
                edt = date.toString();
                selectedEvents = events;
                setState(() {});
              },
            ),
            Container(
              child: FutureBuilder<List<EventsList>>(
                future: downloadJSON(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<EventsList> evts = snapshot.data;

                    return DEventsListView(evts, edt);
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  return CircularProgressIndicator(
                    backgroundColor: apcolor,
                    valueColor: AlwaysStoppedAnimation<Color>(apBcolor),
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: apcolor,
          foregroundColor: Colors.black,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => Calendar())
                .then((value) => setState(() {}));
          }),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }
}
