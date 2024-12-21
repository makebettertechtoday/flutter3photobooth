import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CollectionScreen extends StatefulWidget {
  final String photoPath;

  const CollectionScreen({Key? key, required this.photoPath}) : super(key: key);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namesController = TextEditingController();
  final _lastnamesController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _namesController.dispose();
    _lastnamesController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _savePhotoAndData(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('User is not authenticated');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to continue.')),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      // Upload photo to Firebase Storage under the user's UID
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(File(widget.photoPath));

      // Get the download URL for the uploaded photo
      final photoUrl = await storageRef.getDownloadURL();

      // Save photo metadata to Firestore
      await FirebaseFirestore.instance
          .collection('photos')
          .doc(user.uid)
          .collection('files')
          .add({
        'names': _namesController.text,
        'lastnames': _lastnamesController.text,
        'contact': _contactController.text,
        'photoUrl': photoUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo and data saved successfully!')),
      );

      setState(() {
        _isSubmitting = false;
      });

      // Navigate to confirmation screen
      Navigator.pushNamed(context, '/confirmation');
    } catch (e) {
      print('Error uploading photo and saving data: $e');
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save photo and data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Screen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  if (widget.photoPath.isNotEmpty)
                    Container(
                      width: 600,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(4, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          File(widget.photoPath),
                          width: 580,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    const Text('No photo captured.'),
                  const SizedBox(height: 24),
                  Container(
                    width: 600,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Label Your Photo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Lastname(s)'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _lastnamesController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter lastname(s)',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Enter names left to right'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _namesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter names...',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Email or Phone'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _contactController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter email or phone',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      if (widget.photoPath.isNotEmpty) {
                                        _savePhotoAndData(context);
                                      }
                                    }
                                  },
                            child: _isSubmitting
                                ? const CircularProgressIndicator()
                                : const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/photo');
              },
              icon:
                  const Icon(Icons.arrow_back, size: 24, color: Colors.white),
              label: const Text(
                'Retake',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(110, 55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
