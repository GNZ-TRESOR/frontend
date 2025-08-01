import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/file_upload_service.dart';
import '../../../core/services/api_service.dart';

enum FileUploadType { video, document, audio, image }

class FileUploadWidget extends StatefulWidget {
  final FileUploadType uploadType;
  final int? lessonId;
  final String? title;
  final String? description;
  final Function(Map<String, dynamic>)? onUploadSuccess;
  final Function(String)? onUploadError;

  const FileUploadWidget({
    super.key,
    required this.uploadType,
    this.lessonId,
    this.title,
    this.description,
    this.onUploadSuccess,
    this.onUploadError,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _selectedFileName;
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getIconForType(), color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                _getTitleForType(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_selectedFile == null) ...[
            _buildFileSelector(),
          ] else ...[
            _buildSelectedFileInfo(),
            const SizedBox(height: 16),
            _buildUploadButton(),
          ],

          if (_isUploading) ...[
            const SizedBox(height: 16),
            _buildProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildFileSelector() {
    return GestureDetector(
      onTap: _selectFile,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.primary.withValues(alpha: 0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to select ${_getFileTypeText()}',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getAllowedFormats(),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFileInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFileName ?? 'Unknown file',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_selectedFile != null)
                  Text(
                    _formatFileSize(_selectedFile!.lengthSync()),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearSelection,
            icon: Icon(Icons.close, color: Colors.grey.shade600, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _uploadFile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            _isUploading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  'Upload ${_getFileTypeText()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploading... ${(_uploadProgress * 100).toInt()}%',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _uploadProgress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ],
    );
  }

  Future<void> _selectFile() async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? pickedFile;

      // For now, we'll only support images and videos with image_picker
      // In a production app, you'd use a more comprehensive file picker
      switch (widget.uploadType) {
        case FileUploadType.image:
          pickedFile = await picker.pickImage(source: ImageSource.gallery);
          break;
        case FileUploadType.video:
          pickedFile = await picker.pickVideo(source: ImageSource.gallery);
          break;
        case FileUploadType.document:
        case FileUploadType.audio:
          // For documents and audio, show a message that it's coming soon
          if (widget.onUploadError != null) {
            widget.onUploadError!(
              '${_getFileTypeText()} upload coming soon. Currently only images and videos are supported.',
            );
          }
          return;
      }

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          _selectedFile = file;
          _selectedFileName = file.path.split('/').last;
        });
      }
    } catch (e) {
      if (widget.onUploadError != null) {
        widget.onUploadError!('Failed to select file: $e');
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
    });
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Simulate progress for now - in real implementation, you'd track actual upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _uploadProgress = i / 100;
        });
      }

      // Here you would call the actual API upload method
      final response = await _uploadToApi();

      if (widget.onUploadSuccess != null) {
        widget.onUploadSuccess!(response);
      }

      // Clear selection after successful upload
      _clearSelection();
    } catch (e) {
      if (widget.onUploadError != null) {
        widget.onUploadError!('Upload failed: $e');
      }
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Future<Map<String, dynamic>> _uploadToApi() async {
    if (_selectedFile == null) throw Exception('No file selected');

    final fileUploadService = FileUploadService(ApiService.instance);

    try {
      switch (widget.uploadType) {
        case FileUploadType.video:
          final result = await fileUploadService.uploadEducationVideo(
            file: _selectedFile!,
            lessonId: widget.lessonId,
            title: widget.title,
            description: widget.description,
            onProgress: (sent, total) {
              if (total > 0) {
                setState(() {
                  _uploadProgress = sent / total;
                });
              }
            },
          );
          if (result != null) {
            return result.toJson();
          }
          break;
        case FileUploadType.document:
          final result = await fileUploadService.uploadEducationDocument(
            file: _selectedFile!,
            lessonId: widget.lessonId,
            title: widget.title,
            description: widget.description,
            onProgress: (sent, total) {
              if (total > 0) {
                setState(() {
                  _uploadProgress = sent / total;
                });
              }
            },
          );
          if (result != null) {
            return result.toJson();
          }
          break;
        case FileUploadType.audio:
          final result = await fileUploadService.uploadEducationAudio(
            file: _selectedFile!,
            lessonId: widget.lessonId,
            title: widget.title,
            description: widget.description,
            onProgress: (sent, total) {
              if (total > 0) {
                setState(() {
                  _uploadProgress = sent / total;
                });
              }
            },
          );
          if (result != null) {
            return result.toJson();
          }
          break;
        case FileUploadType.image:
          final result = await fileUploadService.uploadEducationImage(
            file: _selectedFile!,
            lessonId: widget.lessonId,
            title: widget.title,
            description: widget.description,
            onProgress: (sent, total) {
              if (total > 0) {
                setState(() {
                  _uploadProgress = sent / total;
                });
              }
            },
          );
          if (result != null) {
            return result.toJson();
          }
          break;
      }
      throw Exception('Upload failed');
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  IconData _getIconForType() {
    switch (widget.uploadType) {
      case FileUploadType.video:
        return Icons.videocam;
      case FileUploadType.document:
        return Icons.description;
      case FileUploadType.audio:
        return Icons.audiotrack;
      case FileUploadType.image:
        return Icons.image;
    }
  }

  String _getTitleForType() {
    switch (widget.uploadType) {
      case FileUploadType.video:
        return 'Upload Video';
      case FileUploadType.document:
        return 'Upload Document';
      case FileUploadType.audio:
        return 'Upload Audio';
      case FileUploadType.image:
        return 'Upload Image';
    }
  }

  String _getFileTypeText() {
    switch (widget.uploadType) {
      case FileUploadType.video:
        return 'video';
      case FileUploadType.document:
        return 'document';
      case FileUploadType.audio:
        return 'audio';
      case FileUploadType.image:
        return 'image';
    }
  }

  List<String> _getAllowedExtensions() {
    switch (widget.uploadType) {
      case FileUploadType.video:
        return ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'];
      case FileUploadType.document:
        return ['pdf', 'doc', 'docx', 'txt'];
      case FileUploadType.audio:
        return ['mp3', 'wav', 'aac', 'ogg', 'm4a'];
      case FileUploadType.image:
        return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    }
  }

  String _getAllowedFormats() {
    return 'Allowed: ${_getAllowedExtensions().map((e) => e.toUpperCase()).join(', ')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
