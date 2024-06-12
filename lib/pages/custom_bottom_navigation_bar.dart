import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // LatLng import
import 'package:smoke_spot_dev/providers/location_provider.dart'; // LocationProvider import
import 'pages.dart'; // 페이지 import

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  CustomBottomNavigationBar({
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    void _navigateToPage(Widget page, bool isHomePage) {
      if (currentIndex == 2) { // 현재 페이지가 홈 페이지인 경우
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ); // 현재 페이지가 홈페이지인 경우 다른 페이지로의 이동 = push
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        ); // 현재 페이지가 홈페이지가 아닌 경우 다른 페이지로의 이동 = pushReplacement
      }
    }

    return BottomNavigationBar(
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
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) async {
        switch (index) {
          case 0: // 부스 등록 페이지 이동
            if (locationProvider.currentLocation != null) {
              _navigateToPage(
                RegiSmokeSpot(
                  lat: locationProvider.currentLocation!.latitude,
                  lng: locationProvider.currentLocation!.longitude,
                ),
                currentIndex == 2,
              );
            } else {
              if (locationProvider.permissionStatus == PermissionStatus.denied) {
                await locationProvider.requestPermission();
              }
            }
            break;
          case 1: // 저장 페이지로의 이동
            _navigateToPage(BookmarkPage(), currentIndex == 2);
            break;
          case 2: // 홈 페이지로의 이동
            if (currentIndex != 2) { // 다른 페이지에서 홈페이지로 이동할 때 pop
              Navigator.pop(context);
            }
            break;
          case 3: // 커뮤니티 페이지로 이동
            /*_navigateToPage(CommunityPage(), currentIndex == 2);*/
            break;
          case 4: // 마이 페이지로 이동
            _navigateToPage(MyHomePage(), currentIndex == 2);
            break;
        }
      },
    );
  }
}
