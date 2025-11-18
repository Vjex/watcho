import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final Dio dio;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;
      
      if (retryCount < maxRetries) {
        // Calculate exponential backoff delay
        final delay = Duration(
          milliseconds: retryDelay.inMilliseconds * (retryCount + 1),
        );
        
        await Future.delayed(delay);
        
        // Update retry count
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        // Retry the request using the same Dio instance
        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // If retry fails and we've reached max retries, reject
          if (retryCount + 1 >= maxRetries) {
            if (e is DioException) {
              return handler.reject(e);
            }
            return handler.reject(err);
          }
          // Create new error with updated retry count for next attempt
          final newError = DioException(
            requestOptions: err.requestOptions,
            type: err.type,
            error: err.error,
            response: err.response,
          );
          newError.requestOptions.extra['retryCount'] = retryCount + 1;
          return onError(newError, handler);
        }
      }
    }
    
    return handler.reject(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on connection errors, timeouts, and server errors
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}

