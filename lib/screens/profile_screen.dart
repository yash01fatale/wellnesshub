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

  bool _isLoading = true;
  bool _isSaving = false;

  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        _nameCtl.text = data["name"] ?? "";
        _phoneCtl.text = data["phone"] ?? "";
        _avatarUrl = data["avatarUrl"];
      }
    } catch (e) {
      _showSnack("Error loading profile: $e");
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack("Login required");
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          "name": _nameCtl.text.trim(),
          "phone": _phoneCtl.text.trim(),
        },
        SetOptions(merge: true),
      );

      _showSnack("Profile updated!");
    } catch (e) {
      _showSnack("Error saving: $e");
    }

    setState(() => _isSaving = false);
  }

  Future<void> _pickAvatar() async {
    if (_isSaving) return;

    final picker = ImagePicker();
    final x =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (x == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final file = File(x.path);

    setState(() => _isSaving = true);

    try {
      final ref =
          FirebaseStorage.instance.ref("avatars/${user.uid}_${DateTime.now()}.jpg");

      await ref.putFile(file);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({"avatarUrl": url}, SetOptions(merge: true));

      setState(() => _avatarUrl = url);

      _showSnack("Profile picture updated!");
    } catch (e) {
      _showSnack("Error uploading image: $e");
    }

    setState(() => _isSaving = false);
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // -------------------------------------
  // 🔥 UI SECTION STARTS HERE
  // -------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            color: Colors.redAccent,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // ------- Background Gradient -------
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.15),
                        theme.colorScheme.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // ------- Main Scrollable Content -------
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 30),
                  child: Column(
                    children: [
                      _buildAvatarCard(theme),
                      const SizedBox(height: 30),
                      _buildGlassCard(theme),
                      const SizedBox(height: 30),
                      _buildSaveButton(theme),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  // ---------------------------------------------------------
  // 🎨 1. Avatar Section with Card Shadow & Rounded Design
  // ---------------------------------------------------------
  Widget _buildAvatarCard(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.1),
          ),
        ],
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                child: _avatarUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white70)
                    : null,
              ),
              GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _nameCtl.text.isEmpty ? "Your Name" : _nameCtl.text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 🎨 2. Glassmorphism Form Card
  // ---------------------------------------------------------
  Widget _buildGlassCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 5),
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Details",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary)),
          const SizedBox(height: 20),

          // Name Field
          _buildInput("Full Name", Icons.person, _nameCtl),

          const SizedBox(height: 20),

          // Phone
          _buildInput("Phone Number", Icons.phone, _phoneCtl),
        ],
      ),
    );
  }

  Widget _buildInput(String label, IconData icon, TextEditingController ctl) {
    return TextField(
      controller: ctl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ---------------------------------------------------------
  // 🎨 3. Save Button
  // ---------------------------------------------------------
  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Save Changes", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
