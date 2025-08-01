import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../models/file_upload_response.dart';
import '../services/file_upload_service.dart';
import '../theme/app_colors.dart';

/// File Upload Widget Types
enum FileUploadType { any, image, video, audio, document }

/// File Upload Widget for selecting and uploading files
class FileUploadWidget extends StatefulWidget {
  final FileUploadType uploadType;
  final bool allowMultiple;
  final String? userId;
  final String? fileType;
  final Function(List<FileUploadResponse>)? onFilesUploaded;
  final Function(String)? onError;
  final String? title;
  final String? subtitle;
  final List<FileUploadResponse>? initialFiles;

  const FileUploadWidget({
    super.key,
    this.uploadType = FileUploadType.any,
    this.allowMultiple = false,
    this.userId,
    this.fileType,
    this.onFilesUploaded,
    this.onError,
    this.title,
    this.subtitle,
    this.initialFiles,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final List<FileUploadResponse> _uploadedFiles = [];
  final List<File> _selectedFiles = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialFiles != null) {
      _uploadedFiles.addAll(widget.initialFiles!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (widget.subtitle != null) ...[
          Text(
            widget.subtitle!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Upload Area
        _buildUploadArea(),
        
        // Upload Progress
        if (_isUploading) ...[
          const SizedBox(height: 12),
          _buildUploadProgress(),
        ],
        
        // Selected Files
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSelectedFiles(),
        ],
        
        // Uploaded Files
        if (_uploadedFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildUploadedFiles(),
        ],
      ],
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _isUploading ? null : _selectFiles,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
            color: _isUploading ? Colors.grey : AppColors.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: _isUploading 
              ? Colors.grey.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Icon(
              _getUploadIcon(),
              size: 48,
              color: _isUploading ? Colors.grey : AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              _isUploading ? 'Uploading...' : _getUploadText(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _isUploading ? Colors.grey : AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _getUploadSubtext(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _uploadProgress,
          backgroundColor: Colors.grey.withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          'Uploading... ${(_uploadProgress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Files:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ..._selectedFiles.map((file) => _buildFileItem(
          fileName: file.path.split('/').last,
          fileSize: file.lengthSync(),
          isSelected: true,
          onRemove: () {
            setState(() {
              _selectedFiles.remove(file);
            });
          },
        )),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadFiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Upload Files'),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: _isUploading ? null : () {
                setState(() {
                  _selectedFiles.clear();
                });
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadedFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uploaded Files:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ..._uploadedFiles.map((file) => _buildFileItem(
          fileName: file.originalFilename,
          fileSize: file.size,
          isUploaded: true,
          fileUrl: file.url,
          onRemove: () => _removeUploadedFile(file),
        )),
      ],
    );
  }

  Widget _buildFileItem({
    required String fileName,
    required int fileSize,
    bool isSelected = false,
    bool isUploaded = false,
    String? fileUrl,
    VoidCallback? onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUploaded ? AppColors.success.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUploaded ? AppColors.success : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.attach_file,
            color: isUploaded ? AppColors.success : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  FileUploadService.formatFileSize(fileSize),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.error,
            ),
        ],
      ),
    );
  }

  IconData _getUploadIcon() {
    switch (widget.uploadType) {
      case FileUploadType.image:
        return Icons.image;
      case FileUploadType.video:
        return Icons.videocam;
      case FileUploadType.audio:
        return Icons.audiotrack;
      case FileUploadType.document:
        return Icons.description;
      case FileUploadType.any:
      default:
        return Icons.cloud_upload;
    }
  }

  String _getUploadText() {
    if (widget.allowMultiple) {
      return 'Tap to select files';
    } else {
      return 'Tap to select a file';
    }
  }

  String _getUploadSubtext() {
    switch (widget.uploadType) {
      case FileUploadType.image:
        return 'Supported: JPG, PNG, GIF, WebP (max 10MB)';
      case FileUploadType.video:
        return 'Supported: MP4, AVI, MOV, WebM (max 50MB)';
      case FileUploadType.audio:
        return 'Supported: MP3, WAV, AAC, OGG (max 10MB)';
      case FileUploadType.document:
        return 'Supported: PDF, DOC, DOCX, TXT (max 10MB)';
      case FileUploadType.any:
      default:
        return 'All file types supported';
    }
  }

  Future<void> _selectFiles() async {
    try {
      if (widget.uploadType == FileUploadType.image) {
        await _selectImages();
      } else {
        await _selectOtherFiles();
      }
    } catch (e) {
      widget.onError?.call('Failed to select files: $e');
    }
  }

  Future<void> _selectImages() async {
    final ImagePicker picker = ImagePicker();
    
    if (widget.allowMultiple) {
      final List<XFile> images = await picker.pickMultipleImages();
      final files = images.map((image) => File(image.path)).toList();
      _addSelectedFiles(files);
    } else {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _addSelectedFiles([File(image.path)]);
      }
    }
  }

  Future<void> _selectOtherFiles() async {
    FileType fileType;
    List<String>? allowedExtensions;

    switch (widget.uploadType) {
      case FileUploadType.video:
        fileType = FileType.video;
        break;
      case FileUploadType.audio:
        fileType = FileType.audio;
        break;
      case FileUploadType.document:
        fileType = FileType.custom;
        allowedExtensions = ['pdf', 'doc', 'docx', 'txt', 'rtf'];
        break;
      case FileUploadType.any:
      default:
        fileType = FileType.any;
        break;
    }

    final result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowMultiple: widget.allowMultiple,
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      final files = result.files.map((file) => File(file.path!)).toList();
      _addSelectedFiles(files);
    }
  }

  void _addSelectedFiles(List<File> files) {
    final validFiles = <File>[];
    
    for (final file in files) {
      final fileTypeStr = FileUploadService.getFileTypeFromExtension(file.path);
      if (FileUploadService.validateEducationFile(file, fileTypeStr)) {
        validFiles.add(file);
      } else {
        widget.onError?.call('Invalid file: ${file.path.split('/').last}');
      }
    }

    setState(() {
      if (widget.allowMultiple) {
        _selectedFiles.addAll(validFiles);
      } else {
        _selectedFiles.clear();
        if (validFiles.isNotEmpty) {
          _selectedFiles.add(validFiles.first);
        }
      }
    });
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // TODO: Get FileUploadService instance
      // For now, simulate upload
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _uploadProgress = i / 100;
        });
      }

      // TODO: Implement actual upload
      final uploadedFiles = <FileUploadResponse>[];
      
      setState(() {
        _uploadedFiles.addAll(uploadedFiles);
        _selectedFiles.clear();
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      widget.onFilesUploaded?.call(uploadedFiles);
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      widget.onError?.call('Upload failed: $e');
    }
  }

  void _removeUploadedFile(FileUploadResponse file) {
    setState(() {
      _uploadedFiles.remove(file);
    });
    // TODO: Implement actual file deletion
  }
}
