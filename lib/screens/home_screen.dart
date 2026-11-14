import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';
import '../utils/blood_utils.dart';
import '../services/auth_services.dart';
import '../services/request_service.dart';
import '../widgets/request_card.dart';
import 'create_request_screen.dart';

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
          floatingActionButton: user.role == 'requester'
              ? FloatingActionButton.extended(
                  icon: const Icon(Icons.add),
                  label: const Text('New request'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateRequestScreen(user: user),
                      ),
                    );
                  },
                )
              : null,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user.name}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('${user.role.toUpperCase()}  |  '
                        '${user.bloodGroup}  |  ${user.city}'),
                    const SizedBox(height: 16),
                    Expanded(child: _roleContent(user)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _roleContent(UserModel user) {
    switch (user.role) {
      case 'requester':
        return _MyRequests(user: user);
           case 'donor':
        return _MatchingRequests(user: user);
            case 'admin':
        return const _PendingRequests();
      default:
        return const SizedBox();
    }
  }
}

class _MyRequests extends StatelessWidget {
  final UserModel user;
  const _MyRequests({required this.user});

  Future<void> _change(
      BuildContext context, RequestModel request, String status) async {
    final error = await RequestService().updateStatus(request.id, status);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestModel>>(
      stream: RequestService().myRequests(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!;
        if (requests.isEmpty) {
          return const Center(
            child: Text('No requests yet. Tap "New request" to create one.'),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return RequestCard(
              request: request,
              actions: [
                if (request.status == 'open')
                  TextButton(
                    onPressed: () => _change(context, request, 'cancelled'),
                    child: const Text('Cancel request'),
                  ),
                if (request.status == 'accepted')
                  TextButton(
                    onPressed: () => _change(context, request, 'fulfilled'),
                    child: const Text('Mark fulfilled'),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
class _MatchingRequests extends StatelessWidget {
  final UserModel user;
  const _MatchingRequests({required this.user});

  Future<void> _accept(BuildContext context, RequestModel request) async {
    final error = await RequestService().acceptRequest(
      requestId: request.id,
      donorId: user.uid,
      donorName: user.name,
      donorPhone: user.phone,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Request accepted. The requester will contact you.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestModel>>(
      stream: RequestService().openRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final matches = snapshot.data!.where((r) {
          final sameCity =
              r.city.trim().toLowerCase() == user.city.trim().toLowerCase();
          final compatible = BloodUtils.canDonate(user.bloodGroup, r.bloodGroup);
          return r.isVerified && sameCity && compatible;
        }).toList();
        if (matches.isEmpty) {
          return const Center(
            child: Text('No matching requests in your city right now.'),
          );
        }

        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final request = matches[index];
            return RequestCard(
              request: request,
              actions: [
                ElevatedButton(
                  onPressed: () => _accept(context, request),
                  child: const Text('Accept'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
class _PendingRequests extends StatelessWidget {
  const _PendingRequests();

  Future<void> _show(BuildContext context, String? error, String done) async {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? done)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = RequestService();

    return StreamBuilder<List<RequestModel>>(
      stream: service.openRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final pending = snapshot.data!.where((r) => !r.isVerified).toList();

        if (pending.isEmpty) {
          return const Center(child: Text('No requests waiting for approval.'));
        }

        return ListView.builder(
          itemCount: pending.length,
          itemBuilder: (context, index) {
            final request = pending[index];
            return RequestCard(
              request: request,
              actions: [
                TextButton(
                  onPressed: () async {
                    final error =
                        await service.updateStatus(request.id, 'rejected');
                    if (context.mounted) {
                      _show(context, error, 'Request rejected');
                    }
                  },
                  child: const Text('Reject'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final error = await service.verifyRequest(request.id);
                    if (context.mounted) {
                      _show(context, error, 'Request approved');
                    }
                  },
                  child: const Text('Approve'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}