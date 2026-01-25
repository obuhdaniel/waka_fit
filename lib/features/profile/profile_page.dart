import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    final firebaseUser = authProvider.user;

    if (firebaseUser == null) {
      return const Center(child: Text("User not logged in"));
    }

    final displayName =
        firebaseUser.displayName ?? userProvider.name ?? "User";
    final photoUrl = firebaseUser.photoURL;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: navigate to settings
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar with ring
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.cyanAccent, width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                backgroundColor: Colors.grey[800],
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              displayName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Fitness enthusiast | Brooklyn",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 16),

            // Edit profile button
            // OutlinedButton(
            //   style: OutlinedButton.styleFrom(
            //     foregroundColor: Colors.cyanAccent,
            //     side: const BorderSide(color: Colors.cyanAccent),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            //   ),
            //   onPressed: () {},
            //   child: const Text("Edit Profile"),
            // ),

            const SizedBox(height: 24),

                      const SizedBox(height: 32),

            // Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _TabItem(label: "Saved", selected: true),
                _TabItem(label: "Activity"),
                _TabItem(label: "Settings"),
              ],
            ),

            const SizedBox(height: 24),

                      const SizedBox(height: 40),

            // Logout (optional here or move to settings)
            TextButton(
              onPressed: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => AuthScreen()),
                  );
                }
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    
      );
  }
}




class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
        ),
      ],
    );
  }
}


class _TabItem extends StatelessWidget {
  final String label;
  final bool selected;

  const _TabItem({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: selected ? Colors.cyanAccent : Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        if (selected)
          Container(
            height: 2,
            width: 40,
            color: Colors.cyanAccent,
          ),
      ],
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "View All",
            style: TextStyle(color: Colors.cyanAccent),
          ),
        )
      ],
    );
  }
}


class _AvatarGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.cyanAccent, width: 2),
        ),
        child: const CircleAvatar(
          backgroundColor: Colors.grey,
        ),
      ),
    );
  }
}
