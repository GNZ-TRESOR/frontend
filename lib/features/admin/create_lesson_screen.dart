import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../core/models/education_lesson.dart';
import 'widgets/file_upload_widget.dart';

class CreateLessonScreen extends StatefulWidget {
  final VoidCallback onLessonCreated;

  const CreateLessonScreen({super.key, required this.onLessonCreated});

  @override
  State<CreateLessonScreen> createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  final _durationController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _audioUrlController = TextEditingController();

  EducationCategory _selectedCategory = EducationCategory.familyPlanning;
  EducationLevel _selectedLevel = EducationLevel.beginner;
  String _selectedLanguage = 'rw';
  bool _isPublished = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _durationController.dispose();
    _videoUrlController.dispose();
    _audioUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Lesson'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveLesson,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text(
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
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter lesson title',
                validator:
                    (value) =>
                        value?.isEmpty == true ? 'Title is required' : null,
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
                validator:
                    (value) =>
                        value?.isEmpty == true ? 'Content is required' : null,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Wide screen - use row layout
                    return Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<EducationCategory>(
                            label: 'Category',
                            value: _selectedCategory,
                            items: EducationCategory.values,
                            onChanged:
                                (value) =>
                                    setState(() => _selectedCategory = value!),
                            itemBuilder:
                                (category) => _formatCategoryName(category),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown<EducationLevel>(
                            label: 'Level',
                            value: _selectedLevel,
                            items: EducationLevel.values,
                            onChanged:
                                (value) =>
                                    setState(() => _selectedLevel = value!),
                            itemBuilder: (level) => _formatLevelName(level),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Narrow screen - use column layout
                    return Column(
                      children: [
                        _buildDropdown<EducationCategory>(
                          label: 'Category',
                          value: _selectedCategory,
                          items: EducationCategory.values,
                          onChanged:
                              (value) =>
                                  setState(() => _selectedCategory = value!),
                          itemBuilder:
                              (category) => _formatCategoryName(category),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown<EducationLevel>(
                          label: 'Level',
                          value: _selectedLevel,
                          items: EducationLevel.values,
                          onChanged:
                              (value) =>
                                  setState(() => _selectedLevel = value!),
                          itemBuilder: (level) => _formatLevelName(level),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Wide screen - use row layout
                    return Row(
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
                            hint: '15',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Narrow screen - use column layout
                    return Column(
                      children: [
                        _buildTextField(
                          controller: _authorController,
                          label: 'Author',
                          hint: 'Enter author name',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _durationController,
                          label: 'Duration (minutes)',
                          hint: '15',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _videoUrlController,
                label: 'Video URL (optional)',
                hint: 'https://example.com/video.mp4',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _audioUrlController,
                label: 'Audio URL (optional)',
                hint: 'https://example.com/audio.mp3',
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Wide screen - use row layout
                    return Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<String>(
                            label: 'Language',
                            value: _selectedLanguage,
                            items: const ['rw', 'en', 'fr'],
                            onChanged:
                                (value) =>
                                    setState(() => _selectedLanguage = value!),
                            itemBuilder:
                                (lang) =>
                                    {
                                      'rw': 'Kinyarwanda',
                                      'en': 'English',
                                      'fr': 'French',
                                    }[lang] ??
                                    lang,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Published'),
                            value: _isPublished,
                            onChanged:
                                (value) => setState(
                                  () => _isPublished = value ?? false,
                                ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Narrow screen - use column layout
                    return Column(
                      children: [
                        _buildDropdown<String>(
                          label: 'Language',
                          value: _selectedLanguage,
                          items: const ['rw', 'en', 'fr'],
                          onChanged:
                              (value) =>
                                  setState(() => _selectedLanguage = value!),
                          itemBuilder:
                              (lang) =>
                                  {
                                    'rw': 'Kinyarwanda',
                                    'en': 'English',
                                    'fr': 'French',
                                  }[lang] ??
                                  lang,
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: const Text('Published'),
                          value: _isPublished,
                          onChanged:
                              (value) =>
                                  setState(() => _isPublished = value ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // File Upload Section
              const Text(
                'Media Files',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Video Upload
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: FileUploadWidget(
                  uploadType: FileUploadType.video,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  onUploadSuccess: (response) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Video uploaded successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    // Store the video URL for the lesson
                    _videoUrlController.text = response['url'] ?? '';
                  },
                  onUploadError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Video upload failed: $error'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Document Upload
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: FileUploadWidget(
                  uploadType: FileUploadType.document,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  onUploadSuccess: (response) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Document uploaded successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  onUploadError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Document upload failed: $error'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Audio Upload
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: FileUploadWidget(
                  uploadType: FileUploadType.audio,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  onUploadSuccess: (response) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Audio uploaded successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    // Store the audio URL for the lesson
                    _audioUrlController.text = response['url'] ?? '';
                  },
                  onUploadError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Audio upload failed: $error'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Image Upload
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: FileUploadWidget(
                  uploadType: FileUploadType.image,
                  title: _titleController.text,
                  description: _descriptionController.text,
                  onUploadSuccess: (response) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Image uploaded successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  onUploadError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Image upload failed: $error'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(itemBuilder(item)),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final lessonData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _selectedCategory.name,
        'level': _selectedLevel.name,
        'author': _authorController.text.trim(),
        'durationMinutes': int.tryParse(_durationController.text) ?? 15,
        'videoUrl':
            _videoUrlController.text.trim().isEmpty
                ? null
                : _videoUrlController.text.trim(),
        'audioUrl':
            _audioUrlController.text.trim().isEmpty
                ? null
                : _audioUrlController.text.trim(),
        'language': _selectedLanguage,
        'isPublished': _isPublished,
      };

      final response = await ApiService.instance.createEducationLesson(
        lessonData,
      );

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lesson "${_titleController.text}" created successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          widget.onLessonCreated();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to create lesson'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatCategoryName(EducationCategory category) {
    switch (category) {
      case EducationCategory.familyPlanning:
        return 'Family Planning';
      case EducationCategory.contraception:
        return 'Contraception';
      case EducationCategory.pregnancy:
        return 'Pregnancy';
      case EducationCategory.menstrualHealth:
        return 'Menstrual Health';
      case EducationCategory.stiPrevention:
        return 'STI Prevention';
      case EducationCategory.reproductiveHealth:
        return 'Reproductive Health';
      case EducationCategory.maternalHealth:
        return 'Maternal Health';
      case EducationCategory.nutrition:
        return 'Nutrition';
      case EducationCategory.generalHealth:
        return 'General Health';
      case EducationCategory.mentalHealth:
        return 'Mental Health';
    }
  }

  String _formatLevelName(EducationLevel level) {
    switch (level) {
      case EducationLevel.beginner:
        return 'Beginner';
      case EducationLevel.intermediate:
        return 'Intermediate';
      case EducationLevel.advanced:
        return 'Advanced';
      case EducationLevel.expert:
        return 'Expert';
    }
  }
}
