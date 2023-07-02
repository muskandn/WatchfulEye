import 'dart:ui';

import 'package:provider/provider.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
          return MaterialApp(
            title: 'HawkEye',
            theme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: Color(0xFF121212),
              accentColor: Colors.red,
            ),
            home: Scaffold(
              appBar: AppBar(
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
                 ,
            ),
    );
}
