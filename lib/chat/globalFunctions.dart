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
  Future<Stream<QuerySnapshot>> getUserByEmail(String userEm) {
    FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: userEm)
        .snapshots();
  }

//*********************************//
  getUserEmail(String email) async {
    Stream usersStream = await getUserByEmail(email);
    return usersStream;
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
  void registerNotification() {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print("onMessage : $message");
    }, onLaunch: (Map<String, dynamic> message) async {
      print("onLunch : $message");
    }, onResume: (Map<String, dynamic> message) async {
      print("onResume : $message");
    });
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    /* firebaseMessaging.getToken().then((token) {
      print(token);
    }); 
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance
          .collection('users')
          .document(currentUserId)
          .updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    }); */
  }

  //*********************************//
  Future<int> numUnredMsgs() async {
    var count = 0;
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .where("users", arrayContains: myuser.email)
        .get()
        .then((val) {
      for (int i = 0; i < val.docs.length; i++) {
        if ((val.docs[i]['lastmsgread'] == false) &&
            (val.docs[i]['lastMessageSendBy'] != myuser.name)) {
          count++;
        }
      }
      //print(count);
      return count;
    });
  }
}
