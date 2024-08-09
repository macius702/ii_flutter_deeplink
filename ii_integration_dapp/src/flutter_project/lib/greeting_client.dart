

// the Greeting client class
import 'package:agent_dart/agent_dart.dart';
import 'package:flutter_project/ICP/ICP_Connector.dart';

class GreetingClient {
  final ICPconnector _icpConnector;
  GreetingClient(this._icpConnector);

  get actor => _icpConnector.actor;

  Future<String> Greet() async {
    String ?r = await callActorMethod<String>(
        BackendMethod.greet, []);

    // result is record {scores: []}
    // result is one element Map
    // take the value of the signle element of result

    if (r == null) {
      throw Exception("Cannot get greet");
    }

    var result = r;

    if (result != null) {
      return result;
      
    } 
    throw Exception("Cannot get a greet");
  }

  Future<T?> callActorMethod<T>(String method,
      [List<dynamic> params = const []]) async {
    if (actor == null) {
      throw Exception("Actor is null");
    }

    ActorMethod? func = actor?.getFunc(method);
    if (func != null) {
      var res = await func(params);
      return res as T?;
    }

    throw Exception("Cannot call method: $method");
  }

}


abstract class BackendMethod {

  static const greet = 'greet';

  /// you can copy/paste from .dfx/local/canisters/counter/counter.did.js
  /// 

  static final ServiceClass idl =  IDL.Service({ BackendMethod.greet : IDL.Func([], [IDL.Text], ['query']) });

}
