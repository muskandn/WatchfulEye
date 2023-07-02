import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//Auth Provider
class Auth with ChangeNotifier {
  IdTokenResult _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
}
