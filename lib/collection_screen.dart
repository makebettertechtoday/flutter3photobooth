import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final _contactController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _namesController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _uploadPhotoAndSaveData(String photoPath) async {
    try {
      setState(() {
        _isSubmitting = true;
      });

      // Upload photo to Firebase Storage
      final File photo = File(photoPath);
      final storageRef = FirebaseStorage.instance.ref().child('photos/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await storageRef.putFile(photo);

      // Get the photo's download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Save form data and photo URL to Firestore
      await FirebaseFirestore.instance.collection('photo_labels').add({
        'names': _namesController.text,
        'contact': _contactController.text,
        'photoUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo and data saved successfully!')),
      );

      setState(() {
        _isSubmitting = false;
      });

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
    // Directly use widget.photoPath instead of fetching via ModalRoute
    final String photoPath = widget.photoPath;

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
                  if (photoPath.isNotEmpty)
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
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(
                          File(photoPath),
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
                                      if (photoPath.isNotEmpty) {
                                        _uploadPhotoAndSaveData(photoPath);
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
              icon: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
              label: const Text(
                'Retake',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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