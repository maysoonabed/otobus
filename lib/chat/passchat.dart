import 'package:OtoBus/chat/Curruser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'PassChatUsers.dart';
import 'PassConversationList .dart';

//******************************************************/
Curruser myuser;
final FirebaseAuth auth = FirebaseAuth.instance;
final firestore = Firestore.instance;
String em, nm;

//******************************************************/
class PassChat extends StatefulWidget {
  PassChat(this.myemail, this.myname);
  final String myname;
  final String myemail;
  @override
  _PassChatState createState() => _PassChatState();
}

class _PassChatState extends State<PassChat> {
  List<PassChatUsers> chatUsers = [
    PassChatUsers(
        name: "Jane Russel",
        messageText: "Awesome Setup",
        imageURL: "phpfiles/cardlic/image_picker1196946746.jpg",
        time: "Now"),
  ];
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    em = widget.myemail;
    nm = widget.myname;
    myuser = Curruser(email: em, name: nm);
    //print(myuser.email);print(myuser.name);
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
                ListView.builder(
                  itemCount: chatUsers.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 16),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return PassConversationList(
                      //user: myuser,
                      name: chatUsers[index].name,
                      messageText: chatUsers[index].messageText,
                      imageUrl: chatUsers[index].imageURL,
                      time: chatUsers[index].time,
                      isMessageRead: (index == 0 || index == 3) ? true : false,
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
