import 'dart:convert';

import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:http/http.dart' as http;

class Rating extends StatefulWidget {
  final String driverId;
  Rating({this.driverId});

  @override
  _RatingState createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  double rating = 0;
  bool error, showprogress;
  String errormsg;
  TextEditingController comm;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      contentPadding: EdgeInsets.only(top: 10.0),
      content: Container(
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SmoothStarRating(
                  color: apcolor,
                  borderColor: apcolor,
                  rating: rating,
                  size: 35,
                  filledIconData: Icons.directions_bus,
                  allowHalfRating: false,
                  halfFilledIconData: Icons.star_half,
                  defaultIconData: Icons.directions_bus_outlined,
                  starCount: 5,
                  spacing: 2.0,
                  onRated: (value) {
                    setState(() {
                      rating = value;
                    });
                  },
                ),
                Text(
                  "تقييم",
                  style: TextStyle(fontSize: 24.0),
                ),
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            Divider(
              color: Colors.grey,
              height: 4.0,
            ),
            Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                controller: comm,
                textAlign: TextAlign.end,
                decoration: InputDecoration(
                  hintText: "إضافة تعليق",
                  border: InputBorder.none,
                ),
                maxLines: 8,
              ),
            ),
            InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                decoration: BoxDecoration(
                  color: apcolor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                      bottomRight: Radius.circular(32.0)),
                ),
                child: showprogress
                    ? SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          backgroundColor: apcolor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.lightGreenAccent),
                        ),
                      )
                    : Text(
                        "تقييم السائق",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  startLogin() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String apiurl = "http://10.0.0.9/otobus/phpfiles/rate.php"; //10.0.0.8//
    var response = await http.post(apiurl, body:{
      'passid': thisUser.phone, //get the username text
      'driverid': widget.driverId,
      'taq': rating.toInt(),
      'comment': comm.text,
      'report':true, //get password text
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"] == 1) {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = jsondata["message"];
        });
      } else {
        if (jsondata["success"] == 1) {
          setState(() {
            error = false;
            showprogress = false;
          });

          Navigator.pop(context);
        } else {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = "حدث خطأ";
        }
      }
    } else {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "حدث خطأ أثناء الاتصال بالشبكة";
      });
    }
  }
}
