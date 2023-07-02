import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//Auth Provider
class Auth with ChangeNotifier {
  IdTokenResult _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //getter for token data, returns _token
  IdTokenResult get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) return _token;
    return null;
  }
}
