import 'package:edu_app/main.dart';
import 'package:edu_app/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.authState.user;

    return Scaffold(
      appBar: CustomAppBar(title: "Profile"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                child:
                    user?.photoUrl == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
              ),
              const SizedBox(height: 20),
              Text(
                user?.displayName ?? 'N/A',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'N/A',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  context.signOut();
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
