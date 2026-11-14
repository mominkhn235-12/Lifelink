import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';
import '../services/request_service.dart';

class CreateRequestScreen extends StatefulWidget {
  final UserModel user;
  const CreateRequestScreen({super.key, required this.user});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');
  final _hospitalController = TextEditingController();
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;
  final _notesController = TextEditingController();

  static const List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];
  static const List<String> _urgencies = ['normal', 'urgent', 'critical'];

  String? _bloodGroup;
  String _urgency = 'normal';
  bool _loading = false;
  final _requestService = RequestService();

  @override
  void initState() {
    super.initState();
    // Pre-fill city and phone from the user's profile.
    _cityController = TextEditingController(text: widget.user.city);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _patientController.dispose();
    _unitsController.dispose();
    _hospitalController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final request = RequestModel(
      requesterId: widget.user.uid,
      requesterName: widget.user.name,
      patientName: _patientController.text.trim(),
      bloodGroup: _bloodGroup!,
      units: int.parse(_unitsController.text.trim()),
      hospital: _hospitalController.text.trim(),
      city: _cityController.text.trim(),
      urgency: _urgency,
      contactPhone: _phoneController.text.trim(),
      notes: _notesController.text.trim(),
    );

    final error = await _requestService.createRequest(request);
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request created successfully')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Blood Request')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _patientController,
                    decoration: const InputDecoration(
                      labelText: 'Patient name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the patient name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _bloodGroup,
                    decoration: const InputDecoration(
                      labelText: 'Blood group needed',
                      prefixIcon: Icon(Icons.bloodtype),
                      border: OutlineInputBorder(),
                    ),
                    items: _bloodGroups
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (value) => setState(() => _bloodGroup = value),
                    validator: (value) =>
                        value == null ? 'Please select a blood group' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _unitsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Units needed (1-10)',
                      prefixIcon: Icon(Icons.water_drop),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final units = int.tryParse(value?.trim() ?? '');
                      if (units == null || units < 1 || units > 10) {
                        return 'Enter a number from 1 to 10';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hospitalController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital',
                      prefixIcon: Icon(Icons.local_hospital),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the hospital';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the city';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _urgency,
                    decoration: const InputDecoration(
                      labelText: 'Urgency',
                      prefixIcon: Icon(Icons.warning_amber),
                      border: OutlineInputBorder(),
                    ),
                    items: _urgencies
                        .map((u) => DropdownMenuItem(
                            value: u, child: Text(u.toUpperCase())))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _urgency = value ?? 'normal'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact phone (03XXXXXXXXX)',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final phone = value?.trim() ?? '';
                      if (phone.length != 11 ||
                          !phone.startsWith('03') ||
                          int.tryParse(phone) == null) {
                        return 'Enter a valid number like 03001234567';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      prefixIcon: Icon(Icons.notes),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit request'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}