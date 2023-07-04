import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

void _showErrorDialog(BuildContext context, String title, String message) {
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

bool exit = false;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isAuth = false;
  String _camID = "", message = "No violence", _location = "";
  double _latitude, _longitude;
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  Future<dynamic> _notificationHandler(
      Map<String, dynamic> notification) async {
    final dynamic data = notification['data'] ?? notification;
    setState(() async {
      message = "Violence detected";
      _camID = data['camID'];
      _latitude = double.parse(data['latitude']);
      _longitude = double.parse(data['longitude']);
      List<Address> addreses = await Geocoder.local
          .findAddressesFromCoordinates(Coordinates(_latitude, _longitude));
      _location = addreses.first.featureName;
      String file = data['file'];
      exit = false;
      String downloadURL =
          await FirebaseStorage.instance.ref('/$file.mp4').getDownloadURL();
      print(downloadURL);
      _controller = VideoPlayerController.network(downloadURL);
      _initializeVideoPlayerFuture = _controller.initialize();
      _controller.setLooping(true);
      _controller.play();
    });
    await HapticFeedback.heavyImpact();
  }
}