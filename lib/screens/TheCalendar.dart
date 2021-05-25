import 'dart:convert';

import 'package:OtoBus/main.dart';
import 'package:OtoBus/screens/calender.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

Map<DateTime, List<dynamic>> events = new Map();
List<dynamic> selectedEvents;
SharedPreferences prefs;

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              events: events,
              calendarController: calCont,
              calendarStyle: CalendarStyle(
                todayColor: Color(0xFF93f1df),
                selectedColor: apcolor,
              ),
              startingDayOfWeek: StartingDayOfWeek.saturday,
              onDaySelected: (date, events, e) {
                setState(() {
                  selectedEvents = events;
                });
  
              },
            ),
            ...selectedEvents.map((event) => ListTile(
                  title: Text(event),
                )),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
