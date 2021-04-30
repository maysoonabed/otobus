import 'package:OtoBus/chat/passchat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  getChatRoomByUserEmails(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  //*********************************//
  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String myUser = myuser.email;
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("lastMessageSendTs", descending: true)
        .where("users", arrayContains: myUser)
        .snapshots();
  }

  //*********************************//

}
