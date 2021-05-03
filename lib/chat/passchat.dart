import 'package:OtoBus/chat/Curruser.dart';
import 'package:OtoBus/screens/PassMap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import 'PassConversationList .dart';
import 'globalFunctions.dart';

//******************************************************/
Curruser myuser;
final FirebaseAuth auth = FirebaseAuth.instance;
final firestore = Firestore.instance;
String em, nm;
String roomid, romid = "";
String anotherUserEmail, anotherUserName = "";
Stream chatRoomStream;
String mynm, myem;
String secemail = " ";
String lastMsg = "";
//******************************************************/
getCurrUser() {
  return auth.currentUser;
}

//******************************************************/
class PassChat extends StatefulWidget {
  PassChat(this.myemail, this.myname);
  final String myname;
  final String myemail;
  @override
  _PassChatState createState() => _PassChatState();
}

class _PassChatState extends State<PassChat> {
  @override
  Widget build(BuildContext context) {
    em = widget.myemail;
    nm = widget.myname;
    setState(() {
      myuser = Curruser(email: em, name: nm);
      mynm = globalFunctions().getUsernamefromemail(myuser.email);
      myem = myuser.email;
      chatRoomStream = globalFunctions().getChatRooms();
    });
    //###########################################################
    globalFunctions().registerNotification();
    //###########################################################
    return MaterialApp(
        debugShowCheckedModeBanner: false, //لإخفاء شريط depug
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: apcolor,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  //Navigator.push(context,MaterialPageRoute(builder: (context) => PassMap()));
                  //dispose();
                  Navigator.pop(
                      context); //مشان لما ترجع يا للباس ماب أو الباس مسنجر وحدة منهم
                }),
            title: Text(
              "OtoBüs",
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'Pacifico',
                color: Colors.white,
              ),
            ),
          ),
          //*****************************************************************/
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                StreamBuilder(
                    stream: chatRoomStream,
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.only(top: 16),
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                DocumentSnapshot ds = snapshot.data.docs[index];
                                romid = ds.id;
                                secemail = romid.replaceAll("$myem", "");
                                secemail = secemail.replaceAll("*", "");
                                lastMsg = ds["lastMessage"];
                                var lastread = ds["lastmsgread"];
                                var lastsender = ds["lastMessageSendBy"];
                                if (!lastread) {
                                  if (lastsender == myuser.name)
                                    lastread = true;
                                }
                                final Timestamp timestamp =
                                    ds["lastMessageSendTs"] as Timestamp;
                                final DateTime dateTime = timestamp.toDate();
                                final dateString =
                                    DateFormat('k:mm:ss').format(dateTime);
                                return PassConversationList(
                                  secUseremail: secemail,
                                  messageText: lastMsg,
                                  time: dateString,
                                  isMessageRead: lastread,
                                  roomID: romid,
                                );
                              })
                          : Center(child: CircularProgressIndicator());
                    }),
              ],
            ),
          ),
        ));
  }
}
