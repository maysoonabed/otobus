import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'passchat.dart';

class PassChatMessage extends StatelessWidget {
  String messageContent;
  String useremil;
  PassChatMessage({@required this.messageContent, @required this.useremil});

  @override
  Widget build(BuildContext context) {
    var curruseremail = myuser.email;
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Align(
          alignment: (useremil != curruseremail
              ? Alignment.bottomLeft
              : Alignment.topRight),
          child: Material(
            // decoration: BoxDecoration(),
            borderRadius: BorderRadius.circular(20),
            color: (useremil != curruseremail ? Colors.grey.shade200 : apcolor),
            elevation: 5.0,
            //padding: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                messageContent,
                style: TextStyle(
                  fontSize: 18,
                  color:
                      (useremil != curruseremail ? Colors.black : Colors.white),
                ),
              ),
            ),
          )),
    );
  }
}
