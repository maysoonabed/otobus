import 'dart:convert';

import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/dataProvider/address.dart';
import 'package:OtoBus/main.dart';
import 'package:OtoBus/screens/CalendarClient.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:OtoBus/screens/TheCalendar.dart';

Adress dest = new Adress();
Adress pick = new Adress();

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarClient calendarClient = CalendarClient();
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(Duration(days: 1));
  TextEditingController _dest = TextEditingController();
  TextEditingController _date = TextEditingController();
  TextEditingController _pick = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  bool processing = false;

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        child: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.all(4),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                Text(
                  'حجز توصيلة',
                  style: TextStyle(fontFamily: 'Lemonada', fontSize: 18),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Theme(
                        data: Theme.of(context).copyWith(primaryColor: apcolor),
                        child: TextFormField(
                          minLines: 1,
                          maxLines: null,
                          readOnly: true,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.date_range),
                            hintText: 'الموعد',
                          ),
                          controller: _date,
                          onTap: () {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) {
                                return _buildBottomPicker(
                                  CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.dateAndTime,
                                    minimumDate: DateTime.now(),
                                    maximumDate: DateTime(2021, 6, 7),
                                    onDateTimeChanged: (DateTime newDateTime) {
                                      if (mounted) {
                                        {
                                          setState(() {
                                            _date.text = newDateTime.toString();
                                            this.startTime = newDateTime;
                                          });
                                        }
                                      }
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          enabled: true,
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(primaryColor: apcolor),
                        child: TextFormField(
                          minLines: 1,
                          maxLines: null,
                          readOnly: true,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_on),
                            hintText: 'الموقف',
                          ),
                          controller: _pick,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapBoxAutoCompleteWidget(
                                  apiKey: tokenkey,
                                  hint: "حدد مكان اللقاء",
                                  onSelect: (place) {
                                    _pick.text = place.placeName;
                                    setState(() {
                                      pick.lat = place.center[1];
                                      pick.long = place.center[0];
                                      pick.placeName = place.placeName;
                                    });
                                  },
                                  limit: 30,
                                  country: 'Ps',
                                ),
                              ),
                            );
                          },
                          enabled: true,
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(primaryColor: apcolor),
                        child: TextFormField(
                          minLines: 1,
                          maxLines: null,
                          readOnly: true,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_on_outlined),
                            hintText: 'الوجهة',
                          ),
                          controller: _dest,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapBoxAutoCompleteWidget(
                                  apiKey: tokenkey,
                                  hint: "حدد وجهتك",
                                  onSelect: (place) {
                                    _dest.text = place.placeName;
                                    setState(() {
                                      dest.lat = place.center[1];
                                      dest.long = place.center[0];
                                      dest.placeName = place.placeName;
                                    });
                                    print(dest.lat.toString() +
                                        dest.long.toString());
                                  },
                                  limit: 30,
                                  country: 'Ps',
                                ),
                              ),
                            );
                          },
                          enabled: true,
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(primaryColor: apcolor),
                        child: TextFormField(
                          textAlign: TextAlign.end,
                          onChanged: (v) {
                            numCont = int.parse(v);
                          },
                          keyboardType: TextInputType.number,
                          autofocus: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            hintText: 'عدد الركاب',
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      processing
                          ? Center(child: CircularProgressIndicator())
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                  FlatButton(
                                      child: const Text(
                                        'إلغاء',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Lemonada'),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                  FlatButton(
                                      child: Text(
                                        'حفظ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Lemonada'),
                                      ),
                                      onPressed: () {
                                        calendarClient.insert(
                                            'going to ' + _dest.text,
                                            startTime,
                                            startTime);
                                        setState(() {
                                          if (events[startTime] != null) {
                                            events[startTime].add('going to ' +
                                                _dest.text +
                                                'at' +
                                                startTime.hour.toString() +
                                                ':' +
                                                startTime.minute.toString());
                                          } else {
                                            events[startTime] = [
                                              'going to ' +
                                                  _dest.text +
                                                  'at' +
                                                  startTime.hour.toString() +
                                                  ':' +
                                                  startTime.minute.toString()
                                            ];
                                          }

                                          prefs.setString("events",
                                              json.encode(encodeMap(events)));
                                        });

                                        Navigator.pop(context);
                                      }),
                                ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  double _kPickerSheetHeight = 216.0;
  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      // padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  void book() {
    bookRef = FirebaseDatabase.instance.reference().child('Bookings').push();
    Map pickUpMap = {
      'longitude': pick.long.toString(),
      'latitude': pick.lat.toString(),
    };
    Map destinationMap = {
      'longitude': dest.long.toString(),
      'latitude': dest.lat.toString(),
    };
    Map rideMap = {
      'createdAt': startTime.toString(),
      'passengerName': thisUser.name,
      'passengerPhone': thisUser.phone,
      'pickUpAddress': pick.placeName,
      'destinationAddress': dest.placeName,
      'location': pickUpMap,
      'destination': destinationMap,
      'driver_id': 'waiting',
      'status': 'waiting',
      'passengers': numCont != null ? numCont : 1,
    };
    bookRef.set(rideMap);
  }
}
