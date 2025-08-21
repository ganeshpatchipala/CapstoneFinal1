import 'dart:typed_data';
import 'package:capstone_flutter/screens/add_items_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/app_bottom_nav.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  Uint8List? _imageBytes;
  List<String> _detectedItems = [];

  Future<void> _pickAndDetectImage() async {
    final result = await FilePicker.platform.pickFiles(withData: true);

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
      });

      final uri = Uri.parse('http://localhost:5000/detect');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _imageBytes!,
        filename: result.files.single.name,
      ));

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final json = jsonDecode(responseBody.body);
        final List<String> detections = List<String>.from(json['detections']);

        setState(() {
          _detectedItems = detections;
        });
      } else {
        print('Error: ${responseBody.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detection failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fridge Scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickAndDetectImage,
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 16),
            if (_imageBytes != null)
              Image.memory(_imageBytes!, height: 200),
            const SizedBox(height: 16),
            if (_detectedItems.isNotEmpty) ...[
  const Text(
    'Detected Items:',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 8),
  Wrap(
    spacing: 8,
    children: _detectedItems
        .map((item) => Chip(label: Text(item)))
        .toList(),
  ),
  const SizedBox(height: 16),
  ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddItemsScreen(
            detectedItems: _detectedItems,
          ),
        ),
      );
    },
    child: const Text('Add More Items'),
  ),
],

          ],
        ),
      ),
    bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}
