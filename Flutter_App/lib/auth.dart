import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'http_exception.dart';

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

//getter for organization name
Future<String> get organization async {
  var user = _auth.currentUser;
  notifyListeners();
  return user != null ? user.displayName : '';
}

Future<String> get email async {
  var user = _auth.currentUser;
  notifyListeners();
  return user != null ? user.email : "";
}

//getter for isAuth bool flag. Utilises currentUser() method to obtain data and refresh user's token simultaneously
Future<bool> get isAuth async {
  var user = _auth.currentUser;
  if (user != null) {
    _token = await user.getIdTokenResult();
    _expiryDate = _token.expirationTime;
    _userId = user.uid;
    notifyListeners();
  }
  return user != null && user.emailVerified;
}

