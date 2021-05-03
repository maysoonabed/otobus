import 'package:OtoBus/dataProvider/Spacecraft.dart';
import 'package:OtoBus/dataProvider/currDriverInfo.dart';
import 'package:OtoBus/dataProvider/tripInfo.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'screens/CurrUserInfo.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter/material.dart';

const tokenkey =
    'pk.eyJ1IjoibW15eHQiLCJhIjoiY2ttbDMwZzJuMTcxdDJwazVoYjFmN29vZiJ9.zXZhziLKRg0-JEtO4KPG1w';
String mapKey = "AIzaSyCU1zRGJNhBvwMisg1zsPg3oOW6Yymq2Sk";
String googlekey = "AIzaSyDpIlaxbh4WTp4_Ecnz4lupswaRqyNcTv4";
CurrUserInfo thisUser = new CurrUserInfo();
CurrDriverInfo thisDriver = new CurrDriverInfo();
CurrDriverInfo theDriver = CurrDriverInfo();
DatabaseReference tripReq;
DatabaseReference ridRef;
DatabaseReference nnum;
DatabaseReference whereTo;
int s1, s2, s3, s4, s5;
int rateCount;

List<String> accReq = [];

int numCont;
int driverNum;
var currUser;
StreamSubscription<Position> posStream;
StreamSubscription<Position> ridePosStream;
String serverToken =
    'key=AAAAR4af78E:APA91bHxmXSF2dTgOFlJbTjs_20A0lkyTKPYOFz_HOOzGIqTk7lDZidJC5SfcUNQQp6RsyxRabVwHyJ1EItvuTuwZ1xdA7SztFkes8Icu3PN2_Qu4RGisXuU74m0kmMnJs1CaMkXOIYO';

AudioCache cache = AudioCache();
AudioPlayer notifPlayer = AudioPlayer();

LatLng driverF = LatLng(32.2934, 35.3458);
LatLng driverT = LatLng(32.2227, 35.2621);
TripInfo tripInfo = TripInfo();
int dReqTimeout = 10;
String statusRide = '';
String arrivalStatus = ' الباص على الطريق ';
double driversDetailes = 0;
