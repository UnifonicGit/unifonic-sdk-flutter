# Unifonic Flutter SDK

Welcome to the Unifonic Flutter SDK! This SDK provides functionality for integrating Unifonic services into your Flutter applications.

## Features

As of now, the Unifonic SDK Flutter offers the following features:
- Push Notifications for iOS and Android through Unifonic APIs

## Installation

To install the Unifonic SDK Flutter, follow these steps:

1. Add the following dependency to your `pubspec.yaml` file:
```yaml
dependencies:
  unifonic_sdk_flutter:
    git:
      url: https://github.com/UnifonicGit/unifonic-sdk-flutter.git
      path: unifonic_sdk_flutter
      ref: release/0.0.6
```
---
2. Additional setup requirements:  
- **iOS**: Enable Push Notification Capability, and Background Modes for Remote Notifications
- **Android**: Since Android Push Notifications work through FCM, you will have to add your `google-services.json` file to the `android/app` directory.
---
3. In your `main.dart`, use the following code to initialize the Unifonic Flutter SDK:
```dart
void main() async {
  // ... any other initializers
  runApp(const MyApp());
  await Unifonic().init([
    UniPush(apiKey: "your-api-key:your-secret-key"), // best to use a package like "ENVied" or at least "--dart-define"
  ]);
  // ... any other initializers
}
```
---
4. Now, `UniPush` is available to be used via:
```dart
Unifonic.push
```
Thus you can retrieve the token (if it has already been set by the OS) like so:
```dart
Unifonic.push.token
```
---
### Primary Methods
---
#### Register the device (and User) with Unifonic (=> `Future<bool>`)
```dart
Unifonic.registerDevice(userIdentifier: "123456789");
// This method needs to be called before it's possible to send any Push Notification to the device.
// A `userIdentifier` should always be passed. Even if you're planning to track users anonymously,  
// you should provide an Identifier that you can resolve to a real User ID once  
// a User is authenticated.  
// Generally, it can be null. In this case, we will generate a random UUID and store it in SharedPreferences.  
// However, we do not recommend this approach (of leaving the `userIdentifier` empty) as it won't be  
// possible to reconcile a real User once authenticated (as of yet).
// Also, you would have to read the `userIdentifier` key from SharedPreferences in order
// to retrieve the `userIdentifier`.
```
---
### Streams
---
#### onNewTokenStream (=> `String`)
```dart
Unifonic.push.onNewTokenStream.listen((token) {
  debugPrint('New token: $token');
});
```
---
#### onMessageStream (=> `RemoteMessage`)
```dart
Unifonic.push.onMessageStream.listen(onMessageHandler);
```
---
#### onBackgroundMessageStream (=> `RemoteMessage`)
```dart
Unifonic.push.onBackgroundMessageStream.listen(onBackgroundMessage);
```
---
#### onNotificationTapStream (=> `Map<String?, Object?>`)
```dart
Unifonic.push.onNotificationTapStream.listen((message) {
  debugPrint("Message tapped: $message");
});
```
---
### Other methods
---
#### Permission can be requested explicitly (=> `Future<bool>`)
```dart
Unifonic.push.requestPermission();
```
---
#### getNotificationSettings (=> `Future<UNNotificationSettings>`)
```dart
dynamic settings = await Unifonic.push.getNotificationSettings();
debugPrint("alertSetting: ${settings.alertSetting}");
debugPrint("alertStyle: ${settings.alertStyle}");
debugPrint("announcementSetting: ${settings.announcementSetting}");
debugPrint("authorizationStatus: ${settings.authorizationStatus}");
debugPrint("badgeSetting: ${settings.badgeSetting}");
debugPrint("carPlaySetting: ${settings.carPlaySetting}");
debugPrint("criticalAlertSetting: ${settings.criticalAlertSetting}");
debugPrint("lockScreenSetting: ${settings.lockScreenSetting}");
debugPrint(
    "notificationCenterSetting: ${settings.notificationCenterSetting}");
debugPrint(
    "providesAppNotificationSettings: ${settings.providesAppNotificationSettings}");
debugPrint("showPreviewsSetting: ${settings.showPreviewsSetting}");
debugPrint("soundSetting: ${settings.soundSetting}");
```