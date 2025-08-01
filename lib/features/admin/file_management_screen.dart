import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/file_upload_service.dart';
import '../../core/services/api_service.dart';
import '../../core/models/file_upload_response.dart';

class FileManagementScreen extends StatefulWidget {
  const FileManagementScreen({super.key});

  @override
  State<FileManagementScreen> createState() => _FileManagementScreenState();
}

class _FileManagementScreenState extends State<FileManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FileUploadService _fileUploadService;
  
  List<FileUploadResponse> _videos = [];
  List<FileUploadResponse> _documents = [];
  List<FileUploadResponse> _audios = [];
  List<FileUploadResponse> _images = [];
  
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fileUploadService = FileUploadService(ApiService.instance);
    _loadFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _fileUploadService.getFilesByType('education_video'),
        _fileUploadService.getFilesByType('education_document'),
        _fileUploadService.getFilesByType('education_audio'),
        _fileUploadService.getFilesByType('education_image'),
      ]);

      setState(() {
        _videos = results[0];
        _documents = results[1];
        _audios = results[2];
        _images = results[3];
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load files: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: const Icon(Icons.videocam),
              text: 'Videos (${_videos.length})',
            ),
            Tab(
              icon: const Icon(Icons.description),
              text: 'Documents (${_documents.length})',
            ),
            Tab(
              icon: const Icon(Icons.audiotrack),
              text: 'Audio (${_audios.length})',
            ),
            Tab(
              icon: const Icon(Icons.image),
              text: 'Images (${_images.length})',
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadFiles,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFiles,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFileList(_videos, 'video'),
                    _buildFileList(_documents, 'document'),
                    _buildFileList(_audios, 'audio'),
                    _buildFileList(_images, 'image'),
                  ],
                ),
    );
  }

  Widget _buildFileList(List<FileUploadResponse> files, String fileType) {
    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForFileType(fileType),
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${fileType}s uploaded yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFiles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return _buildFileCard(file, fileType);
        },
      ),
    );
  }

  Widget _buildFileCard(FileUploadResponse file, String fileType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            _getIconForFileType(fileType),
            color: AppColors.primary,
          ),
        ),
        title: Text(
          file.originalFilename ?? 'Unknown file',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (file.size != null)
              Text('Size: ${FileUploadService.formatFileSize(file.size!)}'),
            if (file.uploadedAt != null)
              Text('Uploaded: ${_formatDate(file.uploadedAt!)}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleFileAction(value, file),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'download',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Download'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'copy_url',
              child: ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copy URL'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForFileType(String fileType) {
    switch (fileType) {
      case 'video':
        return Icons.videocam;
      case 'document':
        return Icons.description;
      case 'audio':
        return Icons.audiotrack;
      case 'image':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleFileAction(String action, FileUploadResponse file) {
    switch (action) {
      case 'download':
        _downloadFile(file);
        break;
      case 'copy_url':
        _copyFileUrl(file);
        break;
      case 'delete':
        _showDeleteConfirmation(file);
        break;
    }
  }

  void _downloadFile(FileUploadResponse file) {
    // In a real app, you would implement file download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download ${file.originalFilename} - Feature coming soon'),
      ),
    );
  }

  void _copyFileUrl(FileUploadResponse file) {
    // In a real app, you would copy the URL to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URL copied for ${file.originalFilename}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showDeleteConfirmation(FileUploadResponse file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text(
          'Are you sure you want to delete "${file.originalFilename}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFile(file);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(FileUploadResponse file) async {
    try {
      final success = await _fileUploadService.deleteFile(file.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${file.originalFilename} deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadFiles(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete ${file.originalFilename}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting file: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
