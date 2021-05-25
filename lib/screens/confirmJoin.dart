import 'dart:convert';

import 'package:OtoBus/configMaps.dart';
import 'package:OtoBus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ConfJoin extends StatefulWidget {
  final String pass;
  final String id;
  ConfJoin({this.pass, this.id});

  @override
  _ConfJoinState createState() => _ConfJoinState();
}

class _ConfJoinState extends State<ConfJoin> {
  int cont;
  bool processing = false;
  String errormsg = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        content: Container(
          margin: EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(4)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Text(
                'تأكيد الحجز',
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
                        ? Center(
                            child: CircularProgressIndicator(
                            backgroundColor: apcolor,
                            valueColor: AlwaysStoppedAnimation<Color>(apBcolor),
                          ))
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
                                      'تأكيد',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Lemonada'),
                                    ),
                                    onPressed: () {
                                      processing = true;
                                      join();
                                    }),
                              ]),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  join() async {
    int x = int.parse(widget.pass) - cont;
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    String apiurl =
        "http://192.168.1.8/otobus/phpfiles/joinEvent.php"; //10.0.0.8//
    var response = await http.post(apiurl, body: {
      'passphone': thisUser.phone,
      'id': widget.id,
      'newP': x.toString(),
      'passengers': cont.toString(),
      'name': thisUser.name
    });

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["error"] == 1) {
        setState(() {
          processing = false; //don't show progress indicator
          errormsg = jsondata["message"];
        });
      } else {
        if (jsondata["success"] == 1) {
          setState(() {
            processing = false;
            errormsg = jsondata["message"];
          });
        } else {
          setState(() {
            processing = false; //don't show progress indicator
            errormsg = "حدث خطأ";
          });
        }
      }
    } else {
      setState(() {
        processing = false; //don't show progress indicator
        errormsg = "حدث خطأ أثناء الاتصال بالشبكة";
      });
    }
    Fluttertoast.showToast(
      context,
      msg: errormsg,
    );
    Navigator.pop(context);
  }
}
