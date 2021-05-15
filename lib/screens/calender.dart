import 'package:OtoBus/main.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarController calCont;
  @override
  void initState() {
    super.initState();
    calCont = CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          new Container(),
        ],
        title: Center(
          child: Text(
            "OtoBüs Calendar",
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'Pacifico',
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: apcolor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
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
