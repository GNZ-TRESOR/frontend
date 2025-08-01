import 'package:json_annotation/json_annotation.dart';

part 'file_upload_response.g.dart';

@JsonSerializable()
class FileUploadResponse {
  final String id;
  final String url;
  final String filename;
  final String originalFilename;
  final int size;
  final String? mimeType;
  final String? fileType;
  final String? userId;
  final DateTime uploadedAt;
  final String? downloadUrl;

  const FileUploadResponse({
    required this.id,
    required this.url,
    required this.filename,
    required this.originalFilename,
    required this.size,
    this.mimeType,
    this.fileType,
    this.userId,
    required this.uploadedAt,
    this.downloadUrl,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$FileUploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FileUploadResponseToJson(this);

  /// Get file extension
  String get fileExtension {
    return originalFilename.split('.').last.toLowerCase();
  }

  /// Check if file is an image
  bool get isImage {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    return imageExtensions.contains(fileExtension);
  }

  /// Check if file is a video
  bool get isVideo {
    const videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'webm'];
    return videoExtensions.contains(fileExtension);
  }

  /// Check if file is audio
  bool get isAudio {
    const audioExtensions = ['mp3', 'wav', 'aac', 'ogg', 'm4a'];
    return audioExtensions.contains(fileExtension);
  }

  /// Check if file is a document
  bool get isDocument {
    const documentExtensions = ['pdf', 'doc', 'docx', 'txt', 'rtf'];
    return documentExtensions.contains(fileExtension);
  }

  /// Get formatted file size
  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Get file type display name
  String get fileTypeDisplayName {
    if (isImage) return 'Image';
    if (isVideo) return 'Video';
    if (isAudio) return 'Audio';
    if (isDocument) return 'Document';
    return 'File';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileUploadResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FileUploadResponse{id: $id, filename: $filename, size: $size}';
  }
}
