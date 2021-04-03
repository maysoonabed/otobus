import 'package:OtoBus/dataProvider/address.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier {
  Adress pickUpAdd;
  Adress destinationAddress;
  void updatePickAddress(Adress pickUp) {
    pickUpAdd = pickUp;
    notifyListeners();
  }

  void updateDestAddress(Adress destination) {
    destinationAddress = destination;
    notifyListeners();
  }
}
