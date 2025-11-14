import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  bool _loading = true;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      _nameCtl.text = doc['name'] ?? '';
      _phoneCtl.text = doc['phone'] ?? '';
      avatarUrl = doc['avatarUrl'];
    }
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'name': _nameCtl.text.trim(),
      'phone': _phoneCtl.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (x == null) return;
    final user = FirebaseAuth.instance.currentUser!;
    final file = File(x.path);

    final ref = FirebaseStorage.instance.ref().child('avatars/${user.uid}.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'avatarUrl': url});
    setState(() => avatarUrl = url);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar uploaded')));
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login'); // or use MaterialPageRoute
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), actions: [
        IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          GestureDetector(
            onTap: _pickAndUploadAvatar,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null ? const Icon(Icons.person, size: 48) : null,
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: _nameCtl, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 8),
          TextField(controller: _phoneCtl, decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _saveProfile, child: const Text('Save')),
        ]),
      ),
    );
  }
}
