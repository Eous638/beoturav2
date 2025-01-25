import 'package:http/http.dart' as http;
import 'dart:io';

class SpeedTestService {
  static const String _speedTestUrl = 'https://api2.gladni.rs/api/speed-test';
  static const double _minimumUsableSpeed = 50.0; // Minimum speed in KB/s

  Future<bool> isConnectionUsable() async {
    final stopwatch = Stopwatch()..start();
    final response = await http.get(Uri.parse(_speedTestUrl));
    stopwatch.stop();

    if (response.statusCode == 200) {
      final fileSize = response.contentLength ?? 500 * 1024; // 500 KB
      final downloadTime = stopwatch.elapsedMilliseconds / 1000; // in seconds
      final speed = fileSize / downloadTime / 1024; // KB/s
      return speed >= _minimumUsableSpeed;
    } else {
      throw HttpException('Failed to perform speed test');
    }
  }
}
