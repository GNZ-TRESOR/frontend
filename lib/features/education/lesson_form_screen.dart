import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/education_lesson.dart';
import '../../core/providers/education_provider.dart';
import '../../core/theme/app_colors.dart';

/// Lesson Form Screen for creating and editing lessons (Admin)
class LessonFormScreen extends ConsumerStatefulWidget {
  final EducationLesson? lesson;
  final EducationLesson? duplicateFrom;

  const LessonFormScreen({super.key, this.lesson, this.duplicateFrom});

  @override
  ConsumerState<LessonFormScreen> createState() => _LessonFormScreenState();
}

class _LessonFormScreenState extends ConsumerState<LessonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _audioUrlController = TextEditingController();
  final _authorController = TextEditingController();
  final _durationController = TextEditingController();

  EducationCategory _selectedCategory = EducationCategory.generalHealth;
  EducationLevel _selectedLevel = EducationLevel.beginner;
  bool _isPublished = false;
  List<String> _tags = [];
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final lesson = widget.lesson ?? widget.duplicateFrom;
    if (lesson != null) {
      _titleController.text = lesson.title;
      _descriptionController.text = lesson.description ?? '';
      _contentController.text = lesson.content ?? '';
      _videoUrlController.text = lesson.videoUrl ?? '';
      _audioUrlController.text = lesson.audioUrl ?? '';
      _authorController.text = lesson.author ?? '';
      _durationController.text = lesson.durationMinutes?.toString() ?? '';
      _selectedCategory = lesson.category;
      _selectedLevel = lesson.level;
      _isPublished =
          widget.lesson?.isPublished ??
          false; // Don't copy publish status for duplicates
      _tags = List.from(lesson.tags);
      _imageUrls = List.from(lesson.imageUrls);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _videoUrlController.dispose();
    _audioUrlController.dispose();
    _authorController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.lesson != null;
    final isDuplicating = widget.duplicateFrom != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Lesson'
              : isDuplicating
              ? 'Duplicate Lesson'
              : 'Create Lesson',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _saveLesson,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter lesson title',
                required: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter lesson description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _contentController,
                label: 'Content',
                hint: 'Enter lesson content',
                maxLines: 8,
              ),
              const SizedBox(height: 24),

              // Category and Level Section
              _buildSectionHeader('Category & Level'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown<EducationCategory>(
                      label: 'Category',
                      value: _selectedCategory,
                      items: EducationCategory.values,
                      onChanged:
                          (value) => setState(() => _selectedCategory = value!),
                      itemBuilder: (category) => category.name,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown<EducationLevel>(
                      label: 'Level',
                      value: _selectedLevel,
                      items: EducationLevel.values,
                      onChanged:
                          (value) => setState(() => _selectedLevel = value!),
                      itemBuilder: (level) => level.name,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Media Section
              _buildSectionHeader('Media'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _videoUrlController,
                label: 'Video URL',
                hint: 'Enter video URL (optional)',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _audioUrlController,
                label: 'Audio URL',
                hint: 'Enter audio URL (optional)',
              ),
              const SizedBox(height: 24),

              // Additional Information Section
              _buildSectionHeader('Additional Information'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _authorController,
                      label: 'Author',
                      hint: 'Enter author name',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _durationController,
                      label: 'Duration (minutes)',
                      hint: 'Enter duration',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Publish Status
              SwitchListTile(
                title: const Text('Published'),
                subtitle: const Text('Make this lesson visible to users'),
                value: _isPublished,
                onChanged: (value) => setState(() => _isPublished = value),
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator:
          required
              ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
              : null,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemBuilder(item)),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final isEditing = widget.lesson != null;

    try {
      final lessonData = {
        'title': _titleController.text.trim(),
        'description':
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        'content':
            _contentController.text.trim().isEmpty
                ? null
                : _contentController.text.trim(),
        'category': _selectedCategory.name,
        'level': _selectedLevel.name,
        'author':
            _authorController.text.trim().isEmpty
                ? null
                : _authorController.text.trim(),
        'durationMinutes': int.tryParse(_durationController.text),
        'videoUrl':
            _videoUrlController.text.trim().isEmpty
                ? null
                : _videoUrlController.text.trim(),
        'audioUrl':
            _audioUrlController.text.trim().isEmpty
                ? null
                : _audioUrlController.text.trim(),
        'isPublished': _isPublished,
        'tags': _tags,
        'imageUrls': _imageUrls,
      };

      EducationLesson? result;
      if (isEditing) {
        result = await ref
            .read(educationProvider.notifier)
            .updateLesson(widget.lesson!.id!, lessonData);
      } else {
        result = await ref
            .read(educationProvider.notifier)
            .createLesson(lessonData);
      }

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Lesson updated successfully'
                  : 'Lesson created successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Failed to update lesson' : 'Failed to create lesson',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving lesson: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
