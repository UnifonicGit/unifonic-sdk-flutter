abstract class UniFeature<T extends UniFeatureConfig> {
  T get config;
  Future<void> init(T config);
}

abstract class UniFeatureConfig {
  bool containsKey(String key);
  dynamic get(String key);
  void set(String key, dynamic value);
}
