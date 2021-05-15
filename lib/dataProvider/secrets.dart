import 'dart:io' show Platform;

class Secret {
  static const ANDROID_CLIENT_ID = "307201306561-s5lke2if8g6u9odaj4s75rgde6ljme5n.apps.googleusercontent.com";
  static const IOS_CLIENT_ID = "<enter your iOS client secret>";
  static String getId() => Platform.isAndroid ? Secret.ANDROID_CLIENT_ID : Secret.IOS_CLIENT_ID;
}