import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  final String photoPath;

  const CollectionScreen({Key? key, required this.photoPath}) : super(key: key);

  final _labelController = TextEditingController();
  final _namesController = TextEditingController();
  final _emailPhoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Screen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.file(File(photoPath), width: 300, fit: BoxFit.contain),
            const SizedBox(height: 20),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label Your Photo',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _namesController,
              decoration: const InputDecoration(
                labelText: 'Enter names left to right',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailPhoneController,
              decoration: const InputDecoration(
                labelText: 'Email or Phone',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _savePhotoAndData(context),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePhotoAndData(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is not authenticated');
        return;
      }

      // Upload photo to Firebase Storage under the user's UID
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(File(photoPath));

      // Get the download URL for the uploaded photo
      final photoUrl = await storageRef.getDownloadURL();

      // Save photo metadata to Firestore
      await FirebaseFirestore.instance
          .collection('photos')
          .doc(user.uid)
          .collection('files')
          .add({
        'label': _labelController.text,
        'names': _namesController.text,
        'contact': _emailPhoneController.text,
        'photoUrl': photoUrl,
        'timestamp': Timestamp.now(),
      });

      print('Photo and data saved successfully!');
      Navigator.pushNamed(context, '/confirmation');
    } catch (e) {
      print('Error uploading photo and saving data: $e');
    }
  }
}