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
external _login(String url_text);



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

  Future<String> login(String url_text) async {
    final promise = await _login(url_text);
    String delegations = await promiseToFuture<String>(promise);

    print('Juz w darcie Before null');
    print(delegations);
    print('Juz w darcie After null');
    return delegations;
  }
  

}