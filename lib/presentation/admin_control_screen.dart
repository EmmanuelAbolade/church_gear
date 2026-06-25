// lib/presentation/admin_control_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/featured_update_model.dart';
import '../data/repositories/admin_repository.dart';

class AdminControlScreen extends StatefulWidget {
  final String tenantId;
  const AdminControlScreen({super.key, required this.tenantId});

  @override
  State<AdminControlScreen> createState() => _AdminControlScreenState();
}

class _AdminControlScreenState extends State<AdminControlScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminRepo = AdminRepository();

  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  String _selectedBadge = 'DAILY DECLARATION 🙏';
  String _initialStatus = 'published';

  final List<String> _badgeOptions = [
    'DAILY DECLARATION 🙏',
    'VERSE OF THE DAY 📖',
    'MONTHLY PROPHECY 🎯',
    'MILESTONE CELEBRATION 🎉'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final newUpdateItem = FeaturedUpdateItem(
      id: const Uuid().v4(),
      tenantId: widget.tenantId,
      badgeText: _selectedBadge,
      titleText: _titleController.text.trim(),
      subtitleText: _subtitleController.text.trim(),
      reactions: {},
      scheduledFor: DateTime.now().toUtc(),
      status: _initialStatus,
    );

    try {
      await _adminRepo.createFeaturedUpdate(newUpdateItem);
      _titleController.clear();
      _subtitleController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully published live!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCreateUpdateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Draft Front Page Update', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBadge,
                    decoration: const InputDecoration(labelText: 'Category Profile', border: OutlineInputBorder()),
                    items: _badgeOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                    onChanged: (val) => setModalState(() => _selectedBadge = val!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Main Content Text', border: OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? 'Content required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _subtitleController,
                    decoration: const InputDecoration(labelText: 'Subtitle / Action Reference Label', border: OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? 'Reference required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _initialStatus,
                    decoration: const InputDecoration(labelText: 'Visibility Scope', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'published', child: Text('Publish Live Immediately')),
                      DropdownMenuItem(value: 'draft', child: Text('Save as Quiet Draft')),
                    ],
                    onChanged: (val) => setModalState(() => _initialStatus = val!),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _submitForm();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Commit Content Entry', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase() == 'published') return Colors.green;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ministry Control Desk'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUpdateModal(context),
        icon: const Icon(Icons.add),
        label: const Text('New Update'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<FeaturedUpdateItem>>(
          stream: _adminRepo.streamAllTenantUpdates(widget.tenantId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final updates = snapshot.data ?? [];
            if (updates.isEmpty) {
              return const Center(child: Text('No active workspace updates registered yet.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: updates.length,
              itemBuilder: (context, index) {
                final item = updates[index];
                final statusColor = _getStatusColor(item.status);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: statusColor.withAlpha(30), borderRadius: BorderRadius.circular(4)),
                              child: Text(item.status.toUpperCase(), style: TextStyle(fontSize: 9, color: statusColor, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(item.titleText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(item.subtitleText, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.green, size: 20),
                              onPressed: () => _adminRepo.updateContentStatus(item.id, 'published'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_note, color: Colors.orange, size: 20),
                              onPressed: () => _adminRepo.updateContentStatus(item.id, 'draft'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => _adminRepo.deleteFeaturedUpdate(item.id),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}