// lib/core/services/location_service.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    // 1) سرویس لوکیشن روشن باشد
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // 2) مجوزها
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    // 3) iOS Precise check
    if (Platform.isIOS) {
      final status = await Geolocator.getLocationAccuracy();
      if (status == LocationAccuracyStatus.reduced) {
        throw Exception(
            'iOS Precise Location is OFF. Enable "Precise Location" in Settings.');
      }
    }

    // 4) تلاش سریع
    try {
      final quick = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 3),
      );
      if (quick.accuracy <= 50) {
        return quick;
      }
    } catch (_) {
      // ادامه می‌دهیم
    }

    // 5) گوش دادن به استریم تا رسیدن به دقت مطلوب
    final settings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,

    );

    final controller = StreamController<Position>();
    final sub = Geolocator.getPositionStream(locationSettings: settings).listen(
          (pos) {
        controller.add(pos);
        print("location__ : $pos");
      },
      onError: (e) {
        controller.addError(e);
      },
    );

    try {
      final pos = await controller.stream
          .firstWhere((p) => p.accuracy <= 50)
          .timeout(const Duration(seconds: 15));
      return pos;
    } on TimeoutException {
      // اگر به دقت مطلوب نرسید، fallback
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } finally {
      await sub.cancel();
      await controller.close();
    }
  }
}


// // lib/core/services/location_service.dart
// import 'package:geolocator/geolocator.dart';
//
// class LocationService {
//   Future<Position> getCurrentPosition() async {
//     final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw Exception('Location services are disabled');
//     }
//
//     var permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw Exception('Location permission denied');
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       throw Exception('Location permission permanently denied');
//     }
//
//     return Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//   }
// }
