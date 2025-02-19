import 'package:infinite_creation/config/app_config.dart';
import 'package:infinite_creation/models/item.dart';
import 'package:infinite_creation/services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> getHeaders() async {
    final token = await _authService.getToken();

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Item>> getListItem() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${AppConfig.env.apiUrl}/api/items'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Item.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load progress');
      }
    } catch (e) {
      print('Error fetching progress: $e');
      rethrow;
    }
  }

  Future<Item> combineItems(String item1, String item2) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.env.apiUrl}/api/items/combine'),
        headers: headers,
        body: jsonEncode({
          'item_1': item1,
          'item_2': item2,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true) {
          Map<String, dynamic> item = responseBody['data'];
          return Item.fromJson(item);
        }

        throw Exception('Failed to combine');
      } else {
        throw Exception('Failed to combine');
      }
    } catch (e) {
      print('Error combining: $e');
      rethrow;
    }
  }
}