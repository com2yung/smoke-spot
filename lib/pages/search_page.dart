import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];

  void _onSearchChanged(String query) async {
    if (query.isNotEmpty) {
      const apiKey = 'AIzaSyB185R2-8CsRjYS4vet-4k64H81TFnn9a0'; // 여기에 Google Places API 키를 입력하세요
      final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&language=ko';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          if (mounted) {
            setState(() {
              _suggestions = (data['predictions'] as List).map((prediction) => {
                'description': prediction['description'],
                'place_id': prediction['place_id']
              }).toList();
            });
          }
        } else {
          print('Error: ${data['status']}');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } else {
      if (mounted) {
        setState(() {
          _suggestions = [];
        });
      }
    }
  }

  Future<void> _getPlaceDetails(String query) async {
    const apiKey = 'AIzaSyB185R2-8CsRjYS4vet-4k64H81TFnn9a0'; // 여기에 Google Places API 키를 입력하세요
    final url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$query&inputtype=textquery&fields=geometry&key=$apiKey&language=ko';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['candidates'].isNotEmpty) {
        final location = data['candidates'][0]['geometry']['location'];
        if (mounted) {
          Navigator.of(context).pop({
            'latitude': location['lat'],
            'longitude': location['lng']
          });
        }
      } else {
        print('Error: ${data['status']}');
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _onSearchChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: '원하는 장소를 입력하세요.',
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.black),
          onSubmitted: (query) {
            _getPlaceDetails(query);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _getPlaceDetails(_controller.text);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_suggestions[index]['description']),
            onTap: () {
              // 아이템 선택 시 장소 상세 정보 가져오기
              _getPlaceDetails(_suggestions[index]['description']);
            },
          );
        },
      ),
    );
  }
}
