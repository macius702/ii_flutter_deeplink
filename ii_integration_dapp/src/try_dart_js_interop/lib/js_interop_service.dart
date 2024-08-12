@JS()
library js_interop;


import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS()
external void _showAlert (String message);

@JS()
external void _requestFullScreen();

@JS()
external _getSomeAsyncData();

@JS()
external _login();

class JsInteropService {
  void showAlert(String message) {
    _showAlert(message);
  }
  void requestFullScreen() {
    _requestFullScreen();
  }

  getSomeAsyncData() async {
    final promise = await _getSomeAsyncData();
    final data = await promiseToFuture(promise);
    print(data);
  }

  login() async {
    final promise = await _login();
    final data = await promiseToFuture(promise);
    print(data);
  }
  

}