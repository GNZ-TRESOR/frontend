import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/file_upload_response.dart';
import '../config/app_config.dart';
import 'api_service.dart';

/// File Upload Service for handling file uploads to the backend
class FileUploadService {
  final ApiService _apiService;

  FileUploadService(this._apiService);

  /// Upload a single file
  Future<FileUploadResponse?> uploadFile({
    required File file,
    String? userId,
    String? fileType,
    Function(int, int)? onProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        if (userId != null) 'userId': userId,
        if (fileType != null) 'type': fileType,
      });

      final response = await _apiService.dio.post(
        '/files/upload',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return FileUploadResponse.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('File upload error: $e');
      rethrow;
    }
  }

  /// Upload multiple files
  Future<List<FileUploadResponse>> uploadMultipleFiles({
    required List<File> files,
    String? userId,
    String? fileType,
    Function(int, int)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'files': await Future.wait(
          files.map((file) async {
            final fileName = file.path.split('/').last;
            return MultipartFile.fromFile(file.path, filename: fileName);
          }),
        ),
        if (userId != null) 'userId': userId,
        if (fileType != null) 'type': fileType,
      });

      final response = await _apiService.dio.post(
        '/files/upload-multiple',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'];
        return dataList
            .map((item) => FileUploadResponse.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Multiple file upload error: $e');
      rethrow;
    }
  }

  /// Upload profile image
  Future<FileUploadResponse?> uploadProfileImage({
    required File file,
    String? userId,
    Function(int, int)? onProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        if (userId != null) 'userId': userId,
      });

      final response = await _apiService.dio.post(
        '/files/upload/profile-image',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return FileUploadResponse.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Profile image upload error: $e');
      rethrow;
    }
  }

  /// Upload health document
  Future<FileUploadResponse?> uploadHealthDocument({
    required File file,
    String? userId,
    String? documentType,
    String? metadata,
    Function(int, int)? onProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        if (userId != null) 'userId': userId,
        if (documentType != null) 'documentType': documentType,
        if (metadata != null) 'metadata': metadata,
      });

      final response = await _apiService.dio.post(
        '/files/upload/health-document',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return FileUploadResponse.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Health document upload error: $e');
      rethrow;
    }
  }

  /// Get user files
  Future<List<FileUploadResponse>> getUserFiles(String userId) async {
    try {
      final response = await _apiService.dio.get('/files/user/$userId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'];
        return dataList
            .map((item) => FileUploadResponse.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get user files error: $e');
      rethrow;
    }
  }

  /// Delete file
  Future<bool> deleteFile(String fileId) async {
    try {
      final response = await _apiService.dio.delete('/files/$fileId');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      debugPrint('Delete file error: $e');
      return false;
    }
  }

  /// Get file download URL
  String getDownloadUrl(String fileId) {
    return '${AppConfig.baseUrl}/files/download/$fileId';
  }

  // Education-specific upload methods

  /// Upload education video
  Future<FileUploadResponse?> uploadEducationVideo({
    required File file,
    String? userId,
    int? lessonId,
    String? title,
    String? description,
    Function(int, int)? onProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        if (userId != null) 'userId': userId,
        if (lessonId != null) 'lessonId': lessonId.toString(),
        if (title != null) 'title': title,
        if (description != null) 'description': description,
      });

      final response = await _apiService.dio.post(
        '/files/upload/education/video',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return FileUploadResponse.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Education video upload error: $e');
      rethrow;
    }
  }

  /// Upload education document
  Future<FileUploadResponse?> uploadEducationDocument({
    required File file,
    String? userId,
    int? lessonId,
    String? title,
    String? description,
    Function(int, int)? onProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        if (userId != null) 'userId': userId,
        if (lessonId != null) 'lessonId': lessonId.toString(),
        if (title != null) 'title': title,
        if (description != null) 'description': description,
      });

      final response = await _apiService.dio.post(
        '/files/upload/education/document',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return FileUploadResponse.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Education document upload error: $e');
      rethrow;
    }
  }

  /// Upload education audio
  Future<FileUploadResponse?> uploadEducationAudio({
    required File file,
    String? userId,
    int? lessonId,
    String? title,
    String? description,
    Function(int, int)? onProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        if (userId != null) 'userId': userId,
        if (lessonId != null) 'lessonId': lessonId.toString(),
        if (title != null) 'title': title,
        if (description != null) 'description': description,
      });

      final response = await _apiService.dio.post(
        '/files/upload/education/audio',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return FileUploadResponse.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Education audio upload error: $e');
      rethrow;
    }
  }

  /// Upload education image
  Future<FileUploadResponse?> uploadEducationImage({
    required File file,
    String? userId,
    int? lessonId,
    String? title,
    String? description,
    Function(int, int)? onProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        if (userId != null) 'userId': userId,
        if (lessonId != null) 'lessonId': lessonId.toString(),
        if (title != null) 'title': title,
        if (description != null) 'description': description,
      });

      final response = await _apiService.dio.post(
        '/files/upload/education/image',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return FileUploadResponse.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Education image upload error: $e');
      rethrow;
    }
  }

  /// Get lesson files
  Future<List<FileUploadResponse>> getLessonFiles(int lessonId) async {
    try {
      final response = await _apiService.dio.get(
        '/files/education/lesson/$lessonId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'];
        return dataList
            .map((item) => FileUploadResponse.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get lesson files error: $e');
      rethrow;
    }
  }

  /// Get files by type
  Future<List<FileUploadResponse>> getFilesByType(String fileType) async {
    try {
      final response = await _apiService.dio.get(
        '/files/education/type/$fileType',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'];
        return dataList
            .map((item) => FileUploadResponse.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Get files by type error: $e');
      rethrow;
    }
  }

  /// Validate file for education content
  static bool validateEducationFile(File file, String fileType) {
    final fileName = file.path.toLowerCase();
    final fileSize = file.lengthSync();

    // Check file size (max 50MB for videos, 10MB for others)
    final maxSize = fileType == 'video' ? 50 * 1024 * 1024 : 10 * 1024 * 1024;
    if (fileSize > maxSize) {
      return false;
    }

    // Check file extensions
    switch (fileType) {
      case 'video':
        return fileName.endsWith('.mp4') ||
            fileName.endsWith('.avi') ||
            fileName.endsWith('.mov') ||
            fileName.endsWith('.wmv') ||
            fileName.endsWith('.webm');
      case 'audio':
        return fileName.endsWith('.mp3') ||
            fileName.endsWith('.wav') ||
            fileName.endsWith('.aac') ||
            fileName.endsWith('.ogg') ||
            fileName.endsWith('.m4a');
      case 'image':
        return fileName.endsWith('.jpg') ||
            fileName.endsWith('.jpeg') ||
            fileName.endsWith('.png') ||
            fileName.endsWith('.gif') ||
            fileName.endsWith('.webp');
      case 'document':
        return fileName.endsWith('.pdf') ||
            fileName.endsWith('.doc') ||
            fileName.endsWith('.docx') ||
            fileName.endsWith('.txt') ||
            fileName.endsWith('.rtf');
      default:
        return true;
    }
  }

  /// Get file type from extension
  static String getFileTypeFromExtension(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'webm':
        return 'video';
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'ogg':
      case 'm4a':
        return 'audio';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
      case 'rtf':
        return 'document';
      default:
        return 'general';
    }
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
