// import 'dart:async';
// import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:geocoding/geocoding.dart';
// // import 'package:get_ip_address/get_ip_address.dart';
// import 'package:unifonic_sdk_flutter/model/uni_device_info.dart';

// import 'package:unifonic_sdk_flutter/model/notification_update.dart';
// import 'package:unifonic_sdk_flutter/model/uni_feature.dart';
// import 'package:unifonic_sdk_flutter/model/uni_push_config.dart';
// import 'package:unifonic_sdk_flutter/service/http_service.dart';

// import 'package:http/http.dart' as http;

// export 'unifonic_push.dart';

// enum DeviceType {
//   IOS,
//   ANDROID,
// }

// class UnifonicPush implements UniFeature<UniPushConfig> {
//   static final UnifonicPush _instance = UnifonicPush._internal();
//   static UnifonicPush get instance => _instance;
//   UnifonicPush._internal();
//   factory UnifonicPush() {
//     return _instance;
//   }

//   late UniPushConfig _config;

//   static Map<dynamic, dynamic> _payload = {};

//   static bool _isFlutterLocalNotificationsInitialized = false;

//   final streamCtlr = StreamController<String>.broadcast();
//   final titleCtlr = StreamController<String>.broadcast();
//   final bodyCtlr = StreamController<String>.broadcast();

//   static final HttpService _httpService = HttpService();

//   // static var _buildContext;
//   late String _userIdentifier;
//   late String _accountId;
//   late bool _enableLocation;
//   late String _apiKey;

//   @override
//   Future<void> init(UniPushConfig config) async {
//     _userIdentifier = config.userIdentifier;
//     _enableLocation = config.enableLocation;
//     _apiKey = config.apiKey;
//     _config = config;

//     var platform = await _currentPlatform;
//     debugPrint(platform.toString());

//     _httpService.setHeader({
//       'Content-Type': 'application/json',
//       'Authorization': 'Basic $_apiKey'
//     });

//     if (!kIsWeb) {
//       _setupFlutterNotifications();
//     }

//     // handle when app in active state
//     _forgroundNotification();

//     // handle when app running in background state
//     _backgroundNotification();

//     // handle when app completely closed by the user
//     _terminateNotification();
//   }

//   @override
//   UniPushConfig get config => _config;

//   Future<void> _loadEnvVariables() async {
//     // You can use 'await' here
//     await dotenv.load(fileName: 'config/.env');
//   }

//   @pragma('vm:entry-point')
//   Future<void> _firebaseMessagingBackgroundHandler(
//       RemoteMessage message) async {
//     await _setupFlutterNotifications();
//   }

//   Future<Map<String, dynamic>> _registerDevice(
//       UniDeviceInfo deviceInfoRequestDTO) async {
//     var localToken = await _firebaseMessaging.getToken();
//     if (localToken != null) {
//       deviceInfoRequestDTO.firebaseToken = localToken;
//     }

//     return await _httpService.registerDevice(deviceInfoRequestDTO);
//   }

//   _getCountryFromLatAndLng(var latitude, var longitude) async {
//     try {
//       List<Placemark> placemarks =
//           await placemarkFromCoordinates(latitude, longitude);
//       Placemark place = placemarks[0];
//       return place.country;
//     } catch (e) {
//       debugPrint(e as String?);
//     }
//   }

//   void registerDevice(UniDeviceInfo deviceInfoRequestDTO) async {
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     UniDeviceInfo deviceInfoRequestDTO = UniDeviceInfo();

//     if (Platform.isAndroid) {
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//       deviceInfoRequestDTO.deviceType = androidInfo.brand;
//       deviceInfoRequestDTO.deviceModel = androidInfo.model;
//       deviceInfoRequestDTO.deviceOs = "ANDROID";
//     } else {
//       IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//       deviceInfoRequestDTO.deviceType = "iPhone";
//       deviceInfoRequestDTO.deviceModel = iosInfo.model;
//       deviceInfoRequestDTO.deviceOs = "IOS";

//       if (_enableLocation == true) {
//         LocationPermission permission = await Geolocator.requestPermission();

//         if (permission == LocationPermission.denied) {
//           // Handle denied permission
//           debugPrint('Location permission denied for IOS device');
//           return;
//         }
//       }
//     }

//     Position? position = await Geolocator.getLastKnownPosition();
//     if (position != null) {
//       deviceInfoRequestDTO.latitude = position.latitude;
//       deviceInfoRequestDTO.longitude = position.longitude;
//       deviceInfoRequestDTO.country = "UAE"; //@TODO update
//     }

//     deviceInfoRequestDTO.deviceLanguage = "US";
//     deviceInfoRequestDTO.deviceTimezone = DateTime.now().timeZoneName;

//     var ipAddress = IpAddress(type: RequestType.json);
//     var data = await ipAddress.getIpAddress();
//     deviceInfoRequestDTO.lastIpAddress = data['ip'];

//     _registerDevice(deviceInfoRequestDTO);
//     _showEvent();
//   }

//   // for android
//   static _onSelectNotification() async {
//     NotificationUpdateModel notificationUpdateModel = NotificationUpdateModel(
//         notificationId: _payload['notificationId'],
//         notificationStatus: "CLICKED",
//         userIdentifier: _userIdentifier);

//     _httpService.updateStatus(notificationUpdateModel, _accountId);
//   }

//   static Future<FirebaseOptions> get _currentPlatform async {
//     if (kIsWeb) {
//       throw UnsupportedError(
//         'DefaultFirebaseOptions have not been configured for web - '
//         'you can reconfigure this by running the FlutterFire CLI again.',
//       );
//     }

//     switch (defaultTargetPlatform) {
//       case TargetPlatform.android:
//         return _mapFirebaseOption(await _httpService.firebaseConfig("ANDROID"));
//       case TargetPlatform.iOS:
//         return _mapFirebaseOption(await _httpService.firebaseConfig("IOS"));
//       case TargetPlatform.macOS:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions have not been configured for macos - '
//           'you can reconfigure this by running the FlutterFire CLI again.',
//         );
//       case TargetPlatform.windows:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions have not been configured for windows - '
//           'you can reconfigure this by running the FlutterFire CLI again.',
//         );
//       case TargetPlatform.linux:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions have not been configured for linux - '
//           'you can reconfigure this by running the FlutterFire CLI again.',
//         );
//       default:
//         throw UnsupportedError(
//           'DefaultFirebaseOptions are not supported for this platform.',
//         );
//     }
//   }

//   static FirebaseOptions _mapFirebaseOption(Map<String, dynamic> data) {
//     return FirebaseOptions(
//       apiKey: data['apiKey'],
//       appId: data['appId'],
//       messagingSenderId: data['messagingSenderId'],
//       projectId: data['projectId'],
//       storageBucket: data['storageBucket'],
//     );
//   }
// }
