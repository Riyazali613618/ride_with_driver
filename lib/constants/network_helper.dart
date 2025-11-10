// lib/services/network_helper.dart

import 'dart:convert';

import 'package:http/http.dart' as http;

class NetworkHelper {
  static Future<Map<String, dynamic>> handleResponse(
      http.Response response) async {
    switch (response.statusCode) {
      case 200:
      case 201:
        var responseJson = json.decode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 404:
        throw NotFoundException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while communicating with server with status code: ${response.statusCode}');
    }
  }

  static dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        try {
          var responseJson = json.decode(response.body);
          return responseJson;
        } catch (e) {
          return response.body;
        }
      case 400:
        throw BadRequestException(response.body);
      case 401:
      case 403:
        throw UnauthorisedException(response.body);
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while communicating with server with status code: ${response.statusCode}');
    }
  }
}

class AppException implements Exception {
  final String message;
  final String prefix;

  AppException(this.message, this.prefix);

  @override
  String toString() {
    return "$prefix$message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String message = ""])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([String message = ""])
      : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([String message = ""])
      : super(message, "Unauthorised: ");
}

class NotFoundException extends AppException {
  NotFoundException([String message = ""]) : super(message, "Not Found: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String message = ""])
      : super(message, "Invalid Input: ");
}
