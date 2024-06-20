import 'package:unifonic_sdk_flutter/model/uni_feature.dart';

class UniPush extends UniFeature<UniPushConfig> {
  static UniPush? _instance;
  late UniPushConfig _config;

  UniPush._(this._config);

  factory UniPush({
    required String apiKey,
    // bool locationTracking = false,
    // bool lifecycleTracking = false,
  }) {
    if (_instance == null) {
      final config = UniPushConfig(
        apiKey: apiKey,
        locationTracking: false,
        lifecycleTracking: false,
      );
      _instance = UniPush._(config);
    }
    return _instance!;
  }

  @override
  UniPushConfig get config => _config;

  @override
  Future<void> init(UniPushConfig config) async {
    // Initialize the push notification service with the given config
    _config = config;
    // Add your initialization code here
  }
}

class UniPushConfig extends UniFeatureConfig {
  String? userIdentifier;
  bool locationTracking = false;
  bool lifecycleTracking = false;
  String apiKey;

  UniPushConfig({
    required this.lifecycleTracking,
    required this.locationTracking,
    required this.apiKey,
    this.userIdentifier,
  });

  factory UniPushConfig.fromMap(Map<String, dynamic> map) {
    return UniPushConfig(
      userIdentifier: map['userIdentifier'],
      locationTracking: map['locationTracking'],
      lifecycleTracking: map['lifecycleTracking'],
      apiKey: map['apiKey'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userIdentifier': userIdentifier,
      'locationTracking': locationTracking,
      'lifecycleTracking': lifecycleTracking,
      'apiKey': apiKey,
    };
  }

  @override
  bool containsKey(String key) {
    return toMap().containsKey(key);
  }

  @override
  dynamic get(String key) {
    return toMap()[key];
  }

  @override
  void set(String key, dynamic value) {
    var map = toMap();
    map[key] = value;
    var updatedConfig = UniPushConfig.fromMap(map);
    _updateConfig(updatedConfig);
  }

  void _updateConfig(UniPushConfig newConfig) {
    userIdentifier = newConfig.userIdentifier;
    locationTracking = newConfig.locationTracking;
    lifecycleTracking = newConfig.lifecycleTracking;
    apiKey = newConfig.apiKey;
  }
}
