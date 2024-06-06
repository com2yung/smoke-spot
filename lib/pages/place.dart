import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  final String name;
  final LatLng location;
  final String address;
  final String? image; // 이미지 경로를 나타내는 선택적 매개변수

  Place({
    required this.name, 
    required this.location, 
    required this.address,
    this.image});
}

// 위치 정보를 문자열로 변환하는 함수
String locationToString(LatLng location) {
  return '${location.latitude}° N, ${location.longitude}° E';
}

// JSON 파일에서 데이터를 읽어와 Set으로 변환하는 함수
Set<Place> parsePlacesFromJson(String jsonString) {
  final jsonData = json.decode(jsonString);
  return jsonData.map<Place>((item) {
    return Place(
      name: item['name'],
      location: LatLng(item['location']['latitude'], item['location']['longitude']),
      address: item['address'],
      image: item['image'],
    );
  }).toSet();
}

 