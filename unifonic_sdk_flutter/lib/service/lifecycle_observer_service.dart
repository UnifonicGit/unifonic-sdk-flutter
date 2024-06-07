import 'package:flutter/material.dart';

class LifecycleObserver with WidgetsBindingObserver {
  static final LifecycleObserver _instance = LifecycleObserver._internal();
  factory LifecycleObserver() => _instance;

  LifecycleObserver._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  bool enabledAudienceTracking = false;
  late AppLifecycleState _state;

  AppLifecycleState get state => _state;

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _state = state;
    if (state == AppLifecycleState.resumed) {
      debugPrint('App is in the foreground');
      // Call API and save event that user opened app
      if (enabledAudienceTracking) {
        debugPrint("HTTP CALL TO TRACK OPENED");
      }
    } else if (state == AppLifecycleState.paused) {
      debugPrint('App is in the background');
      // Call API and save event that user minimized app
      if (enabledAudienceTracking) {
        debugPrint("HTTP CALL TO TRACK MINIMIZED");
      }
    } else if (state == AppLifecycleState.detached) {
      debugPrint('App is detached');
      // Call API and save event that user closed app
      if (enabledAudienceTracking) {
        debugPrint("HTTP CALL TO TRACK CLOSED");
      }
    }
  }
}
