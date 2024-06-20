/// A Data Transfer Object (DTO) for sending device information to the server.
///
/// This DTO captures relevant details about the device and location,
/// which are then sent to the server for processing. Note that the `fromMap`
/// factory constructor is included to create an instance from a regular
/// `Map<String, dynamic>`.
class UniDeviceInfo {
  /// A unique identifier for the user that is internal to you.
  /// If you don't have a user identifier, or would like to track
  /// anonymous users as well, we automatically use a randomly generated UUID.
  /// We persist that UUID locally on device to ensure that the same user is
  /// identified across app launches.
  String? userIdentifier;

  /// The type of the device (e.g., brand for Android).
  String? deviceType;

  /// The model of the device.
  String? deviceModel;

  /// The operating system of the device. Typically "ANDROID" or "IOS".
  String? deviceOs;

  // /// The latitude of the device's current location.
  // double? latitude;

  // /// The longitude of the device's current location.
  // double? longitude;

  // /// The country where the device is located. E.g., "UAE".
  // String? country;

  /// The language setting of the device. E.g., "US".
  String? deviceLanguage;

  /// The timezone of the device, retrieved from the system.
  String? deviceTimezone;

  /// The FCM/APNs Push token associated with the device.
  String? pushToken;

  /// The version of your application, like semver "1.0.0".
  String? appVersion;

  // /// The package name of your application, like "com.example.app".
  // String? packageName;

  // /// The build number of your application, like like 622.
  // String? buildNumber;

  /// Constructs a new `UniDeviceInfo` with the given details.
  ///
  /// All fields are optional and can be set individually.
  UniDeviceInfo({
    this.userIdentifier,
    this.deviceType,
    this.deviceModel,
    this.deviceOs,
    // this.latitude,
    // this.longitude,
    // this.country,
    this.deviceLanguage,
    this.deviceTimezone,
    this.pushToken,
    this.appVersion,
    // this.packageName,
    // this.buildNumber,
  });

  /// Converts this `UniDeviceInfo` to a Map.
  ///
  /// This method is used to serialize the DTO before sending it to the server.
  Map<String, dynamic> toMap() {
    return {
      'deviceType': deviceType,
      'deviceModel': deviceModel,
      'deviceOs': deviceOs,
      // 'latitude': latitude,
      // 'longitude': longitude,
      // 'country': country,
      'deviceLanguage': deviceLanguage,
      'deviceTimezone': deviceTimezone,
      'pushToken': pushToken,
      'userIdentifier': userIdentifier,
      'appVersion': appVersion,
      // 'packageName': packageName,
      // 'buildNumber': buildNumber,
    };
  }

  /// Creates a new `UniDeviceInfo` from a Map.
  ///
  /// This factory constructor allows creating an instance from a regular
  /// `Map<String, dynamic>`.
  factory UniDeviceInfo.fromMap(Map<String, dynamic> map) {
    return UniDeviceInfo(
      deviceType: map['deviceType'],
      deviceModel: map['deviceModel'],
      deviceOs: map['deviceOs'],
      // latitude: map['latitude'],
      // longitude: map['longitude'],
      // country: map['country'],
      deviceLanguage: map['deviceLanguage'],
      deviceTimezone: map['deviceTimezone'],
      pushToken: map['pushToken'],
      userIdentifier: map['userIdentifier'],
      appVersion: map['appVersion'],
      // packageName: map['packageName'],
      // buildNumber: map['buildNumber'],
    );
  }
}
