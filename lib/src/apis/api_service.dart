import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../utils/app_config.dart';
import '../utils/preference_key.dart';
import '../utils/preference_utils.dart';
import 'base_model.dart';

class ApiService {
  late final Dio _dio;
  final String tag = "API call :";
  late final CancelToken _cancelToken;
  static final Dio mDio = Dio();

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    mDio.options.headers['authorization'] =
        "Bearer ${getString(PreferenceKey.token)}";
    mDio.options.contentType = 'application/json';

    return _instance;
  }

  ApiService._internal() {
    _dio = initApiServiceDio();
  }

  Dio initApiServiceDio() {
    _cancelToken = CancelToken();
    final baseOption = BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      baseUrl: apiBaseUrl,
      contentType: 'application/json',
      headers: {
        'authorization': "Bearer ${getString(PreferenceKey.token)}",
      },
    );
    mDio.options = baseOption;
    final mInterceptorsWrapper = InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint("$tag queryParameters ${options.queryParameters.toString()}",
            wrapWidth: 1024);
        debugPrint("$tag headers ${options.headers.toString()}",
            wrapWidth: 1024);
        debugPrint("$tag ${options.baseUrl.toString() + options.path}",
            wrapWidth: 1024);
        debugPrint("$tag ${options.data.toString()}", wrapWidth: 1024);
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("Code  ${response.statusCode.toString()}", wrapWidth: 1024);
        debugPrint("Response ${response.toString()}", wrapWidth: 1024);
        handler.next(response);
      },
      onError: (e, handler) {
        debugPrint("$tag ${e.error.toString()}", wrapWidth: 1024);
        debugPrint("$tag ${e.response.toString()}", wrapWidth: 1024);
        handler.next(e);
      },
    );
    mDio.interceptors.add(mInterceptorsWrapper);
    return mDio;
  }

  void cancelRequests({CancelToken? cancelToken}) {
    (cancelToken ?? _cancelToken).cancel();
  }

  Future<Response> get(
    String endUrl, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final isConnected = await checkInternet();
      if (!isConnected) {
        return Future.error(ResBaseModel(error: "Internet not connected"));
      }
      return await (_dio.get(
        endUrl,
        queryParameters: params,
        cancelToken: cancelToken ?? _cancelToken,
        options: options,
      ));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return Future.error(ResBaseModel(error: "Poor internet connection"));
      }
      rethrow;
    }
  }

  Future<Response> post(
    String endUrl, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    bool isFormData = false,
  }) async {
    try {
      final isConnected = await checkInternet();
      if (!isConnected) {
        return Future.error(ResBaseModel(error: "Internet not connected"));
      }

      return await (_dio.post(
        endUrl,
        data: isFormData ? FormData.fromMap(data ?? {}) : data,
        queryParameters: params,
        cancelToken: cancelToken ?? _cancelToken,
        options: options,
      ));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return Future.error(ResBaseModel(error: "Poor internet connection"));
      }
      rethrow;
    }
  }

  Future<Response> delete(
    String endUrl, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await (_dio.delete(
        endUrl,
        data: data,
        queryParameters: params,
        cancelToken: cancelToken ?? _cancelToken,
        options: options,
      ));
    } on DioException {
      rethrow;
    }
  }

  Future<Response> multipartPost(
    String endUrl, {
    FormData? data,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await (_dio.post(
        endUrl,
        data: data,
        cancelToken: cancelToken ?? _cancelToken,
        options: options,
      ));
    } on DioException {
      rethrow;
    }
  }

  Future<bool> checkInternet() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    return !connectivityResults.contains(ConnectivityResult.none);
  }
}
