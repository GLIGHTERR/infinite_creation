import 'dart:io';

import 'env.dart';

class DevEnv implements Env {
  // late String host;
  //
  // DevEnv._(this.host);
  //
  // static Future<DevEnv> create() async {
  //   String ipv4 = await getLocalIPv4();
  //   String host = 'http://$ipv4:5000';
  //   return DevEnv._(host); // Khởi tạo instance với host
  // }
  //
  // static Future<String> getLocalIPv4() async {
  //   try{
  //     for (var interface in await NetworkInterface.list()) {
  //       for (var address in interface.addresses) {
  //         if (address.type == InternetAddressType.IPv4 &&
  //             !address.isLoopback &&
  //             address.address.startsWith('192.168.')) {
  //           return address.address; // Trả về IP trong mạng LAN
  //         }
  //       }
  //     }
  //   } catch (exception) {
  //     print('Exception Occur: $exception');
  //   }
  //
  //   return '0.0.0.0';
  // }

  @override
  // String get apiUrl => host;
  String get apiUrl => 'http://192.168.1.13:5000';

  @override
  bool get enableLogging => true;
}