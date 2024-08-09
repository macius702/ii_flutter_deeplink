
import 'package:agent_dart/agent_dart.dart';
import 'package:flutter_project/ICP/ICP_Connector.dart';

class GreetingClient {
  final ICPconnector _icpConnector;

  GreetingClient(this._icpConnector);

  get actor => _icpConnector.actor;

  /// Calls the greet method on the actor and returns the greeting message.
  Future<String> greet() async {
    final String? response = await _callActorMethod<String>(BackendMethod.greet);

    if (response == null) {
      throw GreetingException("Cannot get greeting message");
    }

    return response;
  }

  /// Calls a method on the actor with the given parameters.
  Future<T?> _callActorMethod<T>(String method, [List<dynamic> params = const []]) async {
    if (actor == null) {
      throw ActorNullException("Actor is null");
    }

    final ActorMethod? func = actor?.getFunc(method);
    if (func != null) {
      final res = await func(params);
      return res as T?;
    }

    throw MethodCallException("Cannot call method: $method");
  }
}

/// Custom exception for greeting-related errors.
class GreetingException implements Exception {
  final String message;
  GreetingException(this.message);
  
  @override
  String toString() => "GreetingException: $message";
}

/// Custom exception for null actor errors.
class ActorNullException implements Exception {
  final String message;
  ActorNullException(this.message);
  
  @override
  String toString() => "ActorNullException: $message";
}

/// Custom exception for method call errors.
class MethodCallException implements Exception {
  final String message;
  MethodCallException(this.message);
  
  @override
  String toString() => "MethodCallException: $message";
}

abstract class BackendMethod {
  static const greet = 'greet';

  static final ServiceClass idl = IDL.Service({
    BackendMethod.greet: IDL.Func([], [IDL.Text], ['query'])
  });
}
