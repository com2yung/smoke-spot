import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:smoke_spot_dev/pages/custom_bottom_navigation_bar.dart';
import 'login_page.dart';
import 'pages.dart';
import 'place.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:smoke_spot_dev/providers/providers.dart';

class HomePage extends StatefulWidget {
  final Bookmark? bookmark;
  const HomePage({Key? key, this.bookmark}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<Place> _nearbyPlaces = {}; // 드래그 시트 - 주변 장소 데이터
  late ScrollController _scrollController; // 드래그 시트 컨트롤러
  double _sheetSize = 0.1; // 드래그 시트의 크기
  late Bookmark bookmarkManager;
  int _currentindex = 2; // 현재 인덱스를 홈으로 설정

  Set<Marker> _markers = {}; // 지도에 표시할 마커들

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    loadNearbyPlaces();
    bookmarkManager = Bookmark();
  }

  // json 파일을 읽어오는 함수
  void loadNearbyPlaces() async {
    String jsonString = await rootBundle.loadString('assets/data/places.json'); // 파일 읽기
    setState(() {
      _nearbyPlaces = parsePlacesFromJson(jsonString);
    });
  }

  void loadSmokeSpots(Set<SmokeSpot> smokeSpots) {
    // 스모크 스팟을 마커로 변환하여 _markers에 추가합니다.
    setState(() {
      _markers.addAll(smokeSpots.map((spot) => Marker(
        markerId: MarkerId(spot.address),
        position: LatLng(spot.latitude, spot.longitude),
        infoWindow: InfoWindow(
          title: spot.address,
          snippet: '평균 점수: ${spot.averageScore} 리뷰 개수: ${spot.reviewCount}',
        ),
      )));
    });
  }

  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void animateCameraTo(LatLng position) {
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: position,
          zoom: 16,
        ),
      ));
    }
  }

  void _openSearchPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    );
    if (result != null && result.containsKey('latitude') && result.containsKey('longitude')) {
      animateCameraTo(LatLng(result['latitude'], result['longitude']));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final currentLocation = locationProvider.currentLocation;
    final userProvider = Provider.of<UserProvider>(context);
    final smokeSpots = Provider.of<SmokeSpotProvider>(context).smokeSpots;

    // 스모크 스팟 마커를 로드합니다.
    loadSmokeSpots(smokeSpots.toSet());

    // 현재 위치 마커를 추가합니다.
    if (currentLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId("MyLocation"),
        position: currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }

    return Scaffold(
      // AppBar 세션 - 메뉴 아이콘, 검색창, 검색 아이콘
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        // 검색창 -> search_page로 이동
        title: Row(
          children: [
            Expanded(
              child: TextField(
                readOnly: true,
                onTap: _openSearchPage,
                decoration: InputDecoration(
                  hintText: '원하는 장소를 입력하세요.',
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
            // 검색 아이콘
            IconButton(
              icon: Icon(Icons.search),
              onPressed: _openSearchPage,
            ),
          ],
        ),
      ),
      // GoogleMap 세션
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (currentLocation == null)
            const Center(
              child: Text("Loading..."),
            )
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLocation,
                zoom: 16.0,
              ),
              markers: _markers,
              onMapCreated: _onMapCreated,
              zoomGesturesEnabled: true,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                ),
              },
            ),
          Positioned(
            right: 20,
            bottom: 150,
            child: FloatingActionButton(
              onPressed: () {
                if (mapController != null && currentLocation != null) {
                  mapController!.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                      bearing: 0,
                      target: currentLocation,
                      zoom: 16,
                    ),
                  ));
                } else {
                  // Handle the case where mapController or _currentP is null
                  if (locationProvider.permissionStatus == PermissionStatus.denied) {
                    locationProvider.requestPermission();
                  }
                }
              },
              shape: const CircleBorder(),
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location),
            ),
          ),
          // DraggableScrollableSheet 세션 - 아래에서 위로 드래그 하면 나오는 거
          DraggableScrollableSheet(
            initialChildSize: _sheetSize,
            minChildSize: _sheetSize,
            maxChildSize: 0.6,
            builder: (BuildContext context, ScrollController? scrollController) {
              if (scrollController != null) {
                _scrollController = scrollController;
              }
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _nearbyPlaces.length + 2,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return SizedBox(height: 100);
                        } else if (index == 1) {
                          return SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                '추천 흡연구역',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          );
                        }
                        final place = _nearbyPlaces.elementAt(index - 2);
                        return ListTile(
                          title: Text(place.name),
                          subtitle: Text(place.address),
                          leading: place.image != null
                              ? Image.asset(
                            place.image!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image); // 이미지 파일 로드 실패시 이미지 아이콘
                            },
                          )
                              : null,
                          trailing: IconButton(
                            icon: Icon(
                              Icons.star,
                              color: bookmarkManager.isBookmarked(place) ? Colors.yellow : Colors.grey,
                            ), // 북마크 여부에 따라 색상 변경
                            onPressed: () {
                              setState(() {
                                bookmarkManager.toggleBookmark(place);
                              }); // 저장 아이콘 동작
                            },
                          ),
                          onTap: () {
                            // 장소를 탭했을 때
                          },
                        );
                      },
                    ),
                  ),
                  // 화살표 아이콘을 드래그하면 DraggableScrollableSheet 펼쳐짐
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      _scrollController.animateTo(
                        _scrollController.position.pixels - details.primaryDelta!,
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      // NavigationBar 세션
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentindex,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final user = userProvider.currentUser;
                  if (user != null) {
                    return Column(
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // 사용자 정보가 없을 경우
                    return Column(
                      children: [
                        Text(
                          '로그인이 필요합니다.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                          child: Text('로그인'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
