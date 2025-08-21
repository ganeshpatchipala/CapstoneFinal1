import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000';

  static Future<List<String>> uploadImage(File imageFile) async {
    var uri = Uri.parse('$baseUrl/detect');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['detections']);
    } else {
      throw Exception('Failed to detect items: ${response.body}');
    }
  }

  //  Return full JSON map 
  static Future<Map<String, dynamic>> generateRecipe(List<String> ingredients) async {
    var uri = Uri.parse('$baseUrl/generate_recipe');
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ingredients': ingredients}),
    );
    print("FULL RESPONSE BODY: ${response.body}");
  print("DECODED JSON: ${json.decode(response.body)}");

  
    if (response.statusCode == 200) {
      return json.decode(response.body); 
    } else {
      throw Exception('Failed to generate recipe: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchDailyTotals() async {
    var uri = Uri.parse('$baseUrl/daily_totals');
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch daily totals: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchDailyMeals() async {
    var uri = Uri.parse('$baseUrl/daily_meals');
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data['meals'] is List) {
        return List<Map<String, dynamic>>.from(data['meals']);
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to fetch daily meals: ${response.body}');
    }
  }
}
