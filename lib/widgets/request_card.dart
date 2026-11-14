import 'package:flutter/material.dart';
import '../models/request_model.dart';

class RequestCard extends StatelessWidget {
  final RequestModel request;
  final List<Widget> actions;

  const RequestCard({
    super.key,
    required this.request,
    this.actions = const [],
  });

  MaterialColor _urgencyColor() {
    switch (request.urgency) {
      case 'critical':
        return Colors.red;
      case 'urgent':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  MaterialColor _statusColor() {
    switch (request.status) {
      case 'accepted':
        return Colors.blue;
      case 'fulfilled':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel() {
    if (request.status == 'open' && !request.isVerified) {
      return 'PENDING APPROVAL';
    }
    return request.status.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final urgency = _urgencyColor();
    final status = _statusColor();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.bloodGroup,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${request.units} unit(s) for ${request.patientName}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Hospital: ${request.hospital}'),
            Text('City: ${request.city}'),
            Text('Contact: ${request.contactPhone}'),
            if (request.notes.isNotEmpty) Text('Notes: ${request.notes}'),
            if (request.acceptedByName.isNotEmpty)
              Text(
                'Donor: ${request.acceptedByName} (${request.acceptedByPhone})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(request.urgency.toUpperCase()),
                  backgroundColor: urgency.shade100,
                  labelStyle: TextStyle(color: urgency.shade900, fontSize: 12),
                ),
                Chip(
                  label: Text(_statusLabel()),
                  backgroundColor: status.shade100,
                  labelStyle: TextStyle(color: status.shade900, fontSize: 12),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}