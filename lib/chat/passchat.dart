import 'package:OtoBus/chat/Curruser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'PassConversationList .dart';
import 'getFrronPhp.dart';
import 'globalFunctions.dart';

//******************************************************/
Curruser myuser;
final FirebaseAuth auth = FirebaseAuth.instance;
final firestore = Firestore.instance;
String em, nm;
String roomid = "";
String anotherUserEmail, anotherUserName = "";
Stream chatRoomStream;
String mynm = globalFunctions().getUsernamefromemail(myuser.email);
String roomName = "";
//******************************************************/
getCurrUser() {
  return auth.currentUser;
}

//******************************************************/
Widget chatRoomList() {
  return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 16),
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  print(snapshot.data.docs.length);
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  String romid = ds.id;
                  roomName = romid.replaceAll("$mynm", "");
                  roomName = roomName.replaceAll("_", "");
                  print(roomName);

                  String eml;
                  //String imgpath = getFromPhp().getUserImagePath(eml);
                  return PassConversationList(
                    secUsername: roomName,
                    messageText: "Hello", //chatUsers[index].messageText,
                    imageUrl:
                        "phpfiles/cardlic/image_picker-840323637.jpg", // imgpath,
                    time: "2:51:41 PM", //chatUsers[index].time,
                    secUseremail: anotherUserEmail,
                    isMessageRead: (index == 0 || index == 3) ? true : false,
                  );
                })
            : Center(child: CircularProgressIndicator());
      });
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
  getRooms() async {
    chatRoomStream = await globalFunctions().getChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    em = widget.myemail;
    nm = widget.myname;
    setState(() {
      myuser = Curruser(email: em, name: nm);
      anotherUserEmail = "samah.tobasi@gmail.com";
      anotherUserName = "Samah Tobasi";
      roomid = globalFunctions().getChatRoomByUserEmails(
          globalFunctions().getUsernamefromemail(myuser.email),
          globalFunctions()
              .getUsernamefromemail(anotherUserEmail)); //هون إيميل الشخص الثاني
      //print(roomid);
    }); //getRooms();
    getRooms();
    //###########################################################
    Map<String, dynamic> chatRoomInfoMap = {
      "users": [myuser.email, anotherUserEmail], //هون إيميل الشخص الثاني
    };
    //globalFunctions().createchatroom(roomid, chatRoomInfoMap);
    //###########################################################
    return MaterialApp(
        debugShowCheckedModeBanner: false, //لإخفاء شريط depug
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: apcolor,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
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
                chatRoomList(),
              ],
            ),
          ),
        ));
  }
}
