import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _loading = false;

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF1B2230);
  static const Color gold = Color(0xFFF0A93E);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  Future<void> _changePassword() async {
    final newPass = _newPasswordCtrl.text.trim();
    final confirmPass = _confirmPasswordCtrl.text.trim();

    if (newPass.length < 6) {
      _showMsg("Password must be at least 6 characters!");
      return;
    }

    if (newPass != confirmPass) {
      _showMsg("New passwords do not match!");
      return;
    }

    setState(() => _loading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPass);
        _showMsg("Password updated successfully!");
        _newPasswordCtrl.clear();
        _confirmPasswordCtrl.clear();
        _currentPasswordCtrl.clear();
      }
    } catch (e) {
      _showMsg("Error: $e (Re-authentication may be required)");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      try {
        await _auth.sendPasswordResetEmail(email: user.email!);
        _showMsg("Password reset email sent to ${user.email}");
      } catch (e) {
        _showMsg("Error: $e");
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        title: const Text("Delete Account?", style: TextStyle(color: paper, fontWeight: FontWeight.bold)),
        content: const Text(
          "Are you sure you want to permanently delete your account and all associated study data? This action cannot be undone.",
          style: TextStyle(color: muted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: muted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Delete Account", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _loading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final uid = user.uid;
        await _db.collection('users').doc(uid).delete();
        await user.delete();

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } catch (e) {
      _showMsg("Delete Account failed: $e (Please re-login and try again)");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: surface),
    );
  }

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Security & Account", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CHANGE PASSWORD", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: hairline),
              ),
              child: Column(
                children: [
                  _passwordField("New Password", _newPasswordCtrl),
                  const SizedBox(height: 14),
                  _passwordField("Confirm New Password", _confirmPasswordCtrl),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: ink,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: ink, strokeWidth: 2))
                        : const Text("Update Password", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("ACCOUNT ACTIONS", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: hairline),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.mark_email_read_outlined, color: paper, size: 20),
                    title: const Text("Send Password Reset Email", style: TextStyle(color: paper, fontSize: 14)),
                    subtitle: Text("Send reset link to ${user?.email ?? 'registered email'}", style: const TextStyle(color: muted, fontSize: 12)),
                    onTap: _sendPasswordReset,
                  ),
                  const Divider(color: hairline, height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent, size: 20),
                    title: const Text("Delete Account", style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text("Permanently delete account and learning data", style: TextStyle(color: muted, fontSize: 12)),
                    onTap: _confirmDeleteAccount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: surfaceHi,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hairline),
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        style: const TextStyle(color: paper, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: muted, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
