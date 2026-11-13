import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_services.dart';

class HomeScreen extends StatelessWidget {
  final String uid;
  const HomeScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return StreamBuilder<UserModel?>(
      stream: auth.userStream(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('LifeLink'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () => auth.logout(),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bloodtype, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome, ${user.name}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('${user.role.toUpperCase()}  |  '
                        '${user.bloodGroup}  |  ${user.city}'),
                    const SizedBox(height: 24),
                    Text(
                      _roleMessage(user.role),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _roleMessage(String role) {
    switch (role) {
      case 'donor':
        return 'Matching blood requests will appear here.';
      case 'requester':
        return 'You will be able to create blood requests here.';
      case 'admin':
        return 'You will be able to manage requests and users here.';
      default:
        return '';
    }
  }
}