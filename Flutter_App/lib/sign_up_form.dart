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
