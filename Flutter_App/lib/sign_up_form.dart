import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'http_exception.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _initialized = false;
  bool _isLoading = false;
  Map<String, String> _authData = {
    'name': '',
    'email': '',
    'password': '',
  };
}

void _showErrorDialog(String title, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          )
        ],
      );
    },
  );
}
Future<void> _submit() async {
  if (!_formKey.currentState.validate()) {
    // Invalid!
    return;
  }
  _formKey.currentState.save();
  setState(() {
    _isLoading = true;
  });
  try {
    bool isVerified = await Provider.of<Auth>(context, listen: false)
        .loginWithEmail(_authData['email'], _authData['password']);

    if (isVerified) {
      Navigator.of(context).pop();
    } else {
      _showErrorDialog("Email not verified",
          "We have just sent you a verification email. Please verify your email before continuing");
    }
  } on HttpException catch (error) {
    var errorMessage = 'Authentication error';
    if (error.message.contains('ERROR_INVALID_EMAIL')) {
      errorMessage = 'This email address is invalid';
    } else if (error.message.contains('ERROR_USER_NOT_FOUND')) {
      errorMessage = 'Could not find a user with that email address';
    } else if (error.message.contains('ERROR_WRONG_PASSWORD')) {
      errorMessage = 'This password is invalid';
    } else if (error.message.contains('ERROR_TOO_MANY_REQUESTS')) {
      errorMessage = 'Please try again later';
    }
    _showErrorDialog("Something went wrong", errorMessage);
  } catch (error) {
    const errorMessage = 'Could not sign you in, please try again later.';
    _showErrorDialog("Something went wrong", errorMessage);
    throw error;
  }
  setState(() {
    _isLoading = false;
  });
}
