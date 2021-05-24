import 'package:OtoBus/chat/PassChatDetailes.dart';
import 'package:OtoBus/chat/passchat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'globalFunctions.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PassConversationList extends StatefulWidget {
  String messageText;
  String time;
  bool isMessageRead;
  String secUseremail;
  String roomID;
  PassConversationList({
    @required this.messageText,
    @required this.time,
    @required this.isMessageRead,
    @required this.secUseremail,
    @required this.roomID,
  });
  @override
  _PassConversationListState createState() => _PassConversationListState();
}

class _PassConversationListState extends State<PassConversationList> {
  String userName = "";
  String profPic = "lib/Images/Defultprof.jpg";
  String path;
  AssetImage img;
  getUserfromphp(String usEmail) async {
    String apiurl =
        "http://192.168.1.8/otobus/lib/chat/chatphp/getImage.php"; //10.0.0.8////192.168.1.8
    var response = await http.post(apiurl, body: {'email': usEmail});
    //print(response.body);
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      setState(() {
        userName = jsondata["name"];
        path = jsondata["profpic"];
        if (path != "") {
          profPic = "phpfiles/cardlic/$path";
        }
        img = AssetImage(profPic);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /* getinfo(String em) async {
      QuerySnapshot qs = await globalFunctions().getuserinfo(em);
      //print(qs.docs[0]["name"]); print(qs.docs[0]["profpic"]);
      setState(() {
        userName = qs.docs[0]["name"];
        profPic = qs.docs[0]["profpic"];
      });
      if (profPic != null) {
        profPic = "phpfiles/cardlic/$profPic";
      } else {
        profPic = "lib/Images/Defultprof.jpg";
      }
    } */

    getUserfromphp(widget.secUseremail);
    //getinfo(widget.secUseremail);

    return GestureDetector(
      onTap: () {
        globalFunctions().updateread(widget.roomID, myuser.name);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PassChatDetailes(
            username: userName,
            imageURL: profPic,
            useremail: widget.secUseremail,
            roomID: widget.roomID,
            sendername: myuser.name,
          );
        }));
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        color: widget.isMessageRead
            ? Colors.transparent
            : Colors.grey.shade400, //Color(0xFF01d5ab), //(0xFF548279)
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: img,
                    maxRadius: 30,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            userName,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: widget.isMessageRead
                                    ? FontWeight.normal
                                    : FontWeight.bold),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.messageText,
                            style: TextStyle(
                                fontSize: widget.isMessageRead ? 13 : 16,
                                color: widget.isMessageRead
                                    ? Colors.grey.shade600
                                    : Colors.black,
                                fontWeight: widget.isMessageRead
                                    ? FontWeight.normal
                                    : FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.time,
              style: TextStyle(
                  fontSize: widget.isMessageRead ? 12 : 14,
                  fontWeight: widget.isMessageRead
                      ? FontWeight.normal
                      : FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
