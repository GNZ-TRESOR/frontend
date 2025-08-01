// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileUploadResponse _$FileUploadResponseFromJson(Map<String, dynamic> json) =>
    FileUploadResponse(
      id: json['id'] as String,
      url: json['url'] as String,
      filename: json['filename'] as String,
      originalFilename: json['originalFilename'] as String,
      size: (json['size'] as num).toInt(),
      mimeType: json['mimeType'] as String?,
      fileType: json['fileType'] as String?,
      userId: json['userId'] as String?,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      downloadUrl: json['downloadUrl'] as String?,
    );

Map<String, dynamic> _$FileUploadResponseToJson(FileUploadResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'filename': instance.filename,
      'originalFilename': instance.originalFilename,
      'size': instance.size,
      'mimeType': instance.mimeType,
      'fileType': instance.fileType,
      'userId': instance.userId,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'downloadUrl': instance.downloadUrl,
    };
