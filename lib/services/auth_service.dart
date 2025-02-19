import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:infinite_creation/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String deviceIdKey = 'device_id';
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Future<String> getDeviceId() async {
    // Kiểm tra xem đã có deviceId trong SharedPreferences chưa
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(deviceIdKey);

    // Nếu đã có, trả về luôn
    if (deviceId != null) {
      return deviceId;
    }

    // Nếu chưa có, tạo deviceId mới dựa trên thông tin thiết bị
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      }

      // Nếu không lấy được deviceId từ thiết bị, tạo một ID ngẫu nhiên
      deviceId ??= 'device_${DateTime.now().millisecondsSinceEpoch}';

      // Lưu deviceId vào SharedPreferences
      await prefs.setString(deviceIdKey, deviceId);
      return deviceId;
    } catch (e) {
      // Fallback nếu có lỗi
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(deviceIdKey, deviceId);
      return deviceId;
    }
  }

  // Hàm để authenticate với backend
  Future<void> authenticateGuest() async {
    try {
      final deviceId = await getDeviceId();

      final response = await http.post(
        Uri.parse('${AppConfig.env.apiUrl}/auth/guest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'deviceId': deviceId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Lưu token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      print('Auth error: $e');
      rethrow;
    }
  }

  // Hàm để lấy token cho API calls
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('token'));
    return prefs.getString('token');
  }
}