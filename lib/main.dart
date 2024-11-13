import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for controlling the orientation

import 'photo_screen.dart'; 
import 'collection_screen.dart';
import 'confirmation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lock the screen to landscape mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  // Sign in anonymously when the app starts
  await _signInAnonymously();

  runApp(MyApp());
}

// Function to handle anonymous sign-in
Future<void> _signInAnonymously() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
    print('Signed in anonymously');
  } catch (e) {
    print('Error signing in anonymously: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle routes dynamically
        if (settings.name == '/collection') {
          final photoPath = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) {
              return CollectionScreen(photoPath: photoPath ?? '');
            },
          );
        }
        // Default route handling
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => HomeScreen());
          case '/photo':
            return MaterialPageRoute(builder: (context) => PhotoScreen());
          case '/confirmation':
            return MaterialPageRoute(builder: (context) => ConfirmationScreen());
          default:
            return null;
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/photo');
              },
              child: Text('Go to Photo Screen'),
            )
          ],
        ),
      ),
    );
  }
}
