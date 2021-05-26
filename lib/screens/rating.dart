import 'dart:convert';

import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:http/http.dart' as http;

class Rating extends StatefulWidget {
  final String driverPhone;
  Rating({this.driverPhone});

  @override
  _RatingState createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  double rating = 0;
  bool showprogress = false;
  String errormsg;
  String comm;
  int rep = 0;
  String repo = 'إبلاغ';

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
                  allowHalfRating: false,
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
                textAlign: TextAlign.end,
                onChanged: (value) {
                  comm = value;
                },
                decoration: InputDecoration(
                  hintText: "إضافة تعليق",
                  border: InputBorder.none,
                ),
                maxLines: 6,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    tooltip: repo,
                    alignment: Alignment.bottomLeft,
                    icon: Icon(
                      rep == 0 ? Icons.report_off_outlined : Icons.report,
                      color: rep == 0 ? Colors.grey : Colors.red,
                    ),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      setState(() {
                        rep == 0 ? rep = 1 : rep = 0;
                        rep == 0 ? repo = 'إبلاغ' : repo = 'عدم الإبلاغ';
                      });
                    }),
              ],
            ),
            InkWell(
              onTap: () {
                setState(() {
                  //show progress indicator on click
                  showprogress = true;
                });

                rate();
              },
              child: Container(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                decoration: BoxDecoration(
                  color: apcolor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                      bottomRight: Radius.circular(32.0)),
                ),
                child: showprogress
                    ? Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            backgroundColor: apcolor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.lightGreenAccent),
                          ),
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

  rate() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String apiurl =
        "http://192.168.1.108:8089/otobus/phpfiles/rate.php"; //10.0.0.8//
    var response = await http.post(apiurl, body: {
      'passid': thisUser.name, //get the username text
      'passphone': thisUser.phone,
      'driverid': widget.driverPhone,
      'taq': rating.toInt().toString(),
      'comment': comm != null ? comm : '-',
      'report': rep.toString() //get password text
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"] == 1) {
        setState(() {
          showprogress = false; //don't show progress indicator
          errormsg = jsondata["message"];
        });
      } else {
        if (jsondata["success"] == 1) {
          setState(() {
            showprogress = false;
            errormsg = jsondata["message"];
          });
          Navigator.pop(context);
        } else {
          setState(() {
            showprogress = false; //don't show progress indicator
            errormsg = "حدث خطأ";
          });
        }
      }
    } else {
      setState(() {
        showprogress = false; //don't show progress indicator
        errormsg = "حدث خطأ أثناء الاتصال بالشبكة";
      });
    }
    Fluttertoast.showToast(
      context,
      msg: errormsg,
    );
  }
}
