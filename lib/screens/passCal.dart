import 'dart:convert';

import 'package:OtoBus/dataProvider/eventsList.dart';
import 'package:OtoBus/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

Map<DateTime, List<dynamic>> events = new Map();
CalendarController calCont;

class PassCalendar extends StatefulWidget {
  @override
  _PassCalendarState createState() => _PassCalendarState();
}

class _PassCalendarState extends State<PassCalendar> {
  @override
  void initState() {
    super.initState();
    calCont = CalendarController();
    events = {};
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
                print(date.toString());
              },
            ),
        
        
          ],
        ),
      ),
    );
  }

  
}
 