import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waka_fit/features/authentitcation/pages/auth_screen.dart';
import 'package:waka_fit/features/authentitcation/pages/providers/auth_provider.dart';
import 'package:waka_fit/shared/providers/user_provider.dart';
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final firebaseUser = authProvider.user; // from AppAuthProvider

    if (firebaseUser == null) {
      return const Center(child: Text("User not logged in"));
    }

    final displayName = firebaseUser.displayName ?? userProvider.name ?? "User";
    final email = firebaseUser.email ?? "";
    final photoUrl = firebaseUser.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // PROFILE PHOTO
            CircleAvatar(
              radius: 60,
              backgroundImage: photoUrl != null
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl == null
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
            const SizedBox(height: 20),

            // NAME
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // EMAIL
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 30),

            // EXTRA USER INFO (OPTIONAL)
            _buildInfoTile("UID", firebaseUser.uid),
            const SizedBox(height: 10),
            _buildInfoTile("Email Verified", firebaseUser.emailVerified ? "Yes" : "No"),
            const SizedBox(height: 10),
            _buildInfoTile("Last Sign-in", firebaseUser.metadata.lastSignInTime.toString()),

            const SizedBox(height: 40),

            // LOGOUT BUTTON
            ElevatedButton(
              onPressed: () async {
                await authProvider.signOut();

                // After logout, send them back to login screen
                if (context.mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> AuthScreen()));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}
