import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

bool onIosBackground(ServiceInstance service) {
  return true;
}

void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  Location location = Location();
  await location.enableBackgroundMode(enable: true);

  location.onLocationChanged.listen((LocationData currentLocation) async {
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> savedPath = prefs.getStringList('user_path') ?? [];

      savedPath.add(jsonEncode({
        'lat': currentLocation.latitude,
        'lng': currentLocation.longitude,
      }));

      await prefs.setStringList('user_path', savedPath);

      // Update Notification to comply with Foreground Service
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Location Tracking Active",
          content: "Your location is being tracked in the background",
        );
      }
    }
  });
}

