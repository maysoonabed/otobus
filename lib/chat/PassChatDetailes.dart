import 'package:OtoBus/chat/passchat.dart';
import 'package:OtoBus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'PasschatMessageModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//******************************************************/
var mesg = TextEditingController();
var message; //FierbaseFirestore
//******************************************************/

class PassChatDetailes extends StatefulWidget {
  @override
  _PassChatDetailesState createState() => _PassChatDetailesState();
}

//******************************************************/

class _PassChatDetailesState extends State<PassChatDetailes> {
  @override
  Widget build(BuildContext context) {
    //print(myuser.email);print(myuser.name);\

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
                    backgroundImage: AssetImage(
                        'phpfiles/cardlic/image_picker-1364311807.jpg'),
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
                          "Kriss Benwat",
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
          Container(
            padding: EdgeInsets.only(bottom: 65),
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('passMessages').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(//width: 0.0, height: 0.0,
                      );
                }
                final msgs = snapshot.data.docs.reversed;
                List<PassChatMessage> messages = [];
                for (var message in msgs) {
                  final messText = message.data()['text'];
                  final messSender = message.data()['sender'];
                  final msgwidget = PassChatMessage(
                      messageContent: messText, useremil: messSender);
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
                      onTap: () {},
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
                        controller: mesg,
                        onChanged: (value) {
                          message = value;
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
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        if (message != null && message != "")
                          firestore.collection('passMessages').add({
                            'sender': myuser.email,
                            'text': message,
                          });
                        mesg.clear();
                        message = "";
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
}
