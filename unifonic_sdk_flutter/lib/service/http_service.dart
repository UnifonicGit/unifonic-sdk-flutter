import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:unifonic_sdk_flutter/model/uni_device_info.dart';

import '../model/notification_update.dart';

const String _baseUrlStart = "https://push-notification-api.";
const String _baseUrlEnv = "prod.cloud";
const String _baseUrlEnd = ".unifonic.com";
const String _baseUrlProd = "$_baseUrlStart$_baseUrlEnv$_baseUrlEnd";

class HttpService {
  HttpService._();
  static final HttpService _instance = HttpService._();
  factory HttpService() {
    return _instance;
  }
  String _baseUrl = _baseUrlProd;

  Map<String, String> _headers = {"Content-Type": "application/json"};
  PackageInfo? _packageInfo;

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode <= 205) {
        return data;
      } else {
        throw Exception('Failed to make request: ${response.statusCode}');
      }
    } catch (e) {
      String method = response.request?.method ?? "";
      String url = response.request?.url.toString() ?? "";
      throw Exception('Failed to parse response from $method to "$url": $e');
    }
  }

  void setApiKey(String apiKey) {
    String basicAuthHeader = _createBasicAuthHeader(apiKey);
    _headers["Authorization"] = basicAuthHeader;
  }

  registerDevice(UniDeviceInfo deviceInfoRequestDTO) async {
    await _getPackageInfo();
    if (_packageInfo != null) {
      deviceInfoRequestDTO.appVersion = _packageInfo!.version;
      // deviceInfoRequestDTO.buildNumber = _packageInfo!.buildNumber;
      // deviceInfoRequestDTO.packageName = _packageInfo!.packageName;
    }
    final response = await http.post(Uri.parse('$_baseUrl/api/v1/device-info'),
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
      Uri.parse('$_baseUrl/api/v1/device-info'),
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

  void setSdkBaseUrl(String baseUrl) {
    if (!baseUrl.startsWith(_baseUrlStart)) return;
    if (!baseUrl.endsWith(_baseUrlEnd)) return;
    if (kDebugMode) {
      debugPrint("[WARNING] DO NOT USE THIS (setSdkBaseUrl). UNIFONIC INTERNAL USE ONLY.");
      debugPrint("SDK Environment Base URL set to $baseUrl");
      debugPrint("[WARNING] DO NOT USE THIS (setSdkBaseUrl). UNIFONIC INTERNAL USE ONLY.");
    }
    _baseUrl = baseUrl;
  }

  Future<PackageInfo> _getPackageInfo() async {
    if (_packageInfo != null) {
      return _packageInfo!;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _packageInfo = packageInfo;
    return packageInfo;
  }

  String _createBasicAuthHeader(String credentials) {
    final encodedCredentials = base64Encode(utf8.encode(credentials));
    return 'Basic $encodedCredentials';
  }
}
