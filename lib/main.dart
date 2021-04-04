import 'package:OtoBus/dataProvider/appData.dart';
import 'package:OtoBus/screens/PassengerPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session/flutter_session.dart';
import 'screens/DriverMap.dart';
import 'screens/LoginPage.dart';
import 'screens/SignupPage.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/PassMap.dart';
import 'screens/fire.dart';

Color apcolor = const Color(0xFF1ABC9C);
Color apBcolor = const Color(0xFF00796B);
Color iconBack = const Color(0xFF0e6655);

Color bacolor = const Color(0xFFBDBDBD);
Color ba1color = const Color(0xFFf2f1e3);

Color mypink = const Color(0xFFbc1a3a);
Color myOrange = const Color(0xFFbc4b1a);
Color myPink = const Color(0xFFbc1a8b);
Color myblue = const Color(0xFF1a8bbc);
Color mygreen = const Color(0xFF1abc4b);

const List<Color> myGradients1 = [
  Color(0xFF02100d),
  Color(0xFF05211b),
  Color(0xFF07322a),
  Color(0xFF094338),
  Color(0xFF0c5546),
  Color(0xFF0e6655),
  Color(0xFF107763),
  Color(0xFF138871),
  Color(0xFF159a7f),
  Color(0xFF18ab8e),
  Color(0xFF1abc9c), //this is my color
  Color(0xFF1ccdaa),
  Color(0xFF1fdeb9),
];
const List<Color> myGradients2 = [
  Color(0xFF1fdeb9),
  Color(0xFF1ccdaa),
  Color(0xFF1abc9c), //this is my color
  Color(0xFF18ab8e),
  Color(0xFF159a7f),
  Color(0xFF138871),
  Color(0xFF107763),
  Color(0xFF0e6655),
  Color(0xFF0c5546),
  Color(0xFF094338),
  Color(0xFF07322a),
  Color(0xFF05211b),
  Color(0xFF02100d),
];
const List<Color> myGradients3 = [
  Color(0xFF1abc74),
  Color(0xFF1abc81),
  Color(0xFF1abc8f),
  Color(0xFF1abc9c),
  Color(0xFF1abcaa),
  Color(0xFF1abcb7),
  Color(0xFF1ab4bc),
];
const List<Color> myGradients4 = [
  Color(0xFF64726f),
  Color(0xFF5c7a74),
  Color(0xFF548279),
  Color(0xFF4b8b7e),
  Color(0xFF439383),
  Color(0xFF3b9b88),
  Color(0xFF33a38d),
  Color(0xFF2aac92),
  Color(0xFF22b497),
  Color(0xFF1abc9c), //this is my color
  Color(0xFF12c4a1),
  Color(0xFF0acca6),
  Color(0xFF01d5ab),
];
bool spin = true;
void main() {
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  //***********Session*************
  WidgetsFlutterBinding.ensureInitialized();
  dynamic token = FlutterSession().get('token');
  //*******************************
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => AppData(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false, //لإخفاء شريط depug
      home:MyApp(),// token != null ? PassengerPage() : MyApp(), //MyApp(), //
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..color = Color(0xFF159a7f)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;
    // paint_0.shader = ui.Gradient.linear(
    //    Offset(0, 0), Offset(size.width, 0), myGradients1, [0.00, 1.00]);
    Path path_0 = Path();
    path_0.moveTo(0, 0);
    path_0.cubicTo(
        size.width * 0.7471875,
        size.height * -0.0015000,
        size.width * 0.6921875,
        size.height * 0.0005000,
        size.width * 0.9412500,
        0);
    path_0.cubicTo(
        size.width * 0.8303125,
        size.height * 0.3325000,
        size.width * 0.2484375,
        size.height * 0.0115000,
        0,
        size.height * 0.4860000);
    path_0.cubicTo(size.width * -0.0006250, size.height * 0.3440000,
        size.width * -0.0018750, size.height * 0.3720000, 0, 0);
    path_0.close();
    canvas.drawShadow(path_0, Color(0xFF07322a), 10, true);
    canvas.drawPath(path_0, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class BottomCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(50.0, 50.0),
        child: Material(
          color: apcolor,
          shape: CircleBorder(),
        ));
  }
}

class _MyAppState extends State<MyApp> {
  Widget build(BuildContext context) {
    return Material(
        // debugShowCheckedModeBanner: false, //لإخفاء شريط depug
        type: MaterialType.transparency,
        child: new Container(
            alignment: Alignment.bottomCenter,
            width: double.infinity,
            child: Container(
                color: Colors.white, //bacolor,
                child: CustomPaint(
                    size: Size(
                        100,
                        (200 * 1.5)
                            .toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                    painter: RPSCustomPainter(),
                    child: ListView(
                      children: [
                        BottomCircle(),
                        //*********************************
                        SizedBox(
                          height: 250.0,
                        ),
                        //*********************************
                        Center(
                          child: Text(
                            "OtoBüs",
                            style: TextStyle(
                              fontSize: 60,
                              fontFamily: 'Pacifico',
                              color: Color(
                                  0xFF07322a), // Color(0xFF05211b) //Color(0xFF02100d),
                            ),
                          ),
                        ),
                        //*********************************
                        /*Center(
                          child: Text(
                            //"App saves your time and effort in booking buses",
                            "   وفرّ وقتك و قلقك بشأن المواصلات بحجز الباص مسبقاً",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'ArefRuqaaR', //'Pacifico',
                              color: Color(0xFF07322a), //Color(0xFF64726f),
                            ),
                          ),
                        ),*/
                        //*********************************

                        Center(
                          child: Builder(builder: (BuildContext mContext) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Stack(
                                alignment: Alignment(1.0, 0.0),
                                children: <Widget>[
                                  new GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginPage()));
                                    },
                                    child: new Container(
                                      alignment: Alignment.center,
                                      width:
                                          MediaQuery.of(mContext).size.width /
                                              1.7,
                                      decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0)),
                                        gradient: LinearGradient(
                                            colors: myGradients1,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight),
                                        shadows: [
                                          BoxShadow(
                                            color: Color(0xFF07322a)
                                                .withOpacity(0.5),
                                            //Colors.grey,
                                            spreadRadius: 3,
                                            blurRadius: 7,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Text("  تسجيل الدخول", //"Sign up"
                                          style: TextStyle(
                                              color: Colors.white, //bacolor,
                                              fontSize: 15, //18
                                              fontFamily:
                                                  'Lemonada', // 'ArefRuqaaR', //Pacifico',
                                              fontWeight: FontWeight.w500)),
                                      padding:
                                          EdgeInsets.only(top: 16, bottom: 16),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                        ),
                        //*********************************
                        Center(
                          child: Builder(builder: (BuildContext mContext) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Stack(
                                alignment: Alignment(1.0, 0.0),
                                children: <Widget>[
                                  new GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignupPage()),
                                        );
                                        //setState(() {});
                                      },
                                      child: new Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(mContext).size.width /
                                                1.7,
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0)),
                                          gradient: LinearGradient(
                                              colors: myGradients2,
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight),
                                          shadows: [
                                            BoxShadow(
                                              color: Color(0xFF07322a)
                                                  .withOpacity(0.5),
                                              //Colors.grey,
                                              spreadRadius: 3,
                                              blurRadius: 7,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                            "إنشاء حساب", //"Log in""إنشاء حساب   "
                                            style: TextStyle(
                                                color: Colors.white, //bacolor,
                                                fontSize: 15,
                                                fontFamily:
                                                    'Lemonada', //'ArefRuqaaR',25 //Pacifico',18
                                                fontWeight: FontWeight.w500)),
                                        padding: EdgeInsets.only(
                                            top: 16, bottom: 16),
                                      )),
                                ],
                              ),
                            );
                          }),
                        ),
                        //*********************************

                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ElevatedButton(
                              child: Text('driver map'),
                              style: ElevatedButton.styleFrom(
                                primary: apBcolor,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DriverMap()));
                              },
                            ),
                          ),
                        ),

                        //*********************************

                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ElevatedButton(
                              child: Text('Passenger'),
                              style: ElevatedButton.styleFrom(
                                primary: apBcolor,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PassengerPage()));
                              },
                            ),
                          ),
                        ),

                        //*********************************
                      ],
                    )))));
  }

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }
}
