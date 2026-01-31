library;

class AppException implements Exception {
  final String message;
  final String type;
  final int? statusCode;

  AppException({
    required this.message,
    this.type = 'APP_ERROR',
    this.statusCode,
  });

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  ValidationException({required super.message})
    : super(type: 'VALIDATION_ERROR', statusCode: 400);
}

class NetworkException extends AppException {
  NetworkException({required super.message})
    : super(type: 'NETWORK_ERROR', statusCode: 0);
}

class NotFoundException extends AppException {
  NotFoundException({required super.message})
    : super(type: 'NOT_FOUND', statusCode: 404);
}

class UnauthorizedException extends AppException {
  UnauthorizedException({required super.message})
    : super(type: 'UNAUTHORIZED', statusCode: 401);
}

class ServerException extends AppException {
  ServerException({required super.message})
    : super(type: 'SERVER_ERROR', statusCode: 500);
}

abstract class Result<T> {
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException error) onError,
  });
}

class Success<T> implements Result<T> {
  final T data;

  Success(this.data);

  @override
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException error) onError,
  }) {
    return onSuccess(data);
  }
}

class Failure<T> implements Result<T> {
  final AppException exception;

  Failure(this.exception);

  @override
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException error) onError,
  }) {
    return onError(exception);
  }
}
