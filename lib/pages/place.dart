// 드래그 시트에 보일 사용자와 인접한 흡연장소 목록 리스트 클래스
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  final String name;
  final LatLng location;

  Place(this.name, this.location);
}
