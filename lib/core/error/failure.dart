import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  String get error => message;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class ApiFailure extends Failure {
  final int? statusCode;
  const ApiFailure({String message = 'API Failure', this.statusCode})
      : super(message);
}

class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({String message = 'Local Database Failure'})
      : super(message);
}
