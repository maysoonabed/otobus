import 'package:flutter/material.dart';
import '../main.dart';
import 'PassChatUsers.dart';
import 'PassConversationList .dart';

class PassChat extends StatefulWidget {
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
    PassChatUsers(
        name: "Glady's Murphy",
        messageText: "That's Great",
        imageURL: "phpfiles/cardlic/image_picker-28516318.jpg",
        time: "Yesterday"),
    PassChatUsers(
        name: "Jorge Henry",
        messageText: "Hey where are you?",
        imageURL: "phpfiles/cardlic/image_picker-1364311807.jpg",
        time: "31 Mar"),
    PassChatUsers(
        name: "Philip Fox",
        messageText: "Busy! Call me in 20 mins",
        imageURL: "phpfiles/cardlic/image_picker1196946746.jpg",
        time: "28 Mar"),
    PassChatUsers(
        name: "Debra Hawkins",
        messageText: "Thankyou, It's awesome",
        imageURL: "phpfiles/cardlic/image_picker-1364311807.jpg",
        time: "23 Mar"),
    PassChatUsers(
        name: "Jacob Pena",
        messageText: "will update you in evening",
        imageURL: "phpfiles/cardlic/image_picker1196946746.jpg",
        time: "17 Mar"),
    PassChatUsers(
        name: "Andrey Jones",
        messageText: "Can you please share the file?",
        imageURL: "phpfiles/cardlic/image_picker-1364311807.jpg",
        time: "24 Feb"),
    PassChatUsers(
        name: "John Wick",
        messageText: "How are you?",
        imageURL: "phpfiles/cardlic/image_picker-28516318.jpg",
        time: "18 Feb"),
  ];
  @override
  Widget build(BuildContext context) {
    //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
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
