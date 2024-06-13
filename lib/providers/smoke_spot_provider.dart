import 'package:flutter/material.dart';
import 'smoke_spot_model.dart';

class SmokeSpotProvider with ChangeNotifier {
  List<SmokeSpot> _smokeSpots = [];

  List<SmokeSpot> get smokeSpots => _smokeSpots;

  void loadSmokeSpots(String jsonString) {
    _smokeSpots = decodeSmokeSpots(jsonString);
    notifyListeners();
  }
}
