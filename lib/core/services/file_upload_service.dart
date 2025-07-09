import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive file upload service for Ubuzima app
/// Handles image uploads, document uploads, and file management
class FileUploadService extends ChangeNotifier {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  // Configuration
  static const String baseUrl = 'http://localhost:8080';
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];
  static const List<String> allowedDocumentTypes = [
    'pdf',
    'doc',
    'docx',
    'txt',
  ];

  // Upload state
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _lastError;
  List<UploadedFile> _uploadedFiles = [];

  // Getters
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get lastError => _lastError;
  List<UploadedFile> get uploadedFiles => _uploadedFiles;

  /// Initialize file upload service
  Future<void> initialize() async {
    try {
      await _loadUploadedFiles();
      debugPrint('✅ File upload service initialized');
    } catch (e) {
      debugPrint('❌ File upload service initialization failed: $e');
    }
  }

  /// Upload profile image
  Future<String?> uploadProfileImage({
    required Uint8List imageBytes,
    required String fileName,
    String? userId,
  }) async {
    try {
      _setUploadState(true, 0.0, null);

      // Validate file
      if (!_isValidImageFile(fileName)) {
        throw Exception(
          'Invalid image file type. Allowed: ${allowedImageTypes.join(', ')}',
        );
      }

      if (imageBytes.length > maxFileSize) {
        throw Exception(
          'File size exceeds maximum limit of ${maxFileSize ~/ (1024 * 1024)}MB',
        );
      }

      // Create multipart request
      final uri = Uri.parse('$baseUrl/files/upload/profile-image');
      final request = http.MultipartRequest('POST', uri);

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes('file', imageBytes, filename: fileName),
      );

      // Add metadata
      if (userId != null) {
        request.fields['userId'] = userId;
      }
      request.fields['type'] = 'profile_image';
      request.fields['timestamp'] = DateTime.now().toIso8601String();

      // Add auth header
      final token = await _getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Send request with progress tracking
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final fileUrl = responseData['data']['url'] as String;

        // Save uploaded file info
        final uploadedFile = UploadedFile(
          id: responseData['data']['id'],
          fileName: fileName,
          fileUrl: fileUrl,
          fileType: FileType.image,
          uploadedAt: DateTime.now(),
          size: imageBytes.length,
        );

        _uploadedFiles.add(uploadedFile);
        await _saveUploadedFiles();

        _setUploadState(false, 1.0, null);
        debugPrint('✅ Profile image uploaded successfully: $fileUrl');
        return fileUrl;
      } else {
        throw Exception(
          'Upload failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _setUploadState(false, 0.0, e.toString());
      debugPrint('❌ Profile image upload failed: $e');
      return null;
    }
  }

  /// Upload health document
  Future<String?> uploadHealthDocument({
    required Uint8List documentBytes,
    required String fileName,
    required String documentType,
    String? userId,
    Map<String, String>? metadata,
  }) async {
    try {
      _setUploadState(true, 0.0, null);

      // Validate file
      if (!_isValidDocumentFile(fileName)) {
        throw Exception(
          'Invalid document file type. Allowed: ${allowedDocumentTypes.join(', ')}',
        );
      }

      if (documentBytes.length > maxFileSize) {
        throw Exception(
          'File size exceeds maximum limit of ${maxFileSize ~/ (1024 * 1024)}MB',
        );
      }

      // Create multipart request
      final uri = Uri.parse('$baseUrl/files/upload/health-document');
      final request = http.MultipartRequest('POST', uri);

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes('file', documentBytes, filename: fileName),
      );

      // Add fields
      if (userId != null) {
        request.fields['userId'] = userId;
      }
      request.fields['documentType'] = documentType;
      request.fields['type'] = 'health_document';
      request.fields['timestamp'] = DateTime.now().toIso8601String();

      // Add metadata
      if (metadata != null) {
        request.fields['metadata'] = json.encode(metadata);
      }

      // Add auth header
      final token = await _getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final fileUrl = responseData['data']['url'] as String;

        // Save uploaded file info
        final uploadedFile = UploadedFile(
          id: responseData['data']['id'],
          fileName: fileName,
          fileUrl: fileUrl,
          fileType: FileType.document,
          uploadedAt: DateTime.now(),
          size: documentBytes.length,
          metadata: metadata,
        );

        _uploadedFiles.add(uploadedFile);
        await _saveUploadedFiles();

        _setUploadState(false, 1.0, null);
        debugPrint('✅ Health document uploaded successfully: $fileUrl');
        return fileUrl;
      } else {
        throw Exception(
          'Upload failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      _setUploadState(false, 0.0, e.toString());
      debugPrint('❌ Health document upload failed: $e');
      return null;
    }
  }

  /// Upload multiple files
  Future<List<String>> uploadMultipleFiles({
    required List<FileUploadData> files,
    String? userId,
  }) async {
    final uploadedUrls = <String>[];

    try {
      _setUploadState(true, 0.0, null);

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final progress = (i / files.length);
        _setUploadState(true, progress, null);

        String? url;
        if (file.fileType == FileType.image) {
          url = await uploadProfileImage(
            imageBytes: file.bytes,
            fileName: file.fileName,
            userId: userId,
          );
        } else if (file.fileType == FileType.document) {
          url = await uploadHealthDocument(
            documentBytes: file.bytes,
            fileName: file.fileName,
            documentType: file.metadata?['documentType'] ?? 'general',
            userId: userId,
            metadata: file.metadata,
          );
        }

        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      _setUploadState(false, 1.0, null);
      debugPrint(
        '✅ Multiple files uploaded: ${uploadedUrls.length}/${files.length}',
      );
      return uploadedUrls;
    } catch (e) {
      _setUploadState(false, 0.0, e.toString());
      debugPrint('❌ Multiple files upload failed: $e');
      return uploadedUrls;
    }
  }

  /// Delete uploaded file
  Future<bool> deleteFile(String fileId) async {
    try {
      final uri = Uri.parse('$baseUrl/files/$fileId');
      final token = await _getAuthToken();

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Remove from local list
        _uploadedFiles.removeWhere((file) => file.id == fileId);
        await _saveUploadedFiles();

        debugPrint('✅ File deleted successfully: $fileId');
        notifyListeners();
        return true;
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ File deletion failed: $e');
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get file download URL
  Future<String?> getFileDownloadUrl(String fileId) async {
    try {
      final uri = Uri.parse('$baseUrl/files/$fileId/download-url');
      final token = await _getAuthToken();

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data']['downloadUrl'] as String;
      } else {
        throw Exception('Failed to get download URL: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Failed to get download URL: $e');
      return null;
    }
  }

  /// Validate image file
  bool _isValidImageFile(String fileName) {
    final extension = path
        .extension(fileName)
        .toLowerCase()
        .replaceFirst('.', '');
    return allowedImageTypes.contains(extension);
  }

  /// Validate document file
  bool _isValidDocumentFile(String fileName) {
    final extension = path
        .extension(fileName)
        .toLowerCase()
        .replaceFirst('.', '');
    return allowedDocumentTypes.contains(extension);
  }

  /// Set upload state
  void _setUploadState(bool isUploading, double progress, String? error) {
    _isUploading = isUploading;
    _uploadProgress = progress;
    _lastError = error;
    notifyListeners();
  }

  /// Get auth token
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      debugPrint('❌ Failed to get auth token: $e');
      return null;
    }
  }

  /// Save uploaded files to local storage
  Future<void> _saveUploadedFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filesJson = _uploadedFiles.map((f) => f.toJson()).toList();
      await prefs.setString('uploaded_files', json.encode(filesJson));
    } catch (e) {
      debugPrint('❌ Failed to save uploaded files: $e');
    }
  }

  /// Load uploaded files from local storage
  Future<void> _loadUploadedFiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filesString = prefs.getString('uploaded_files');

      if (filesString != null) {
        final List<dynamic> filesJson = json.decode(filesString);
        _uploadedFiles =
            filesJson.map((json) => UploadedFile.fromJson(json)).toList();
      }

      debugPrint('✅ Loaded ${_uploadedFiles.length} uploaded files');
    } catch (e) {
      debugPrint('❌ Failed to load uploaded files: $e');
    }
  }

  /// Clear all uploaded files
  Future<void> clearUploadedFiles() async {
    try {
      _uploadedFiles.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('uploaded_files');
      notifyListeners();
      debugPrint('✅ Uploaded files cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear uploaded files: $e');
    }
  }
}

/// File upload data model
class FileUploadData {
  final Uint8List bytes;
  final String fileName;
  final FileType fileType;
  final Map<String, String>? metadata;

  const FileUploadData({
    required this.bytes,
    required this.fileName,
    required this.fileType,
    this.metadata,
  });
}

/// Uploaded file model
class UploadedFile {
  final String id;
  final String fileName;
  final String fileUrl;
  final FileType fileType;
  final DateTime uploadedAt;
  final int size;
  final Map<String, String>? metadata;

  const UploadedFile({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.uploadedAt,
    required this.size,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType.name,
      'uploadedAt': uploadedAt.toIso8601String(),
      'size': size,
      'metadata': metadata,
    };
  }

  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      id: json['id'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      fileType: FileType.values.firstWhere(
        (e) => e.name == json['fileType'],
        orElse: () => FileType.document,
      ),
      uploadedAt: DateTime.parse(json['uploadedAt']),
      size: json['size'],
      metadata:
          json['metadata'] != null
              ? Map<String, String>.from(json['metadata'])
              : null,
    );
  }
}

/// File types
enum FileType { image, document, audio, video }
