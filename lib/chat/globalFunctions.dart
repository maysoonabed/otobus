import 'package:OtoBus/chat/passchat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class globalFunctions {
  //*********************************//
  getUsernamefromemail(String email) {
    String nUsName = email.replaceAll("@", "");
    nUsName = nUsName.replaceAll(".", "");
    nUsName = nUsName.replaceAll("com", "");
    nUsName = nUsName.replaceAll("gmail", "");
    nUsName = nUsName.replaceAll("hotmail", "");
    nUsName = nUsName.replaceAll("mail", "");
    nUsName = nUsName.replaceAll("yahoo", "");
    nUsName = nUsName.replaceAll("outlook", "");
    return nUsName;
  }

  //*********************************//
  createchatroom(String chatRoomId, Map chatRoomMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomMap);
    }
  }

  //*********************************//
  getUserByEmail(String userEm) {
    //Future<Stream<QuerySnapshot>>
    return FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: userEm)
        .snapshots();
  }

//*********************************//
  getRoomId(String myemail, String anusem) {
    String rRID = getChatRoomByUserEmails(myemail, anusem);
    return rRID;
  }

//*********************************//
  getChatRoomByUserEmails(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\*\*\*$a";
    } else {
      return "$a\*\*\*$b";
    }
  }

  //*********************************//
  getChatRooms() {
    // Future <Stream<QuerySnapshot>> async
    String myUser = myuser.email;
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("lastMessageSendTs", descending: true)
        .where("users", arrayContains: myUser)
        .snapshots();
  }

  //*********************************//
  creatChatRoomInfo(String myusrEmail, String secusrEmail) {
    //String roomID = getRoomId(getUsernamefromemail(myusrEmail), getUsernamefromemail(secusrEmail));
    String roomID = getRoomId(myusrEmail, secusrEmail);
    Map<String, dynamic> chatRoomInfoMap = {
      "users": [myusrEmail, secusrEmail], // [myuser.email, anotherUserEmail],
    };
    createchatroom(roomID, chatRoomInfoMap);
    return (roomID);
    //return roomID;
  }

  //*********************************//
  getuserinfo(String ema) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: ema)
        .get();
  }

  //*********************************//
  updateread(String rRID, String myusr) {
    final DocumentReference documentReference =
        FirebaseFirestore.instance.collection('chatrooms').doc(rRID);
    documentReference.update(<String, dynamic>{'lastmsgread': true});
    // var user = userDocument["lastMessageSendBy"];
  }
  //*********************************//
}
