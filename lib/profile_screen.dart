import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? imageFile;

  var storageRef = FirebaseStorage.instance.ref();

  @override
  void initState() {
    super.initState();
    _getFileUrl();
  }

  void _getFileUrl() async {
    try {
      ListResult result = await storageRef.child('profilepics').listAll();
      for (Reference ref in result.items) {
        // Leverage our naming schema from _getImage()
        if (ref.name.startsWith(FirebaseAuth.instance.currentUser!.uid)) {
          imageFile = await ref.getDownloadURL();
          setState(() {});
        }
      }
    } on FirebaseException {
      // Caught an exception from Firebase.
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Couldn't download profile picture for user"),
        duration: Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Column(
        children: [
          // Display a placeholder or the selected image
          if (imageFile == null) const Icon(Icons.account_circle, size: 72),
          if (imageFile != null) Image.network(imageFile!, width: 250),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () => _getImage(ImageSource.camera),
                  child: const Text("Camera")),
              ElevatedButton(
                  onPressed: () => _getImage(ImageSource.gallery),
                  child: const Text("Gallery")),
            ],
          )
        ],
      ),
    );
  }

  _getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      // Extract the image file extension
      String fileExtension = '';
      int period = image.path.lastIndexOf('.');
      if (period > -1) {
        fileExtension = image.path.substring(period);
      }
      final profileImageRef = storageRef.child(
          "profilepics/${FirebaseAuth.instance.currentUser!.uid}$fileExtension");

      try {
        // Upload the image file.
        await profileImageRef.putFile(File(image.path));
        imageFile = await profileImageRef.getDownloadURL();
        setState(() {});
        // We should provide feedback to the user here.
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile picture successfully saved'),
          duration: Duration(seconds: 2),
        ));
      } on FirebaseException {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error saving profile picture"),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }
}
