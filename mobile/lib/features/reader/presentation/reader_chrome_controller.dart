import 'package:flutter/foundation.dart';

class ReaderChromeController extends ChangeNotifier {
  ReaderChromeController({this.hideThreshold = 24});

  final double hideThreshold;
  var _downwardTravel = 0.0;
  var _visible = true;

  bool get visible => _visible;

  void handleContentScroll(double delta, {bool atTop = false}) {
    if (!delta.isFinite) return;
    if (atTop || delta < 0) {
      _downwardTravel = 0;
      _setVisible(true);
      return;
    }
    if (delta <= 0 || !_visible) return;
    _downwardTravel += delta;
    if (_downwardTravel >= hideThreshold) _setVisible(false);
  }

  void reveal() {
    _downwardTravel = 0;
    _setVisible(true);
  }

  void _setVisible(bool value) {
    if (_visible == value) return;
    _visible = value;
    notifyListeners();
  }
}
