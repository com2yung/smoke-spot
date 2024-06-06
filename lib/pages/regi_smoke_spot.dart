import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegiSmokeSpot extends StatefulWidget {
  final double lat;
  final double lng;

  /// Default Constructor
  const RegiSmokeSpot({super.key, required this.lat, required this.lng});

  @override
  State<RegiSmokeSpot> createState() => _RegiSmokeSpotState();
}

class _RegiSmokeSpotState extends State<RegiSmokeSpot> {
  late CameraController controller;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      controller = CameraController(_cameras[0], ResolutionPreset.max);
      await controller.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<XFile?> _takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }

    // Ensure that the camera is not taking another picture
    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      // Take the picture and return the file
      return await controller.takePicture();
    } catch (e) {
      // Handle any errors here
      print(e);
      return null;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('부스 등록'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (!controller.value.isInitialized) {
                return Container();
              }
              return Stack(
                children: [
                  CameraPreview(controller),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FloatingActionButton(
                        onPressed: () async {
                          XFile? picture = await _takePicture();
                          if (picture != null && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DisplayPictureScreen(
                                  imagePath: picture.path,
                                  lat: widget.lat,
                                  lng: widget.lng,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Icon(Icons.camera),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}


/// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final double lat;
  final double lng;

  const DisplayPictureScreen({super.key, required this.imagePath, required this.lat, required this.lng});

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final TextEditingController _detailsController = TextEditingController();
  final List<String> _tags = ['#부스', '#밀폐', '#통풍'];
  final List<bool> _selectedTags = [false, false, false];
  String _address = '주소';

  @override
  void initState() {
    super.initState();
    _getAddressFromCoordinates(widget.lat, widget.lng);
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    const apiKey = 'AIzaSyB185R2-8CsRjYS4vet-4k64H81TFnn9a0';  // 여기에 당신의 API 키를 입력하세요.
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey&language=ko';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        setState(() {
          _address = data['results'][0]['formatted_address'];
        });
      } else {
        throw Exception('Failed to get address: ${data['status']}');
      }
    } else {
      throw Exception('Failed to connect to the API: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(title: const Text('부스 등록')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.file(File(widget.imagePath), width: 200, height: 200),  // 사진을 더 크게 표시합니다.
                const SizedBox(width: 10),
                Expanded(child: Text(_address)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('세부 정보', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(
                hintText: '세부 정보를 입력하세요',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            const Text('태그 선택', style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 10.0,
              children: List<Widget>.generate(_tags.length, (int index) {
                return ChoiceChip(
                  label: Text(_tags[index]),
                  selected: _selectedTags[index],
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedTags[index] = selected;
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle upload action
                  },
                  child: const Text('업로드'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('취소'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
