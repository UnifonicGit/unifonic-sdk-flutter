import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifonic_sdk_flutter/model/notification_update.dart';
import 'package:unifonic_sdk_flutter/model/uni_device_info.dart';
import 'package:unifonic_sdk_flutter/service/http_service.dart';
import 'package:unifonic_sdk_flutter_platform_interface/unifonic_sdk_flutter_platform_interface.dart';
import 'package:uuid/uuid.dart';

typedef MessageHandler = void Function(Map<String, dynamic> message);

class UniPushVM {
  // Private constructor for singleton pattern
  UniPushVM._internal();

  // Singleton instance
  static final UniPushVM _instance = UniPushVM._internal();

  // Factory constructor to return the singleton instance
  factory UniPushVM() {
    return _instance;
  }

  static final HttpService _httpService = HttpService();
  late final SharedPreferences? _sharedPreferences;

  // StreamControllers
  final StreamController<Map<String?, Object?>>
      _onNotificationTapStreamController = StreamController.broadcast();
  final StreamController<String> _onNewTokenStreamController =
      StreamController.broadcast();
  final StreamController<RemoteMessage> _onBackgroundMessageStreamController =
      StreamController.broadcast();
  final StreamController<RemoteMessage> _onMessageStreamController =
      StreamController.broadcast();

  bool configured = false;
  String? token = "";
  dynamic _userIdentifier;

  final ValueNotifier<Map<String, dynamic>> userInfo =
      ValueNotifier<Map<String, dynamic>>({});

  /// Get the forwarded [Stream] of notification tap events.
  /// Stream will emit a [Map] of notification data when a notification is tapped.
  Stream<Map<String?, Object?>> get onNotificationTapStream =>
      _onNotificationTapStreamController.stream;

  /// Get the forwarded [Stream] of new token events.
  /// Stream will emit a [String] of the new token when a new token is generated.
  /// This stream is also used to emit the initial token when the [init] method is called.
  /// This is useful for getting the token when the app is already running.
  Stream<String> get onNewTokenStream => _onNewTokenStreamController.stream;

  /// Get the forwarded [Stream] of background message events.
  /// Stream will emit a [RemoteMessage] when a background message is received.
  Stream<RemoteMessage> get onBackgroundMessageStream =>
      _onBackgroundMessageStreamController.stream;

  /// Get the forwarded [Stream] of message events.
  /// Stream will emit a [RemoteMessage] when a message is received.
  Stream<RemoteMessage> get onMessageStream =>
      _onMessageStreamController.stream;

  /// Initialize the push service.
  /// This method should be called after the [Unifonic().init] method.
  /// This method will start listening to push events and forward them to the appropriate streams.
  void init() async {
    UnifonicPush.instance.addOnBackgroundMessage((message) {
      _onBackgroundMessageStreamController.add(message);
    });
    UnifonicPush.instance.addOnMessage((message) {
      _onMessageStreamController.add(message);
    });
    UnifonicPush.instance.onNewToken.listen(_addNewToken);
    UnifonicPush.instance.onNotificationTap.listen(_addNotificationTap);
    _addNewToken(await UnifonicPush.instance.token);
    configured = true;
  }

  /// Request permission to receive push notifications.
  /// This method will show the permission dialog to the user.
  Future<bool> requestPermission() async {
    return await UnifonicPush.instance.requestPermission();
  }

  /// Check if notifications are enabled.
  Future<bool> areNotificationsEnabled() async {
    return await UnifonicPush.instance.areNotificationsEnabled();
  }

  /// Get the notification settings.
  /// This method will return a [Future] of [UNNotificationSettings].
  Future<UNNotificationSettings> getNotificationSettings() async {
    return await UnifonicPush.instance.getNotificationSettings();
  }

  /// Register the device with the provided [UniDeviceInfo].
  /// This method will send the device information to the server to register the device.
  Future<Map<String, dynamic>> registerDevice(
      UniDeviceInfo uniDeviceInfo) async {
    if (token != null) {
      uniDeviceInfo.pushToken = token;
    }
    if (_userIdentifier != null) {
      uniDeviceInfo.userIdentifier = _userIdentifier;
    }

    return await _httpService.registerDevice(uniDeviceInfo);
  }

  Future<void> setUserIdentifier(dynamic userIdentifier) async {
    userIdentifier ??= await _getUserIdentifier();
    _userIdentifier = userIdentifier;
  }

  Future<String> _getUserIdentifier() async {
    String userIdentifier = const Uuid().v4();
    try {
      _sharedPreferences ??= await SharedPreferences.getInstance();
      await _sharedPreferences!.setString('userIdentifier', userIdentifier);
    } catch (e) {
      debugPrint("Failed to save user identifier");
    }
    return userIdentifier;
  }

  void _addNotificationTap(Map<String?, Object?> data) {
    _onNotificationTapStreamController.add(data);
    if (Platform.isAndroid) {
      _handleAndroidNotificationTap(data);
    } else if (Platform.isIOS) {
      _handleIOSNotificationTap(data);
    }
  }

  void _handleAndroidNotificationTap(Map<String?, Object?> data) {
    if (data.containsKey("data")) {
      Map<String?, Object?>? notificationData =
          data["data"] as Map<String?, Object?>?;
      if (notificationData != null) {
        if (notificationData.containsKey("notificationId")) {
          String? notificationId =
              notificationData["notificationId"] as String?;
          if (notificationId != null) {
            _updateNotificationStatus(notificationId);
          }
        }
      }
    }
  }

  void _handleIOSNotificationTap(Map<String?, Object?> data) {
    if (data.containsKey("notificationId")) {
      String? notificationId = data["notificationId"] as String?;
      if (notificationId != null) {
        _updateNotificationStatus(notificationId);
      }
    }
  }

  void _updateNotificationStatus(String notificationId) {
    if (_userIdentifier == null) {
      debugPrint(
          "[_updateNotificationStatus]: No user identifier found - did you call [Unifonic().registerDevice(...)]?");
      return;
    }

    NotificationUpdateModel notificationUpdateModel = NotificationUpdateModel(
        notificationId: notificationId,
        notificationStatus: "CLICKED",
        userIdentifier: _userIdentifier);

    _httpService.updateStatus(notificationUpdateModel);
  }

  void _addNewToken(String? newToken) {
    if (newToken != null) {
      token = newToken;
      _onNewTokenStreamController.add(newToken);
    }
  }

  // Dispose method to close the StreamControllers and ValueNotifiers
  void dispose() {
    _onNotificationTapStreamController.close();
    _onNewTokenStreamController.close();
    _onBackgroundMessageStreamController.close();
    _onMessageStreamController.close();
    userInfo.dispose();
  }
}
