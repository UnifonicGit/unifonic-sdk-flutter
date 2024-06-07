import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:unifonic_sdk_flutter/model/uni_device_info.dart';

import '../model/notification_update.dart';

class HttpService {
  // final String _baseUrl = "https://testing-push.requestcatcher.com";
  final String _baseUrl =
      "https://push-notification-api.prod.cloud.unifonic.com";

  Map<String, String> _headers = {};
  PackageInfo? _packageInfo;

  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode <= 205) {
      return data;
    } else {
      throw Exception('Failed to make POST request: ${response.statusCode}');
    }
  }

  registerDevice(UniDeviceInfo deviceInfoRequestDTO) async {
    debugPrint('+++ url base: $_baseUrl +++');
    await _getPackageInfo();
    if (_packageInfo != null) {
      deviceInfoRequestDTO.appVersion = _packageInfo!.version;
      deviceInfoRequestDTO.buildNumber = _packageInfo!.buildNumber;
      deviceInfoRequestDTO.packageName = _packageInfo!.packageName;
    }
    final response = await http.post(Uri.parse('$_baseUrl/api/v1/device-info/'),
        body: json.encode(deviceInfoRequestDTO.toMap()), headers: _headers);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> unregisterDevice(
      String id, String userId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/v1/device-info/$id/$userId'),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateLocation(
      Map<String, dynamic> deviceInfoRequestDTO) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/v1/device-info/'),
      body: json.encode(deviceInfoRequestDTO),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  updateStatus(NotificationUpdateModel notificationUpdateModel) async {
    // @TODO get accountId from env variables
    final response = await http.patch(
      Uri.parse("$_baseUrl/api/v1/notification/update-status"),
      body: jsonEncode(notificationUpdateModel),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> firebaseConfig(String deviceType) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/firebase/$deviceType'),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  void setHeader(Map<String, String> headers) {
    _headers = headers;
  }

  Future<PackageInfo> _getPackageInfo() async {
    if (_packageInfo != null) {
      return _packageInfo!;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _packageInfo = packageInfo;
    return packageInfo;
  }
}
