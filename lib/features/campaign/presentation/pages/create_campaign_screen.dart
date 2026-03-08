import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/campaign/presentation/view_model/campaign_providers.dart';
import 'package:influcollb_app/features/campaign/presentation/widgets/location_picker.dart';
import 'package:intl/intl.dart';

class CreateCampaignScreen extends ConsumerStatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  ConsumerState<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends ConsumerState<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedCategory = 'Fashion';
  DateTime? _selectedDeadline;
  final List<String> _requirements = [];
  final List<String> _deliverables = [];
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
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
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

  Future<void> _submitCampaign() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a deadline'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate deadline is not in the past
    if (_selectedDeadline!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Campaign deadline cannot be in the past'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate budget range
    final minBudget = double.tryParse(_budgetMinController.text);
    final maxBudget = double.tryParse(_budgetMaxController.text);

    if (minBudget == null || maxBudget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid budget amounts'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (minBudget < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum budget must be at least NPR 100'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (maxBudget > 1000000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum budget cannot exceed NPR 1,000,000'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (minBudget > maxBudget) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum budget cannot be greater than maximum budget'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_requirements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one requirement'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_deliverables.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one deliverable'),
          backgroundColor: Colors.red,
        ),
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
      'deadline': _selectedDeadline?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'location': _locationController.text,
      'requirements': _requirements,
      'deliverables': _deliverables,
      'status': 'active',
    };

    final success = await ref.read(campaignViewModelProvider.notifier).createCampaign(campaignData);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaign created successfully!')),
      );
      Navigator.of(context).pop(true);
    } else if (mounted) {
      final error = ref.read(campaignViewModelProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to create campaign')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campaignViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Campaign'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                  _selectedDeadline == null
                      ? 'Select deadline'
                      : DateFormat('yyyy-MM-dd').format(_selectedDeadline!),
                  style: TextStyle(
                    color: _selectedDeadline == null ? Colors.grey : Colors.black,
                  ),
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

            // Submit Button
            ElevatedButton(
              onPressed: state.isCreating ? null : _submitCampaign,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: state.isCreating
                  ? const CircularProgressIndicator()
                  : const Text('Create Campaign', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
