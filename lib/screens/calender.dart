import 'dart:convert';

import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/dataProvider/address.dart';
import 'package:OtoBus/main.dart';
import 'package:OtoBus/screens/CalendarClient.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:OtoBus/screens/TheCalendar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

Adress dest = new Adress();
Adress pick = new Adress();
String errormsg;
int cont;
String d, t;

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
                                    setState(() {
                                      pick.lat = place.center[1];
                                      pick.long = place.center[0];
                                      pick.placeName = place.placeName;
                                      var str = place.placeName.toString();
                                      var ss = str.split(',');
                                      _pick.text = ss[0];
                                    });
                                  },
                                  limit: 30,
                                  country: 'Ps',
                                  language: 'ar',
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
                                    setState(() {
                                      dest.lat = place.center[1];
                                      dest.long = place.center[0];
                                      dest.placeName = place.placeName;
                                      var str = place.placeName.toString();
                                      var ss = str.split(',');
                                      _dest.text = ss[0];
                                    });
                                  },
                                  limit: 30,
                                  country: 'Ps',
                                  language: 'ar',
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
                            cont = int.parse(v);
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
                                        int i =
                                            startTime.toString().indexOf(' ');
                                        d = startTime
                                            .toString()
                                            .substring(0, i);
                                        int j =
                                            startTime.toString().indexOf('.');
                                        t = startTime
                                            .toString()
                                            .substring(i + 1, j);
                                        addEvent();
                                        calendarClient.insert(
                                            'going to ' + _dest.text,
                                            startTime,
                                            startTime);
                                        setState(() {
                                          if (events[startTime] != null) {
                                            events[startTime].add('going to ' +
                                                _dest.text +
                                                ' at ' +
                                                t);
                                          } else {
                                            events[startTime] = [
                                              'going to ' +
                                                  _dest.text +
                                                  ' at ' +
                                                  t
                                            ];
                                          }

                                          prefs.setString(thisUser.phone,
                                              json.encode(encodeMap(events)));
                                        });
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

  addEvent() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String apiurl =
        "http://192.168.1.8/otobus/phpfiles/addEvent.php"; //10.0.0.8//
    var response = await http.post(apiurl, body: {
      'driverphone': thisUser.phone, //get the username text
      'pick': _dest.text,
      'dest': _pick.text,
      'passengers': cont.toString(),
      'eDate': d,
      'eTime': t,
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"] == 1) {
        setState(() {
          errormsg = jsondata["message"];
        });
      } else {
        if (jsondata["success"] == 1) {
          setState(() {
            errormsg = jsondata["message"];
          });
          Navigator.pop(context);
        } else {
          setState(() {
            errormsg = "حدث خطأ";
          });
        }
      }
    } else {
      setState(() {
        errormsg = "حدث خطأ أثناء الاتصال بالشبكة";
      });
    }
    Fluttertoast.showToast(
      context,
      msg: errormsg,
    );
  }
}
