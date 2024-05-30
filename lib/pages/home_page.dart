import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smoke_spot/pages/my_home_page.dart';
import 'package:geolocator/geolocator.dart'; 
import 'place.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);
  Position? _currentPosition; // 드래그 시트 - 현재 위치 
  List<Place> _nearbyPlaces = []; // 드래그 시트 - 주변 장소 리스트 
  late ScrollController _scrollController; // 드래그 시트 컨트롤러
  double _sheetSize = 0.1; // 드래그 시트의 크기 
  bool _isSearchBarFocused = false; // 검색창 포커스 여부 - 검색창 누르면 드래그 시트 뜨지 않게 하기 위함

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 활성화되지 않은 경우
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한이 거부된 경우
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부된 경우
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _fetchNearbyPlaces();
    });
  }

  void _fetchNearbyPlaces() {
    // 예시로 임의의 장소 목록을 추가함
    // 나중에 API를 사용해서 데이터를 가져와야 함
    final List<Place> places = [
      Place('Place 1', LatLng(45.521563, -122.677433)),
      Place('Place 2', LatLng(45.531563, -122.687433)),
      Place('Place 3', LatLng(45.511563, -122.667433)),
    ];

    if (_currentPosition != null) {
      places.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
          _currentPosition!.latitude, _currentPosition!.longitude,
          a.location.latitude, a.location.longitude,
        );
        double distanceB = Geolocator.distanceBetween(
          _currentPosition!.latitude, _currentPosition!.longitude,
          b.location.latitude, b.location.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      setState(() {
        _nearbyPlaces = places;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar 세션 - 메뉴 아이콘, 검색창, 검색 아이콘
      appBar: AppBar(
        backgroundColor: Colors.white,
        // 메뉴 아이콘 -> Drawer
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
        // 검색창 
        title: Row(
          children: [
            Expanded(
              child: TextField(
                // 드래그 시트 숨기기
                onTap: () {
                  setState( () {
                    _isSearchBarFocused = true;
                    _sheetSize = 0; 
                  });
                },
                // 드래그 시트 다시 등장시키기
                onEditingComplete: () {
                  setState(() {
                    _isSearchBarFocused = false;
                    _sheetSize = 0.1;
                  });
                },
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
              onPressed: () {
                // 검색 아이콘 동작 설정
              },
            ),
          ],
        ),
      ),
      // GoogleMap 세션
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
          ),
      // DraggableScrollableSheet 세션 - 아래에서 위로 드래그 하면 나오는 거
          if (! _isSearchBarFocused) // 검색창에 포커스 안 되어있을 때 나오게 구현함
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
                      itemCount: _nearbyPlaces.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(_nearbyPlaces[index].name),
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
      bottomNavigationBar: Stack(
        children: [
          BottomNavigationBar(
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: '부스 등록',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: '저장',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.forum),
                label: '커뮤니티',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '마이페이지',
              ),
            ],
            selectedItemColor: Colors.black26,
            unselectedItemColor: Colors.black,
            currentIndex: 2,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              if (index == 4) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                ); 
              }
            },
          ),
        ],
      ),
      // Drawer 세션
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          alignment: Alignment.center, // 세로 중앙 정렬
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 가로 중앙 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
            children: [
              CircleAvatar(
                // 프로필 아이콘
                backgroundColor: Colors.black,
                child: Icon(Icons.account_circle, color: Colors.white,), // Flutter에서 제공하는 프로필 아이콘
              ),
              SizedBox(height: 10), // 아이콘과 이름 사이 여백 추가
              Text(
                "사용자 이름", // 사용자의 이름
                style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                ),
              ),
              SizedBox(height: 20), // 프로필 아이콘과 메뉴 항목 사이 여백 추가
              ListTile(
                title: Text('메뉴 항목 1'),
                onTap: () {
                // 메뉴 항목 1을 클릭했을 때
                },
              ),
              ListTile(
                title: Text('메뉴 항목 2'),
                onTap: () {
                // 메뉴 항목 2를 클릭했을 때
                },
              ),
              // 추가적인 메뉴 항목들을 여기에 추가
            ],
          ),
        ),
      ),
    );
  }
}