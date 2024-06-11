library unifonic_sdk_flutter;

import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unifonic_sdk_flutter/model/uni_active_capabilities.dart';
import 'package:unifonic_sdk_flutter/model/uni_device_info.dart';
import 'package:unifonic_sdk_flutter/model/uni_feature.dart';
import 'package:unifonic_sdk_flutter/model/uni_push_config.dart';
import 'package:unifonic_sdk_flutter/service/http_service.dart';
import 'package:unifonic_sdk_flutter/service/lifecycle_observer_service.dart';
import 'package:unifonic_sdk_flutter/view_model/location_view_model.dart';
import 'package:unifonic_sdk_flutter/view_model/push_view_model.dart';

export 'package:unifonic_sdk_flutter_platform_interface/unifonic_sdk_flutter_platform_interface.dart'
    show RemoteMessage;
export 'package:unifonic_sdk_flutter/model/uni_push_config.dart' show UniPush;

class Unifonic {
  Unifonic._();
  static final Unifonic _instance = Unifonic._();
  factory Unifonic() => _instance;
  static late UniPushVM _pushVM;
  static late UniLocationVM _locationVM;
  static final HttpService _httpService = HttpService();
  static final Capabilities _capabilities = Capabilities();

  /// Get the [UniPushVM] instance.
  /// This instance can be used to listen to push events.
  static UniPushVM get push => _pushVM;

  /// Get the [UniPushVM] instance.
  /// This instance can be used to listen to push events.
  /// This is an alias for [push].
  static UniPushVM get p => _pushVM;

  /// Get the [UniLocationVM] instance.
  /// This instance can be used to listen to location events.
  static UniLocationVM get location => _locationVM;

  /// Get the [UniLocationVM] instance.
  /// This instance can be used to listen to location events.
  /// This is an alias for [location].
  static UniLocationVM get l => _locationVM;

  /// Get the [Unifonic] instance.
  /// This instance can be used to initialize the SDK and get the [UniPushVM] and [UniLocationVM] instances.
  /// This is an alias for [Unifonic].
  static Unifonic get i => _instance;

  /// Initialize the Unifonic SDK with the provided [features].
  /// This method should be called before any other method.
  /// The [features] parameter is a list of [UniFeature] objects.
  /// Each [UniFeature] object should contain a [config] object that contains the configuration for the feature.
  /// The [config] object should contain an [apiKey] field that is required for the SDK to work.
  /// If an [apiKey] is found in only one of the [config] objects, it will use that as the API key for all features.
  Future<void> init(List<dynamic> features) async {
    LifecycleObserver();
    String apiKey = "";
    for (UniFeature feature in features) {
      if (feature.config.containsKey("apiKey")) {
        apiKey = feature.config.get("apiKey");
      }
      _setupLocationTracking(feature.config);
      _setupLifecycleTracking(feature.config);
    }

    if (apiKey.isEmpty) {
      throw Exception("API Key is required");
    } else if (!apiKey.contains(":")) {
      throw Exception(
      """
        Invalid API Key. The API Key should be formatted like "API_KEY:SECRET_KEY". 
        An API Key generated on the Unifonic Console consists of an "API Key" and a "Secret Key". 
        API Keys can be created in the Unifonic Console: https://cloud.unifonic.com/api-keys
      """
      );
    }

    _httpService.setHeader(
        {'Content-Type': 'application/json', 'Authorization': 'Basic $apiKey'});

    for (UniFeature feature in features) {
      if (feature.config is UniPushConfig) {
        _setupPushNotifications(feature.config);
      }
    }
  }

  /// Register the device with the provided [UniDeviceInfo].
  /// This method will send the device information to the server to register the device.
  /// This needs to be done before it's possible to send any Push Notification to the device.
  /// The [UniDeviceInfo] object should contain the user identifier.
  /// If the user identifier is not provided, a random user identifier will be generated and stored in the device.
  static Future<bool> registerDevice({String? userIdentifier}) async {
    if (_pushVM.configured == false) {
      throw Exception("Push notifications are not enabled");
    }

    await _pushVM.setUserIdentifier(userIdentifier!);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    UniDeviceInfo deviceInfoRequestDTO = UniDeviceInfo();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceInfoRequestDTO.deviceType = androidInfo.brand;
      deviceInfoRequestDTO.deviceModel = androidInfo.model;
      deviceInfoRequestDTO.deviceOs = "ANDROID";
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceInfoRequestDTO.deviceType = "iPhone";
      deviceInfoRequestDTO.deviceModel = iosInfo.model;
      deviceInfoRequestDTO.deviceOs = "IOS";

      if (_capabilities.location == true) {
        LatLngLike? position = await _locationVM.getCurrentPosition();
        if (position != null) {
          deviceInfoRequestDTO.latitude = position.latitude;
          deviceInfoRequestDTO.longitude = position.longitude;
          // deviceInfoRequestDTO.country = "UAE"; // should come from Geocoder
        }
      }
    }

    deviceInfoRequestDTO.deviceLanguage = Platform.localeName;
    deviceInfoRequestDTO.deviceTimezone = DateTime.now().timeZoneName;

    var res = await _pushVM.registerDevice(deviceInfoRequestDTO);
    return res.isNotEmpty;
  }

  /// Dispose the Unifonic SDK.
  /// This method should be called when the SDK is no longer needed.
  /// This method will dispose the [UniPushVM] and [UniLocationVM] instances.
  /// This method will also remove the [LifecycleObserver] instance.
  static void dispose() {
    LifecycleObserver().dispose();
    _locationVM.dispose();
  }

  void _setupPushNotifications(UniFeatureConfig config) {
    _pushVM = UniPushVM();
    _addTokenEventListener();
  }

  void _addTokenEventListener() {
    _pushVM.onNewTokenStream.listen(
      (token) {
        debugPrint('New token SDK: $token');
      },
    );
  }

  void _setupLocationTracking(UniFeatureConfig config) {
    if (config.containsKey("enableLocation")) {
      if (config.get("enableLocation") == true) {
        _capabilities.location = true;
        _locationVM = UniLocationVM();
        _locationVM.configureService(true);

        _locationVM.positionStream.listen(
          (position) {
            debugPrint('New position: $position');
          },
          onError: (error) {
            debugPrint('Error: $error');
          },
        );

        _locationVM.startLocationUpdates();
      }
    }
  }

  void _setupLifecycleTracking(UniFeatureConfig config) {
    if (config.containsKey("lifecycleTracking")) {
      if (config.get("lifecycleTracking") == true) {
        _capabilities.lifecycleTracking = true;
        LifecycleObserver().enabledAudienceTracking = true;
      }
    }
  }
}
