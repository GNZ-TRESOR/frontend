import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import 'http_client.dart';

/// File type enum
enum FileType {
  image('IMAGE'),
  document('DOCUMENT'),
  audio('AUDIO'),
  video('VIDEO'),
  other('OTHER');

  const FileType(this.value);
  final String value;

  static FileType fromValue(String value) {
    return FileType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => FileType.other,
    );
  }

  static FileType fromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
      case '.webp':
        return FileType.image;
      case '.pdf':
      case '.doc':
      case '.docx':
      case '.txt':
      case '.rtf':
        return FileType.document;
      case '.mp3':
      case '.wav':
      case '.aac':
      case '.ogg':
        return FileType.audio;
      case '.mp4':
      case '.avi':
      case '.mov':
      case '.wmv':
        return FileType.video;
      default:
        return FileType.other;
    }
  }

  String get displayName {
    switch (this) {
      case FileType.image:
        return 'Ishusho';
      case FileType.document:
        return 'Inyandiko';
      case FileType.audio:
        return 'Ijwi';
      case FileType.video:
        return 'Amashusho';
      case FileType.other:
        return 'Ikindi';
    }
  }
}

/// File upload model
class UploadedFile {
  final String id;
  final String originalName;
  final String fileName;
  final String fileUrl;
  final FileType fileType;
  final int fileSize;
  final String mimeType;
  final String uploadedBy;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UploadedFile({
    required this.id,
    required this.originalName,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedBy,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      id: json['id']?.toString() ?? '',
      originalName: json['originalName'] ?? '',
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileType: FileType.fromValue(json['fileType'] ?? 'OTHER'),
      fileSize: json['fileSize'] ?? 0,
      mimeType: json['mimeType'] ?? '',
      uploadedBy: json['uploadedBy']?.toString() ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalName': originalName,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType.value,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'uploadedBy': uploadedBy,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Get human readable file size
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get file extension
  String get fileExtension {
    return path.extension(originalName);
  }

  /// Check if file is an image
  bool get isImage => fileType == FileType.image;

  /// Check if file is a document
  bool get isDocument => fileType == FileType.document;

  /// Check if file is audio
  bool get isAudio => fileType == FileType.audio;

  /// Check if file is video
  bool get isVideo => fileType == FileType.video;
}

/// File upload progress callback
typedef UploadProgressCallback = void Function(int sent, int total);

/// Service for managing file uploads and downloads
class FileService {
  final HttpClient _httpClient = HttpClient();

  /// Upload a single file
  Future<UploadedFile?> uploadFile({
    required File file,
    String? category,
    Map<String, dynamic>? metadata,
    UploadProgressCallback? onProgress,
  }) async {
    try {
      final fileName = path.basename(file.path);
      final fileExtension = path.extension(fileName);
      final fileType = FileType.fromExtension(fileExtension);

      // Create multipart request
      final uri = Uri.parse('${AppConstants.baseUrl}/files/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: fileName,
      );
      request.files.add(multipartFile);

      // Add additional fields
      if (category != null) request.fields['category'] = category;
      if (metadata != null) request.fields['metadata'] = json.encode(metadata);
      request.fields['fileType'] = fileType.value;

      // Add authorization header
      final token = await _getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Send request with progress tracking
      final streamedResponse = await request.send();
      
      if (onProgress != null) {
        int sent = 0;
        streamedResponse.stream.listen(
          (chunk) {
            sent += chunk.length;
            onProgress(sent, fileLength);
          },
        );
      }

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(data, (data) => data);

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return UploadedFile.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  /// Upload multiple files
  Future<List<UploadedFile>> uploadMultipleFiles({
    required List<File> files,
    String? category,
    Map<String, dynamic>? metadata,
    UploadProgressCallback? onProgress,
  }) async {
    final uploadedFiles = <UploadedFile>[];
    
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final uploadedFile = await uploadFile(
        file: file,
        category: category,
        metadata: metadata,
        onProgress: onProgress != null
            ? (sent, total) => onProgress(
                (i * 100 + (sent * 100 / total)).round(),
                files.length * 100,
              )
            : null,
      );
      
      if (uploadedFile != null) {
        uploadedFiles.add(uploadedFile);
      }
    }
    
    return uploadedFiles;
  }

  /// Get file by ID
  Future<UploadedFile?> getFileById(String fileId) async {
    try {
      final response = await _httpClient.get('/files/$fileId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return UploadedFile.fromJson(apiResponse.data as Map<String, dynamic>);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching file: $e');
      return null;
    }
  }

  /// Get files by user
  Future<List<UploadedFile>> getUserFiles({
    String? userId,
    int page = 0,
    int limit = 20,
    FileType? fileType,
    String? category,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (userId != null) queryParams['userId'] = userId;
      if (fileType != null) queryParams['fileType'] = fileType.value;
      if (category != null) queryParams['category'] = category;

      final response = await _httpClient.get(
        '/files',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final filesData = apiResponse.data as Map<String, dynamic>;
          final filesList = filesData['files'] as List<dynamic>;
          
          return filesList
              .map((json) => UploadedFile.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching user files: $e');
      return [];
    }
  }

  /// Delete file
  Future<bool> deleteFile(String fileId) async {
    try {
      final response = await _httpClient.delete('/files/$fileId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );
        return apiResponse.isSuccess;
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  /// Download file
  Future<File?> downloadFile(String fileId, String savePath) async {
    try {
      final response = await _httpClient.get('/files/$fileId/download');

      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.data as List<int>);
        return file;
      }

      return null;
    } catch (e) {
      debugPrint('Error downloading file: $e');
      return null;
    }
  }

  /// Get file download URL
  Future<String?> getFileDownloadUrl(String fileId) async {
    try {
      final response = await _httpClient.get('/files/$fileId/download-url');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final urlData = apiResponse.data as Map<String, dynamic>;
          return urlData['downloadUrl'] as String?;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error getting file download URL: $e');
      return null;
    }
  }

  /// Search files
  Future<List<UploadedFile>> searchFiles(String query) async {
    try {
      final response = await _httpClient.get(
        '/files/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          final filesData = apiResponse.data as Map<String, dynamic>;
          final filesList = filesData['files'] as List<dynamic>;
          
          return filesList
              .map((json) => UploadedFile.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error searching files: $e');
      return [];
    }
  }

  /// Get file storage statistics
  Future<Map<String, dynamic>> getStorageStatistics(String userId) async {
    try {
      final response = await _httpClient.get('/files/statistics/$userId');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => data,
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return apiResponse.data as Map<String, dynamic>;
        }
      }

      return {};
    } catch (e) {
      debugPrint('Error fetching storage statistics: $e');
      return {};
    }
  }

  /// Helper method to get auth token
  Future<String?> _getAuthToken() async {
    // This should be implemented to get the current auth token
    // For now, return null (will be handled by HttpClient)
    return null;
  }

  /// Validate file before upload
  bool validateFile(File file, {int? maxSizeBytes, List<String>? allowedExtensions}) {
    // Check file size
    if (maxSizeBytes != null) {
      final fileSize = file.lengthSync();
      if (fileSize > maxSizeBytes) {
        debugPrint('File too large: $fileSize bytes > $maxSizeBytes bytes');
        return false;
      }
    }

    // Check file extension
    if (allowedExtensions != null) {
      final fileName = path.basename(file.path);
      final fileExtension = path.extension(fileName).toLowerCase();
      if (!allowedExtensions.contains(fileExtension)) {
        debugPrint('File extension not allowed: $fileExtension');
        return false;
      }
    }

    return true;
  }
}
