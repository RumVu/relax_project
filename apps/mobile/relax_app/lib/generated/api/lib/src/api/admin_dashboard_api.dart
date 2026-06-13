//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:relax_api_client/src/api_util.dart';
import 'package:relax_api_client/src/model/error_response.dart';

class AdminDashboardApi {

  final Dio _dio;

  final Serializers _serializers;

  const AdminDashboardApi(this._dio, this._serializers);

  /// Get admin aggregate dashboard metrics for users, billing, retention, engagement, and operations
  /// 
  ///
  /// Parameters:
  /// * [period] 
  /// * [from] 
  /// * [to] 
  /// * [timezone] 
  /// * [timezoneOffsetMinutes] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
  Future<Response<void>> adminDashboardControllerGetOverview({ 
    String? period,
    DateTime? from,
    DateTime? to,
    String? timezone,
    num? timezoneOffsetMinutes,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/admin/analytics/overview';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'access-token',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (period != null) r'period': encodeQueryParameter(_serializers, period, const FullType(String)),
      if (from != null) r'from': encodeQueryParameter(_serializers, from, const FullType(DateTime)),
      if (to != null) r'to': encodeQueryParameter(_serializers, to, const FullType(DateTime)),
      if (timezone != null) r'timezone': encodeQueryParameter(_serializers, timezone, const FullType(String)),
      if (timezoneOffsetMinutes != null) r'timezoneOffsetMinutes': encodeQueryParameter(_serializers, timezoneOffsetMinutes, const FullType(num)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return _response;
  }

  /// Search indexed dashboard/admin content
  /// 
  ///
  /// Parameters:
  /// * [q] 
  /// * [entityType] 
  /// * [skip] 
  /// * [limit] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
  Future<Response<void>> adminDashboardControllerSearch({ 
    String? q,
    String? entityType,
    num? skip,
    num? limit,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/admin/search';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'access-token',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (q != null) r'q': encodeQueryParameter(_serializers, q, const FullType(String)),
      if (entityType != null) r'entityType': encodeQueryParameter(_serializers, entityType, const FullType(String)),
      if (skip != null) r'skip': encodeQueryParameter(_serializers, skip, const FullType(num)),
      if (limit != null) r'limit': encodeQueryParameter(_serializers, limit, const FullType(num)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return _response;
  }

}
