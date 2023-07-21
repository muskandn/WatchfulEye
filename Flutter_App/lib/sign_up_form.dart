import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'http_exception.dart';
import 'auth.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  // bool _initialized = false;
  bool _isLoading = false;
  Map<String, String> _authData = {
    'name': '',
    'email': '',
    'password': '',
  };

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (_formKey.currentState?.validate() == false) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      var org = await firestore
          .collection('organizations')
          .doc(_authData['name'])
          .get();

      if (!org.exists) {
        throw HttpException("Organization does not exist");
      }
      await Provider.of<Auth>(context, listen: false).signupWithEmail(
          _authData['name']!, _authData['email']!, _authData['password']!);
      _showErrorDialog("Verify your email",
          "We have just sent you a verification email. Please verify your email before continuing");
    } on HttpException catch (error) {
      var errorMessage = 'Authentication error';
      if (error.message.contains('ERROR_EMAIL_ALREADY_IN_USE')) {
        errorMessage = 'That email address is already in use';
      } else if (error.message.contains('ERROR_INVALID_EMAIL') ||
          error.message.contains('ERROR_INVALID_CREDENTIAL')) {
        errorMessage = 'This email address is invalid';
      } else if (error.message.contains('ERROR_WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (error.message.contains('Organization does not exist')) {
        errorMessage = 'Organization does not exist';
      }
      _showErrorDialog("Something went wrong", errorMessage);
    } catch (error) {
      const errorMessage = 'Could not sign you up, try again later.';
      _showErrorDialog("Something went wrong", errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
    @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Container(
      height: 360,
      constraints: const BoxConstraints(minHeight: 360),
      width: deviceSize.width * 0.85,
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Theme(
                data: Theme.of(context).copyWith(
                    primaryColor: Theme.of(context).colorScheme.secondary),
                child: TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Organization ID'),
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    _emailFocusNode.requestFocus();
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter a valid ID';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['name'] = value!;
                  },
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                    primaryColor: Theme.of(context).colorScheme.secondary),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  focusNode: _emailFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (value) {
                    _passwordFocusNode.requestFocus();
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
              ),
              
              
            ],
          ),
        ),
      ),
    );
  }
  }
