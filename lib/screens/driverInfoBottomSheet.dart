import 'package:OtoBus/main.dart';
import 'package:flutter/material.dart';
import 'package:OtoBus/configMaps.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:OtoBus/dataProvider/Spacecraft.dart';
import 'package:OtoBus/screens/Customlistview.dart';

class DriverInfoBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(25.0),
              topRight: const Radius.circular(25.0))),
      height: MediaQuery.of(context).size.height * 0.83,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              height: 6,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'بيانات السائق',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            SizedBox(
              height: 6,
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: IconButton(
                      icon: Icon(Icons.phone),
                      onPressed: () async {
                        launch(('tel://${theDriver.phone}'));
                      }),
                ),
                Column(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      theDriver.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontFamily: 'Lemonada'),
                    ),
                    Text(
                      getFstWord(theDriver.begN) +
                          ' - ' +
                          getFstWord(theDriver.endN),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Lemonada',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الاسم',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, fontFamily: 'Lemonada'),
                    ),
                    Text(
                      'الخط',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, fontFamily: 'Lemonada'),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: theDriver.pic != null
                      ? AssetImage('lib/Images/${theDriver.pic}')
                      : AssetImage('lib/Images/Defultprof.jpg'),
                )
              ],
            ),
            Divider(),
            SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        LinearPercentIndicator(
                          width: 200.0,
                          lineHeight: 6.0,
                          percent: s5 / rateCount,
                          backgroundColor: bacolor,
                          progressColor: apcolor,
                        ),
                        Text(
                          '5',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 10, fontFamily: 'Lemonada'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        LinearPercentIndicator(
                          width: 200.0,
                          lineHeight: 6.0,
                          percent: s4 / rateCount,
                          backgroundColor: bacolor,
                          progressColor: apcolor,
                        ),
                        Text(
                          '4',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 10, fontFamily: 'Lemonada'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        LinearPercentIndicator(
                          width: 200.0,
                          lineHeight: 6.0,
                          percent: s3 / rateCount,
                          backgroundColor: bacolor,
                          progressColor: apcolor,
                        ),
                        Text(
                          '3',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 10, fontFamily: 'Lemonada'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        LinearPercentIndicator(
                          width: 200.0,
                          lineHeight: 6.0,
                          percent: s2 / rateCount,
                          backgroundColor: bacolor,
                          progressColor: apcolor,
                        ),
                        Text(
                          '2',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 10, fontFamily: 'Lemonada'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        LinearPercentIndicator(
                          width: 200.0,
                          lineHeight: 6.0,
                          percent: s1 / rateCount,
                          backgroundColor: bacolor,
                          progressColor: apcolor,
                        ),
                        Text(
                          '1',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 10, fontFamily: 'Lemonada'),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      theDriver.rate.toStringAsFixed(1),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 40, fontFamily: 'Lemonada'),
                    ),
                    SmoothStarRating(
                      isReadOnly: true,
                      color: apcolor,
                      borderColor: apcolor,
                      rating: theDriver.rate,
                      size: 15,
                      allowHalfRating: false,
                      starCount: 5,
                      spacing: 2.0,
                      onRated: (value) {},
                    ),
                    Text(
                      rateCount.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, fontFamily: 'Lemonada'),
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
            Container(
              //FutureBuilder is a widget that builds itself based on the latest snapshot
              // of interaction with a Future.
              child: FutureBuilder<List<Spacecraft>>(
                future: downloadJSON(),
                //we pass a BuildContext and an AsyncSnapshot object which is an
                //Immutable representation of the most recent interaction with
                //an asynchronous computation.
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Spacecraft> spacecrafts = snapshot.data;

                    return CustomListView(spacecrafts);
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  //return  a circular progress indicator.
                  return CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getFstWord(String input) {
    int i = input.indexOf(',');
    String word = input.substring(0, i);
    return word;
  }
}
