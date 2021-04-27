import 'package:OtoBus/chat/Curruser.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'PassChatUsers.dart';
import 'PassConversationList .dart';

Curruser myuser;

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
    String em = widget.myemail;
    String nm = widget.myname;
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
            title: Padding(
              padding: EdgeInsets.only(top: 20, left: 0, right: 0, bottom: 20),
              child: TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: "... بحث",
                  hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontFamily: 'Lemonada',
                      fontSize: 15),
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey)),
                ),
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
