@JS()
library js_interop;


import 'package:js/js.dart';

@JS()
external void _showAlert (String message);

@JS()
external void _requestFullScreen();


class JsInteropService {
  void showAlert(String message) {
    _showAlert(message);
  }
  void requestFullScreen() {
    _requestFullScreen();
  }

}