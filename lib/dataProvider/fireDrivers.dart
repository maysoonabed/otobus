import 'package:OtoBus/dataProvider/nearDriver.dart';

class FireDrivers {
  static List<NearDrivers> nDrivers = [];
  static void removeDriver(String key) {
    nDrivers.removeAt(nDrivers.indexWhere((element) => element.key == key));
  }

  static void updateDriver(NearDrivers driver) {
    int indx = nDrivers.indexWhere((element) => element.key == driver.key);
    nDrivers[indx].long = driver.long;
    nDrivers[indx].lat = driver.lat;
  }
}
