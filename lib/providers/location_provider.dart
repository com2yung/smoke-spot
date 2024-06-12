import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier {
  final Location _location = Location();
  LatLng? _currentLocation; // 사용자의 현재 위치 저장
  LatLng? get currentLocation => _currentLocation;
  PermissionStatus _permissionGranted = PermissionStatus.denied; // 위치 권한 상태
  PermissionStatus get permissionStatus => _permissionGranted; // 위치 권한 상태 getter

  LocationProvider() {
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _location.onLocationChanged.listen((LocationData locationData) {
      _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      notifyListeners();
    });
  }

  Future<void> requestPermission() async {
    _permissionGranted = await _location.requestPermission();
    notifyListeners();
  }
}
