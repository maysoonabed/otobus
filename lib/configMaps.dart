import 'package:OtoBus/dataProvider/tripInfo.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'screens/CurrUserInfo.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

const tokenkey =
    'pk.eyJ1IjoibW15eHQiLCJhIjoiY2ttbDMwZzJuMTcxdDJwazVoYjFmN29vZiJ9.zXZhziLKRg0-JEtO4KPG1w';
String mapKey = "AIzaSyCU1zRGJNhBvwMisg1zsPg3oOW6Yymq2Sk";
String googlekey = "AIzaSyDpIlaxbh4WTp4_Ecnz4lupswaRqyNcTv4";
CurrUserInfo thisUser = new CurrUserInfo();
DatabaseReference tripReq;
var currUser;
StreamSubscription<Position> posStream;
final notifPlayer = AssetsAudioPlayer();

LatLng driverF = LatLng(32.2934, 35.3458);
LatLng driverT = LatLng(32.2227, 35.2621);
TripInfo tripInfo = TripInfo();
