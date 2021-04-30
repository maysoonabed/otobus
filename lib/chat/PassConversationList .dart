import 'package:OtoBus/chat/PassChatDetailes.dart';
import 'package:flutter/material.dart';

class PassConversationList extends StatefulWidget {
  //Curruser user;//@required this.user,
  String secUsername;
  String messageText;
  String imageUrl;
  String time;
  bool isMessageRead;
  String secUseremail;
  PassConversationList({
    @required this.secUsername,
    @required this.messageText,
    @required this.imageUrl,
    @required this.time,
    @required this.isMessageRead,
    @required this.secUseremail,
  });
  @override
  _PassConversationListState createState() => _PassConversationListState();
}

class _PassConversationListState extends State<PassConversationList> {
  @override
  Widget build(BuildContext context) {
    //print(myuser.email); print(myuser.name);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PassChatDetailes(
              username: widget.secUsername,
              imageURL: widget.imageUrl,
              secUser: widget.secUseremail);
        }));
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: AssetImage(widget.imageUrl),
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
                            widget.secUsername,
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.messageText,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: widget.isMessageRead
                                    ? FontWeight.bold
                                    : FontWeight.normal),
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
                  fontSize: 12,
                  fontWeight: widget.isMessageRead
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
