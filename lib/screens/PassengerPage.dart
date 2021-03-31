import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
String name, email, password, errormsg, phone;
bool error = false;

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
class PassengerPage extends StatefulWidget {
  @override
  _PassengerPageState createState() => _PassengerPageState();
}

class _PassengerPageState extends State<PassengerPage> {
  profileConnection() async {
    String apiurl =
        "http://192.168.1.107:8089/otobus/phpfiles/profile.php"; //10.0.0.13//192.168.1.107:8089

    var response = await http.post(apiurl, body: {
      'email': email,
    });
    //print(response.body);
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body); //json.decode
      if (jsondata["error"] == 1) {
        setState(() {
          error = true;
          errormsg = jsondata["message"];
        });
      } else {
        setState(() {
          email = email;
          name = jsondata["name"];
          phone = jsondata["phonenum"];
          //jsondata["image"];
        });
      }
    } else {
      setState(() {
        error = true;
        errormsg = "هناك مشكلة في الاتصال بالسيرفر";
      });
    }
  }

  void initState() {
    name = "";
    phone = "";
    email = "";
    errormsg = "";
    error = false;
    super.initState();
  }

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  Widget build(BuildContext context) {
    profileConnection();
    final Size size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false, //لإخفاء شريط depug
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: ba1color,
        //#######################################
        appBar: AppBar(
          actions: <Widget>[
            new Container(),
          ],
          title: Center(
            child: Text(
              "OtoBüs",
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'Pacifico',
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: apcolor,
        ),
        //#######################################
        endDrawer: Drawer(
          child: Column(
            children: <Widget>[
              Stack(
                overflow: Overflow.visible,
                alignment: Alignment.center,
                children: <Widget>[
                  Image(
                    image: NetworkImage(
                        'https://wallpapercave.com/wp/wp2779617.jpg'),
                  ),
                  Positioned(
                      bottom: -50.0,
                      child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white,
                          backgroundImage: (NetworkImage(
                              'https://st4.depositphotos.com/1000507/24488/v/600/depositphotos_244889634-stock-illustration-user-profile-picture-isolate-background.jpg')))),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              ListTile(
                  title: Center(
                      child: Text(name,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Lemonada",
                          )))),
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                  future: FlutterSession().get('token'),
                  builder: (context, snapshot) {
                    email = snapshot.hasData ? snapshot.data : '';
                    return Text(snapshot.hasData ? snapshot.data : 'Loading...',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Lemonada",
                        ));
                  }),
              SizedBox(
                height: 20,
              ),
              ListTile(
                title: Center(
                    child: Text(phone,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Lemonada",
                        ))),
              ),
              SizedBox(
                height: 100,
              ),
              MaterialButton(
                color: apBcolor,
                height: 20,
                minWidth: 150.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onPressed: () {
                  FlutterSession().set('token', '');
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyApp()));
                },
                child: Text('Logout',
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Lemonada",
                        color: Colors.white)),
              ),
            ],
          ),
        ),
        //#######################################
        body: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                // color: apcolor,
                width: size.width,
                height: 80,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(size.width, 80),
                      painter: CusPaint(),
                    ),
                    Center(
                      heightFactor: 0.6,
                      child: FloatingActionButton(
                        onPressed: () {
                          // _searchDialog();
                        },
                        backgroundColor: mypink,
                        //Color(0xFF0e6655),  //Colors.black,
                        child: Icon(Icons.search),
                        elevation: 0.1,
                      ),
                    ),
                    Container(
                        width: size.width,
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly, //Center Row contents vertically,

                          children: [
                            Material(
                              color: Color(0xFF1ccdaa),
                              shape: CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: IconButton(
                                  icon: Icon(Icons.home),
                                  color: mypink,
                                  // iconBack, //mypink, //apcolor,
                                  onPressed: () {}),
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: IconButton(
                                  icon: Icon(Icons.message_outlined),
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyApp()));
                                  }),
                            ),
                            Container(
                              width: size.width * 0.20,
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: IconButton(
                                  icon: Icon(Icons.notifications_outlined),
                                  color: Colors.white,
                                  onPressed: () {}),
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: IconButton(
                                  icon: Icon(Icons.person_outline_rounded),
                                  color: Colors.white,
                                  onPressed: () {
                                    _scaffoldKey.currentState.openEndDrawer();

                                    //Navigator.of(context).pop();  //For close the drawer
                                  }),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
class CusPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = apcolor
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 20);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(10), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDElegate) {
    return false;
  }
}
