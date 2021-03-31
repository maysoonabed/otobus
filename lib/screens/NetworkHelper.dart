import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper{
  NetworkHelper({this.startLng,this.startLat,this.endLng,this.endLat});

final String url ='https://api.openrouteservice.org/v2/directions/';
  final String apiKey = '5b3ce3597851110001cf6248ad184afec335461598654d8f8969690c';
  final String pathParam = 'driving-car';// Change it if you want
  final double startLng;
  final double startLat;
  final double endLng;
  final double endLat;

  Future getData() async{
     http.Response response = await http.get('$url$pathParam?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat');
    

    if(response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);

    }
    else{
      print(response.statusCode);
    }
  }
}
