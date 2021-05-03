import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'passchat.dart';

class PassChatMessage extends StatelessWidget {
  String messageContent;
  String username;
  String msgTime;
  PassChatMessage(
      {@required this.messageContent,
      @required this.username,
      @required this.msgTime});

  @override
  Widget build(BuildContext context) {
    var currusername = myuser.name;
    //print(useremil);
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Align(
          alignment: (username != currusername
              ? Alignment.bottomLeft
              : Alignment.topRight),
          child: Column(children: [
            Material(
              // decoration: BoxDecoration(),
              borderRadius: BorderRadius.circular(20),
              color:
                  (username != currusername ? Colors.grey.shade300 : apcolor),
              elevation: 5.0,
              //padding: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  messageContent,
                  style: TextStyle(
                    fontSize: 18,
                    color: (username != currusername
                        ? Colors.black
                        : Colors.white),
                  ),
                ),
              ),
            ),
            Text(
              msgTime,
              style: TextStyle(
                fontSize: 10,
              ),
            )
          ]),
        ));
  }
}
