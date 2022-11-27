// ignore_for_file: avoid_catching_errors

import 'dart:io';
import 'package:dart_deta_frog_todo_server/controllers/auth.controller.dart';
import 'package:dart_deta_frog_todo_server/helpers/globals.dart';
import 'package:dart_deta_frog_todo_server/models/user.model.dart';
import 'package:dart_deta_frog_todo_server/strategies/base.strategy.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:tuple/tuple.dart';

///
class JwtAuthStrategy extends Strategy {
  ///
  JwtAuthStrategy({
    required this.jwtSecret,
    required this.expiresIn,
  }) : super();

  final _authController = locator<AuthController>();

  ///
  final Duration expiresIn;

  ///
  final String? jwtSecret;

  /// a simple function to sign user with unique token
  String sign(User user) {
    final jwt = JWT(user.key);
    return jwt.sign(
      SecretKey(jwtSecret!),
      expiresIn: expiresIn,
    );
  }

  @override
  Future<bool> validate(String username, String password) async {
    final userExist = await _authController.validateUser(
      User(
        username: username,
        password: password,
      ),
    );
    if (userExist.item1) {
      return true;
    }
    return false;
  }

  @override
  Future<Response?> verifyAuth(Map<String, String> headers) async {
    if (jwtSecret == null) {
      logger.w('[JwtAuthStrategy] Your jwtSecret were not defined !');
      return null;
    }

    String? bearerToken;

    for (final element in headers.keys) {
      if (element.toLowerCase() == HttpHeaders.authorizationHeader) {
        bearerToken = headers[element]!.split(' ').last;
      }
    }

    if (bearerToken == null) {
      return Response(
        statusCode: HttpStatus.badRequest,
        body: 'Bad Request',
      );
    }

    try {
      JWT.verify(bearerToken, SecretKey(jwtSecret!));
    } on JWTExpiredError {
      return Response(
        statusCode: HttpStatus.unauthorized,
        body: 'Token expired',
      );
    } on JWTError catch (e) {
      logger.w('[JwtAuthStrategy]: A JWTError occured: ${e.message}');
      return Response(
        statusCode: HttpStatus.unauthorized,
        body: e.message,
      );
    } catch (e) {
      logger.w('[JwtAuthStrategy]: And error occured: ${e.toString()}');
      return Response(
        statusCode: HttpStatus.unauthorized,
        body: e.toString(),
      );
    }

    return null;
  }
}
