import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/community_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/auto_translate_widget.dart';

class CreateSupportGroupForm extends ConsumerStatefulWidget {
  const CreateSupportGroupForm({super.key});

  @override
  ConsumerState<CreateSupportGroupForm> createState() =>
      _CreateSupportGroupFormState();
}

class _CreateSupportGroupFormState
    extends ConsumerState<CreateSupportGroupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _meetingLocationController = TextEditingController();
  final _meetingScheduleController = TextEditingController();
  final _maxMembersController = TextEditingController();

  String _selectedCategory = 'Mental Health';
  bool _isPrivate = false;
  bool _isActive = true;
  final List<String> _tags = [];
  final _tagController = TextEditingController();

  final List<String> _categories = [
    'Mental Health',
    'Chronic Conditions',
    'Pregnancy & Parenting',
    'Addiction Recovery',
    'Disability Support',
    'General Health',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contactInfoController.dispose();
    _meetingLocationController.dispose();
    _meetingScheduleController.dispose();
    _maxMembersController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                'Create Support Group'.at(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildCategoryField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildContactInfoField(),
                      const SizedBox(height: 16),
                      _buildMeetingFields(),
                      const SizedBox(height: 16),
                      _buildMaxMembersField(),
                      const SizedBox(height: 16),
                      _buildPrivacySwitch(),
                      const SizedBox(height: 16),
                      _buildActiveSwitch(),
                      const SizedBox(height: 16),
                      _buildTagsField(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Group Name *',
        hintText: 'Enter group name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter group name';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category *',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          _categories.map((category) {
            return DropdownMenuItem(value: category, child: category.at());
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Describe the purpose and goals of your group',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildContactInfoField() {
    return TextFormField(
      controller: _contactInfoController,
      decoration: InputDecoration(
        labelText: 'Contact Information',
        hintText: 'Email, phone, or other contact details',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildMeetingFields() {
    return Column(
      children: [
        TextFormField(
          controller: _meetingLocationController,
          decoration: InputDecoration(
            labelText: 'Meeting Location',
            hintText: 'Where does the group meet?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _meetingScheduleController,
          decoration: InputDecoration(
            labelText: 'Meeting Schedule',
            hintText: 'When does the group meet?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildMaxMembersField() {
    return TextFormField(
      controller: _maxMembersController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Maximum Members',
        hintText: 'Leave empty for unlimited',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final number = int.tryParse(value);
          if (number == null || number <= 0) {
            return 'Please enter a valid number';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPrivacySwitch() {
    return SwitchListTile(
      title: 'Private Group'.at(),
      subtitle: 'Only invited members can join'.at(),
      value: _isPrivate,
      onChanged: (value) {
        setState(() {
          _isPrivate = value;
        });
      },
      activeColor: AppColors.communityTeal,
    );
  }

  Widget _buildActiveSwitch() {
    return SwitchListTile(
      title: 'Active Group'.at(),
      subtitle: 'Group is currently accepting new members'.at(),
      value: _isActive,
      onChanged: (value) {
        setState(() {
          _isActive = value;
        });
      },
      activeColor: AppColors.communityTeal,
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        'Tags'.at(style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'Add a tag',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onFieldSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addTag(_tagController.text),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              _tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                  deleteIcon: const Icon(Icons.close, size: 16),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: 'Cancel'.at(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _createGroup,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.communityTeal,
              foregroundColor: Colors.white,
            ),
            child: 'Create Group'.at(),
          ),
        ),
      ],
    );
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
      setState(() {
        _tags.add(tag.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(currentUserProvider);
      if (user?.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: 'Error: User not authenticated'.at(),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        // Prepare data for API call
        final groupData = {
          'name': _nameController.text.trim(),
          'category': _selectedCategory,
          'description':
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          'contactInfo':
              _contactInfoController.text.trim().isEmpty
                  ? null
                  : _contactInfoController.text.trim(),
          'meetingLocation':
              _meetingLocationController.text.trim().isEmpty
                  ? null
                  : _meetingLocationController.text.trim(),
          'meetingSchedule':
              _meetingScheduleController.text.trim().isEmpty
                  ? null
                  : _meetingScheduleController.text.trim(),
          'maxMembers':
              _maxMembersController.text.trim().isEmpty
                  ? null
                  : int.tryParse(_maxMembersController.text.trim()),
          'isPrivate': _isPrivate,
          'isActive': _isActive,
          'creatorId': user!.id!,
          'tags': _tags.isEmpty ? null : _tags,
        };

        final response = await ApiService.instance.createSupportGroup(
          groupData,
        );

        if (response.success) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: 'Support group created successfully!'.at(),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Refresh the support groups list
          ref.read(supportGroupsProvider.notifier).loadSupportGroups();
        } else {
          throw Exception(response.message ?? 'Failed to create support group');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating support group: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
