import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/campaign/data/models/campaign_model.dart';
import 'package:influcollb_app/features/campaign/presentation/view_model/campaign_providers.dart';
import 'package:influcollb_app/features/campaign/presentation/widgets/location_picker.dart';
import 'package:intl/intl.dart';

class EditCampaignScreen extends ConsumerStatefulWidget {
  final Campaign campaign;

  const EditCampaignScreen({super.key, required this.campaign});

  @override
  ConsumerState<EditCampaignScreen> createState() => _EditCampaignScreenState();
}

class _EditCampaignScreenState extends ConsumerState<EditCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _brandNameController;
  late TextEditingController _budgetMinController;
  late TextEditingController _budgetMaxController;
  late TextEditingController _locationController;
  
  late String _selectedCategory;
  late DateTime _selectedDeadline;
  late List<String> _requirements;
  late List<String> _deliverables;
  late String _selectedStatus;
  
  final _requirementController = TextEditingController();
  final _deliverableController = TextEditingController();

  final List<String> _categories = [
    'Fashion',
    'Beauty',
    'Fitness',
    'Technology',
    'Food',
    'Travel',
    'Lifestyle',
    'Gaming',
    'Education',
    'Other',
  ];

  final List<String> _statuses = ['active', 'draft', 'completed'];

  @override
  void initState() {
    super.initState();
    // Initialize with existing campaign data
    _titleController = TextEditingController(text: widget.campaign.title);
    _descriptionController = TextEditingController(text: widget.campaign.description);
    _brandNameController = TextEditingController(text: widget.campaign.brandName);
    _budgetMinController = TextEditingController(text: widget.campaign.budgetMin.toString());
    _budgetMaxController = TextEditingController(text: widget.campaign.budgetMax.toString());
    _locationController = TextEditingController(text: widget.campaign.location);
    _selectedCategory = widget.campaign.category;
    _selectedDeadline = widget.campaign.deadline;
    _requirements = List.from(widget.campaign.requirements);
    _deliverables = List.from(widget.campaign.deliverables);
    _selectedStatus = widget.campaign.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _brandNameController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _locationController.dispose();
    _requirementController.dispose();
    _deliverableController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(), // Do not allow previous dates
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _addRequirement() {
    if (_requirementController.text.isNotEmpty) {
      setState(() {
        _requirements.add(_requirementController.text);
        _requirementController.clear();
      });
    }
  }

  void _removeRequirement(int index) {
    setState(() {
      _requirements.removeAt(index);
    });
  }

  void _addDeliverable() {
    if (_deliverableController.text.isNotEmpty) {
      setState(() {
        _deliverables.add(_deliverableController.text);
        _deliverableController.clear();
      });
    }
  }

  void _removeDeliverable(int index) {
    setState(() {
      _deliverables.removeAt(index);
    });
  }

  Future<void> _updateCampaign() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_requirements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one requirement')),
      );
      return;
    }

    if (_deliverables.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one deliverable')),
      );
      return;
    }

    final campaignData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'brandName': _brandNameController.text,
      'category': _selectedCategory,
      'budgetMin': double.parse(_budgetMinController.text),
      'budgetMax': double.parse(_budgetMaxController.text),
      'deadline': _selectedDeadline.toIso8601String(),
      'location': _locationController.text,
      'requirements': _requirements,
      'deliverables': _deliverables,
      'status': _selectedStatus,
    };

    final success = await ref.read(campaignViewModelProvider.notifier)
        .updateCampaign(widget.campaign.id, campaignData);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaign updated successfully!')),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      final error = ref.read(campaignViewModelProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to update campaign')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campaignViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Campaign'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_selectedStatus),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _selectedStatus.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Campaign Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Brand Name
            TextFormField(
              controller: _brandNameController,
              decoration: const InputDecoration(
                labelText: 'Brand Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter brand name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Status
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              items: _statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Budget Range
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _budgetMinController,
                    decoration: const InputDecoration(
                      labelText: 'Min Budget (NPR)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      helperText: 'Min: 100',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return 'Invalid number';
                      }
                      if (amount < 100) {
                        return 'Min is 100';
                      }
                      if (amount > 1000000) {
                        return 'Max is 1M';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _budgetMaxController,
                    decoration: const InputDecoration(
                      labelText: 'Max Budget (NPR)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      helperText: 'Max: 1M',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null) {
                        return 'Invalid number';
                      }
                      if (amount < 100) {
                        return 'Min is 100';
                      }
                      if (amount > 1000000) {
                        return 'Max is 1M';
                      }
                      final min = double.tryParse(_budgetMinController.text);
                      if (min != null && amount < min) {
                        return 'Max < Min';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () async {
                    final location = await showDialog<String>(
                      context: context,
                      builder: (context) => const LocationPickerDialog(),
                    );
                    if (location != null) {
                      _locationController.text = location;
                    }
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Deadline
            InkWell(
              onTap: _selectDeadline,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('yyyy-MM-dd').format(_selectedDeadline),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Requirements Section
            const Text(
              'Requirements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _requirementController,
                    decoration: const InputDecoration(
                      hintText: 'Add requirement',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addRequirement,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._requirements.asMap().entries.map((entry) {
              return ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(entry.value),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeRequirement(entry.key),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Deliverables Section
            const Text(
              'Deliverables',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _deliverableController,
                    decoration: const InputDecoration(
                      hintText: 'Add deliverable',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addDeliverable,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._deliverables.asMap().entries.map((entry) {
              return ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(entry.value),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removeDeliverable(entry.key),
                ),
              );
            }),
            const SizedBox(height: 32),

            // Update Button
            ElevatedButton(
              onPressed: state.isUpdating ? null : _updateCampaign,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: state.isUpdating
                  ? const CircularProgressIndicator()
                  : const Text('Update Campaign', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campaign'),
        content: const Text('Are you sure you want to delete this campaign? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(campaignViewModelProvider.notifier)
          .deleteCampaign(widget.campaign.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign deleted successfully!')),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        final error = ref.read(campaignViewModelProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to delete campaign')),
        );
      }
    }
  }
}
