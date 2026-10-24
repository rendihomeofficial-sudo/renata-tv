import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);
  Timer? _timer;

  void startMonitoring() {
    _checkConnection();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkConnection();
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
  }

  Future<void> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('dns.google')
          .timeout(const Duration(seconds: 3));
      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (isOnline.value != connected) {
        isOnline.value = connected;
      }
    } on SocketException catch (_) {
      if (isOnline.value != false) {
        isOnline.value = false;
      }
    } on TimeoutException catch (_) {
      if (isOnline.value != false) {
        isOnline.value = false;
      }
    } catch (_) {
      if (isOnline.value != false) {
        isOnline.value = false;
      }
    }
  }
}
