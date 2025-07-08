class HealthRecord {
  final String id;
  final String userId;
  final String healthWorkerId;
  final DateTime recordDate;
  final String recordType;
  final HealthRecordType type;
  final Map<String, dynamic> data;
  final String? notes;
  final List<String> attachments;
  final bool isConfidential;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthRecord({
    required this.id,
    required this.userId,
    required this.healthWorkerId,
    required this.recordDate,
    required this.recordType,
    required this.type,
    required this.data,
    this.notes,
    this.attachments = const [],
    this.isConfidential = true,
    required this.createdAt,
    required this.updatedAt,
  });
}

class MenstrualCycle {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength;
  final int flowDuration;
  final FlowIntensity flowIntensity;
  final List<String> symptoms;
  final String? notes;
  final bool isPredicted;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenstrualCycle({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    required this.cycleLength,
    required this.flowDuration,
    required this.flowIntensity,
    this.symptoms = const [],
    this.notes,
    this.isPredicted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  DateTime get nextPeriodDate => startDate.add(Duration(days: cycleLength));
  DateTime get ovulationDate => startDate.add(Duration(days: cycleLength ~/ 2));
  DateTime get fertileWindowStart =>
      ovulationDate.subtract(const Duration(days: 5));
  DateTime get fertileWindowEnd => ovulationDate.add(const Duration(days: 1));
}

class Medication {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String prescribedBy;
  final String purpose;
  final String? instructions;
  final List<String> sideEffects;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.prescribedBy,
    required this.purpose,
    this.instructions,
    this.sideEffects = const [],
    this.isActive = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
}

class HealthWorker {
  final String id;
  final String name;
  final String specialization;
  final String facilityId;
  final String phone;
  final String email;
  final List<String> qualifications;
  final List<String> languages;
  final bool isAvailable;
  final bool isActive;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthWorker({
    required this.id,
    required this.name,
    required this.specialization,
    required this.facilityId,
    required this.phone,
    required this.email,
    this.qualifications = const [],
    this.languages = const [],
    this.isAvailable = true,
    this.isActive = true,
    this.rating = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });
}

class EducationContent {
  final String id;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final String language;
  final String? audioUrl;
  final String? videoUrl;
  final List<String> images;
  final int readingTime;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  EducationContent({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.tags = const [],
    required this.language,
    this.audioUrl,
    this.videoUrl,
    this.images = const [],
    required this.readingTime,
    this.isPublished = true,
    required this.createdAt,
    required this.updatedAt,
  });
}

class UserProgress {
  final String id;
  final String userId;
  final String contentId;
  final double progressPercentage;
  final DateTime lastAccessed;
  final bool isCompleted;
  final int timeSpent;
  final Map<String, dynamic> quizResults;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProgress({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.progressPercentage,
    required this.lastAccessed,
    this.isCompleted = false,
    this.timeSpent = 0,
    this.quizResults = const {},
    required this.createdAt,
    required this.updatedAt,
  });
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime sentAt;
  final DateTime? readAt;
  final bool isDelivered;
  final String? attachmentUrl;
  final MessagePriority priority;
  final String? replyToId;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.sentAt,
    this.readAt,
    this.isDelivered = false,
    this.attachmentUrl,
    this.priority = MessagePriority.normal,
    this.replyToId,
    required this.createdAt,
  });
}

// Enums
enum FlowIntensity { light, normal, heavy }

enum MessageType { text, voice, image, audio, video, document, location }

enum MessagePriority { low, normal, high, urgent }

enum HealthRecordType {
  consultation,
  vaccination,
  labResult,
  prescription,
  vitals,
  familyPlanning,
  pregnancy,
  menstrualCycle,
  contraception,
}
