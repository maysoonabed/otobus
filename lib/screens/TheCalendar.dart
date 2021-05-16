import 'package:OtoBus/main.dart';
import 'package:OtoBus/screens/calender.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

  Map<DateTime, List<dynamic>> events=new Map();

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
        child: TableCalendar(
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
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: apcolor,
          foregroundColor: Colors.black,
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => Calendar());
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }



  
}
