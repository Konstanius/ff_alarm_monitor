import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../utils/globals.dart';

class Request {
  Map<String, dynamic> data;
  late DateTime time;
  String type;
  String server;
  RequestStatus status = RequestStatus.unsent;
  Map<String, dynamic>? ackData;
  AckError? error;

  Request(this.type, this.data, this.server);

  Future<Request> emit(
    bool errors, {
    int timeout = 6000,
    Function(double)? uploadProgress,
    Function(double)? downloadProgress,
    CancelToken? cancelToken,
    bool guest = false,
  }) async {
    time = DateTime.now();

    BaseOptions options = BaseOptions(
      connectTimeout: Duration(milliseconds: timeout),
      receiveTimeout: Duration(milliseconds: timeout),
      sendTimeout: Duration(milliseconds: timeout),
      headers: !guest ? getAuthData(server) : null,
      method: 'POST',
      baseUrl: 'http$server/api/',
      receiveDataWhenStatusError: true,
      validateStatus: (_) => true,
    );

    Dio dio = Dio(options);
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      HttpClient client = HttpClient();
      client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      return client;
    };

    // Convert double (percent 0 to 100) function to int, int function
    Function(int d, int m)? uploadProgressInt = uploadProgress != null ? (int d, int m) => uploadProgress(d / m) : null;
    Function(int d, int m)? downloadProgressInt = downloadProgress != null ? (int d, int m) => downloadProgress(d / m) : null;

    status = RequestStatus.sent;

    cancelToken ??= CancelToken();

    Response<dynamic> response;
    try {
      response = await dio.post(
        'http$server/api/$type',
        data: data,
        onSendProgress: uploadProgressInt,
        onReceiveProgress: downloadProgressInt,
        options: Options(
          validateStatus: (status) {
            return true;
          },
        ),
        cancelToken: cancelToken,
      );
    } catch (e, s) {
      if (!e.toString().contains('timeout') && !e.toString().contains('The connection errored')) {
        print(e);
        print(s);
      }

      error = AckError.timeout;
      status = RequestStatus.timeout;

      // if less than timeout * 0.8 has passed, set error to offline
      if (DateTime.now().millisecondsSinceEpoch - time.millisecondsSinceEpoch < timeout * 0.8) {
        error = AckError.offline;
      }

      try {
        cancelToken.cancel();
      } catch (_) {}
      if (errors) {
        throw error!;
      }
      return this;
    }

    int responseCode = response.statusCode!;
    switch (responseCode) {
      case HttpStatus.ok:
        try {
          status = RequestStatus.acknowledged;

          String responseBody = response.data.toString();
          ackData = jsonDecode(responseBody);
        } catch (e) {
          error = AckError(400, 'Die Antwort des Servers war fehlerhaft');
          status = RequestStatus.failed;
        }
        break;
      case HttpStatus.requestTimeout:
      case HttpStatus.badGateway:
        error = AckError.timeout;
        status = RequestStatus.timeout;
        break;
      case HttpStatus.tooManyRequests:
        error = AckError.tooManyRequests;
        status = RequestStatus.timeout;
        break;
      case HttpStatus.unauthorized:
        if (!guest) {
          error = AckError(HttpStatus.unauthorized, 'Du bist nicht angemeldet');
          status = RequestStatus.failed;
          Globals.logout();
          print('Unauthorized request to $server');
        }
        break;
      default:
        String responseBody = response.data.toString();
        Map<String, dynamic> responseJson = jsonDecode(responseBody);
        error = AckError.from(responseCode, responseJson['message']);
        break;
    }

    if (errors && error != null) {
      throw error!;
    }

    return this;
  }

  static Map<String, String> getAuthData(String server) {
    String rawAuth = '${Globals.prefs.getInt('monitor_id')} ${Globals.prefs.getString('monitor_token')}';
    String encodedAuth = base64Encode(gzip.encode(utf8.encode(rawAuth)));

    Map<String, String> headers = {"authorization": encodedAuth};
    return headers;
  }
}

enum RequestStatus {
  unsent,
  sent,
  acknowledged,
  failed,
  timeout,
}

class AckError {
  int errorCode;
  String errorMessage;

  AckError(this.errorCode, this.errorMessage);

  static AckError get timeout => AckError(408, 'Die Anfrage an den Server hat die Zeitüberschreitung erreicht');
  static AckError get offline => AckError(0, 'Du bist aktuell offline');
  static AckError get tooManyRequests => AckError(429, 'Zu viele Anfragen an den Server. Bitte warte einen Moment und versuche es erneut');
  static AckError get server => AckError(500, 'Ein Serverfehler ist aufgetreten');

  static AckError from(int code, String message) {
    return AckError(code, message);
  }
}
