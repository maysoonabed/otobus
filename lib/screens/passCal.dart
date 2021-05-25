import 'package:OtoBus/screens/eventsListView.dart';

import 'package:OtoBus/dataProvider/eventsList.dart';
import 'package:OtoBus/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

Map<DateTime, List<dynamic>> events = new Map();
CalendarController calCont;
String edt;

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
                setState(() {
                 edt= getFstWord(date.toString());
                });
              },
            ),
            Container(
              child: FutureBuilder<List<EventsList>>(
                future: downloadJSON(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<EventsList> evts = snapshot.data;

                    return EventsListView(evts,edt);
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
          ],
        ),
      ),
    );
  }

  String getFstWord(String input) {
    if (input.contains(' ')) {
      int i = input.indexOf(' ');
      String word = input.substring(0, i);
      return word;
    } else
      return input;
  }
}
