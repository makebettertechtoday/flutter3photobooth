import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

import 'photo_screen.dart'; 
import 'collection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      routes: {
        '/': (context) => HomeScreen(),
        '/photo': (context) => PhotoScreen(),
        '/collection': (context) => CollectionScreen(),
        '/confirmation': (context) => ConfirmationScreen(),
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

// class PhotoScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Photo Screen'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.pushNamed(context, '/collection');
//           },
//           child: Text('Go to Collection Screen'),
//         ),
//       ),
//     );
//   }
// }

// class CollectionScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Collection Screen'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.pushNamed(context, '/confirmation');
//           },
//           child: Text('Go to Confirmation Screen.'),
//         ),
//       ),
//     );
//   }
// }

class ConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
          child: Text('Back to Home Screen'),
        ),
      ),
    );
  }
}
