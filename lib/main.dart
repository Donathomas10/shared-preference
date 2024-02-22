import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageList(),
    );
  }
}

class ImageList extends StatefulWidget {
  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  late Future<List<ImageData>> _imageData;

  @override
  void initState() {
    super.initState();
    _imageData = fetchImageData();
  }

  Future<List<ImageData>> fetchImageData() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));
    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return responseData.map((json) => ImageData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load image data');
    }
  }

  void _navigateToDetailScreen(BuildContext context, ImageData imageData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageDetailScreen(
          title: imageData.title,
          description: imageData.description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Details'),
      ),
      body: FutureBuilder<List<ImageData>>(
        future: _imageData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      _navigateToDetailScreen(context, snapshot.data![index]);
                    },
                    child: Image.network(snapshot.data![index].thumbnailUrl),
                  ),
                  title: Text(snapshot.data![index].title),
                  subtitle: Text('ID: ${snapshot.data![index].id.toString()}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ImageDetailScreen extends StatelessWidget {
  final String title;
  final String description;

  ImageDetailScreen({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageData {
  final int id;
  final String title;
  final String description;
  final String thumbnailUrl;

  ImageData({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: json['id'],
      title: json['title'],
      description: json['url'], 
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}
