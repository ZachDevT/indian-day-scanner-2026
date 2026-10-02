import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _controller = BehaviorSubject<bool>.seeded(true);

  StreamSubscription? _sub;

  Stream<bool> get onlineStream => _controller.stream;
  bool get isOnline => _controller.value;

  Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    _controller.add(_isConnected(result));
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      _controller.add(_isConnected(results));
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
