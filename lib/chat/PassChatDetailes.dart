import 'package:OtoBus/chat/passchat.dart';
import 'package:OtoBus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'PasschatMessageModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'globalFunctions.dart';
import '../configMaps.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//******************************************************/
var mesg = TextEditingController();
var mes = "";
String messageId = "";
String chatRoomId = "";
AssetImage img;
String myusName;
//******************************************************/
Future addmsgToDatabase(String chatRoomId, String msgId, Map msgInfoMap) async {
  return FirebaseFirestore.instance
      .collection("chatrooms")
      .doc(chatRoomId)
      .collection("chats")
      .doc(msgId)
      .set(msgInfoMap);
}

//*********************************//
updateLastMessageSend(String chatRoomId, Map lastMessageInfoMap) {
  return FirebaseFirestore.instance
      .collection("chatrooms")
      .doc(chatRoomId)
      .update(lastMessageInfoMap);
}

//*********************************//
addMessage(bool sendClicked) {
  String masS = mes;
  if (masS != "") {
    //mesg.text
    var lastMessageTs = DateTime.now();

    Map<String, dynamic> messageInfoMap = {
      "message": masS,
      "sendBy": myusName,
      "ts": lastMessageTs,
      "read": false
    };
    if (messageId == "") {
      messageId = randomAlphaNumeric(12);
    }
    addmsgToDatabase(chatRoomId, messageId, messageInfoMap).then((value) {
      Map<String, dynamic> lastMessageInfoMap = {
        "lastMessageSendBy": myusName,
        "lastMessageSendTs": lastMessageTs,
        "lastMessage": masS,
        "lastmsgread": false
      };
      updateLastMessageSend(chatRoomId, lastMessageInfoMap);
      if (sendClicked) {
        masS = "";
        mes = "";
        mesg.text = "";
        messageId = "";
      }
    });
  }
}

//*********************************//
class PassChatDetailes extends StatefulWidget {
  String username;
  String imageURL;
  String useremail;
  String roomID;
  String sendername;
  PassChatDetailes(
      {@required this.username,
      @required this.imageURL,
      @required this.useremail,
      @required this.roomID,
      @required this.sendername});
  @override
  _PassChatDetailesState createState() => _PassChatDetailesState();
}

//******************************************************/
var tokken = "";
var usiidd = "";

void sendNotifToUser(String token, String msg, String usname) async {
  Map<String, String> headerMap = {
    'Content-Type': 'application/json',
    'Authorization': serverToken,
  };
  Map notificationMap = {'body': msg, 'title': usname};
  Map dataMap = {
    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    'id': '1',
    'status': 'done',
  };
  Map sendNotificationMao = {
    "notification": notificationMap,
    "data": dataMap,
    'priority': 'high',
    'to': token,
  };
  var respon = await http.post(
    'https://fcm.googleapis.com/fcm/send',
    headers: headerMap,
    body: jsonEncode(sendNotificationMao),
  );
}

class _PassChatDetailesState extends State<PassChatDetailes> {
  @override
  Widget build(BuildContext context) {
    setState(() {
      chatRoomId = widget.roomID;
      myusName = widget.sendername;
      img = AssetImage(widget.imageURL);
    });
    var sStream = globalFunctions().getUserByEmail(widget.useremail);
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  CircleAvatar(
                    backgroundImage: img,
                    maxRadius: 20,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.username,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          "Online",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.settings, color: Colors.black54),
                      onPressed: () {})
                ],
              ),
            ),
          ),
        ),
        /******************************************************/
        body: Stack(children: <Widget>[
          StreamBuilder(
              stream: sStream,
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = snapshot.data.docs[index];
                          usiidd = ds.id;
                          tokken = ds["token"];
                          return Container();
                        })
                    : Container();
              }),
          Container(
            padding: EdgeInsets.only(bottom: 65),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .doc(chatRoomId)
                  .collection("chats")
                  .orderBy("ts", descending: true)
                  .snapshots(), //firestore.collection('passMessages').snapshots(),
              builder: (context, snapshot) {
                //controller:listScrollController;
                if (!snapshot.hasData) {
                  return Container(//width: 0.0, height: 0.0,
                      );
                }

                final msgs = snapshot.data.docs;
                List<PassChatMessage> messages = [];
                for (var message in msgs) {
                  final messText = message.data()['message'];
                  final messSender = message.data()['sendBy'];
                  final Timestamp timestamp = message.data()['ts'] as Timestamp;
                  final DateTime dateTime = timestamp.toDate();
                  final dateString = DateFormat('dd/M k:mm').format(dateTime);
                  //print(messText);print(messSender);
                  final msgwidget = PassChatMessage(
                    messageContent: messText,
                    username: messSender,
                    msgTime: dateString,
                    sendername: widget.sendername,
                  );
                  messages.add(msgwidget);
                }
                return ListView(
                  reverse: true,
                  children: messages,
                );
              },
            ),
          ),
          /******************************************************/
          Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        print(usiidd);
                        print(tokken);
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: apBcolor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: TextField(
                        onTap: () {
                          globalFunctions().updateread(widget.roomID, myusName);
                        },
                        controller: mesg,
                        onChanged: (value) {
                          setState(() {
                            mes = value;
                          });
                        },
                        decoration: InputDecoration(
                            hintText: "Write message...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        addMessage(true);
                        sendNotifToUser(tokken, mes, widget.sendername);
                        //SystemChannels.textInput.invokeMethod('TextInput.hide'),
                        /*  listScrollController.animateTo(0.0,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOut); */
                        /* if (message != null && message != "")
                          firestore.collection('passMessages').add({
                            'sender': myuser.email,
                            'text': message,
                          }); */
                        mesg.clear();
                        mes = "";
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: apBcolor,
                      elevation: 0,
                    ),
                    /******************************************************/
                  ],
                ),
              ))
        ]));
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

}
