import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:location_geocoder/location_geocoder.dart';
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
      const apiKey = "";
      late LocatitonGeocoder geocoder = LocatitonGeocoder(apiKey);

      final address = await geocoder
          .findAddressesFromCoordinates(Coordinates(_latitude, _longitude));
      _location = address.first.addressLine;
      String file = data['file'];
      exit = false;
      String downloadURL =
          await FirebaseStorage.instance.ref('/$file.mp4').getDownloadURL();
      print(downloadURL);
      _controller = VideoPlayerController.networkUrl(Uri.parse(downloadURL));
      _initializeVideoPlayerFuture = _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.play();
    });
    await HapticFeedback.heavyImpact();
  }

  @override
  void initState() {
    bool initialized = false;
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    if (!initialized) {
      // For iOS request permission first.
      firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print("violence detected");
        final dynamic data = message.data;
        print(data);

        HapticFeedback.vibrate();
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from terminated state!');
        final dynamic data = message.data;
        print(data);
      });

      firebaseMessaging.getToken().then((token) {
        print('Firebase Messaging Token: $token');
      }).catchError((error) {
        print('Error getting Firebase Messaging token: $error');
      });

      initialized = true;
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (exit) _controller.dispose();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        )
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) {
          auth.isAuth.then((value) {
            setState(() {
              isAuth = value;
            });
          });

          return MaterialApp(
            title: 'HawkEye',
            theme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: Color(0xFF121212),
              accentColor: Colors.red,
            ),
            home: Scaffold(
              appBar: isAuth
                  ? AppBar(
                      title: Text("HawkEye"),
                      backgroundColor: Colors.redAccent,
                      elevation: 50.0,
                      actions: [
                        IconButton(
                          icon: Icon(Icons.logout),
                          onPressed: () {
                            auth.logout();
                          },
                        )
                      ],
                    )
                  : null,
              body: isAuth
                  ? MainPage(message, _camID, _location, _latitude, _longitude,
                      _controller, _initializeVideoPlayerFuture)
                  : LoginPage(),
            ),
          );
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final String message; // Mark these fields as final
  final String camID;
  final String location;
  final double latitude;
  final double longitude;

  final VideoPlayerController controller;
  final Future<void> initializeVideoPlayerFuture;
  const MainPage(this.message, this.camID, this.location, this.latitude,
      this.longitude, this.controller, this.initializeVideoPlayerFuture,
      {super.key});


  MainPage(this.message, this.camID, this.location, this.latitude,
      this.longitude, this.controller, this.initializeVideoPlayerFuture);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: (exit || widget.controller == null)
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceAround,
      children: [
        if (exit || widget.controller == null)
          Center(
            child: Text(
              "No violence detected",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
        if (exit || widget.controller == null)
          SizedBox(
            height: 40,
          ),
        if (exit || widget.controller == null)
          Icon(
            Icons.security,
            size: 80,
            color: Colors.white70,
          ),
        if (!exit && widget.controller != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              widget.message,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (widget.controller != null && !exit)
          FutureBuilder(
            future: widget.initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the aspect ratio of the video.
                return Card(
                  margin: const EdgeInsets.all(16),
                  child: AspectRatio(
                    aspectRatio: widget.controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 20.0,
                              offset: Offset(0, 5),
                              spreadRadius: 0.9,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: 2, color: Theme.of(context).accentColor)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: VideoPlayer(widget.controller),
                      ),
                    ),
                  ),
                );
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner.
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          if (widget.controller != null && !exit)
          Center(
            child: Column(
              children: [
                Text(
                  "Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 20.0,
                        offset: Offset(0, 3),
                        spreadRadius: 0.9,
                      )
                    ],
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Theme.of(context).accentColor,
                        width: 1,
                      ),
                    ),
                    color: Colors.black,
                    child: Container(
                      height: 100,
                      width: 360,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Camera ID : ${widget.camID}",
                            style: TextStyle(fontSize: 17),
                          ),
                          Text(
                            "Location : ${widget.location}",
                            style: TextStyle(fontSize: 17),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

            if (!exit && widget.controller != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ButtonTheme(
                  minWidth: 150,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () async {
                      Position currentPosition;
                      currentPosition = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,
                      );
                      await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high)
                          .then((Position position) async {
                        setState(() {
                          // Store the position in the variable
                          currentPosition = position;
                        });
                        String mapOptions = [
                          'saddr=${currentPosition.latitude},${currentPosition.longitude}',
                          'daddr=${widget.latitude},${widget.longitude}',
                          'dir_action=navigate'
                        ].join('&');
                        final url = 'https://www.google.com/maps?$mapOptions';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        } else {
                          throw 'Could not launch $url';
                        }
                      }).catchError((e) {
                        print(e);
                        _showErrorDialog(context, "Something went wrong", e);
                      });
                    },
                    child: const Text("Navigate"),
                  ),
                ),
                ButtonTheme(
                  minWidth: 150,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        exit = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: const Text("Close"),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
  }
