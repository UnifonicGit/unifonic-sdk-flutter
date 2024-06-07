import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../service/geolocation_service.dart';

class LatLngLike {
  final double latitude;
  final double longitude;

  LatLngLike(this.latitude, this.longitude);
}

class UniLocationVM {
  static final UniLocationVM _instance = UniLocationVM._internal();
  factory UniLocationVM() => _instance;
  UniLocationVM._internal();

  final GeolocationService _geolocationService = GeolocationService();
  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();
  bool _isServiceEnabled = false;

  Stream<Position> get positionStream => _positionController.stream;

  void configureService(bool isEnabled) {
    _isServiceEnabled = isEnabled;
  }

  Future<void> startLocationUpdates() async {
    if (!_isServiceEnabled) {
      return;
    }

    try {
      Position position = await _geolocationService.determinePosition();
      _positionController.add(position);
    } catch (e) {
      _positionController.addError(e);
    }
  }

  Future<LatLngLike?> getCurrentPosition() async {
    if (!_isServiceEnabled) {
      throw 'Location services are disabled.';
    }

    try {
      Position position = await _geolocationService.determinePosition();
      return LatLngLike(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Error: $e");
    }
    return null;
  }

  void dispose() {
    _positionController.close();
  }
}
