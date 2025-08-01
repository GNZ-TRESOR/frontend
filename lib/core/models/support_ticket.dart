import 'package:json_annotation/json_annotation.dart';

part 'support_ticket.g.dart';

@JsonSerializable()
class SupportTicket {
  final int? id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? version;
  final String description;
  final TicketPriority? priority;
  final String? resolutionNotes;
  final DateTime? resolvedAt;
  final TicketStatus? status;
  final String subject;
  final TicketType ticketType;
  final String? userEmail;
  final String? userPhone;
  final int? assignedTo;
  final int? userId;

  const SupportTicket({
    this.id,
    required this.createdAt,
    this.updatedAt,
    this.version,
    required this.description,
    this.priority,
    this.resolutionNotes,
    this.resolvedAt,
    this.status,
    required this.subject,
    required this.ticketType,
    this.userEmail,
    this.userPhone,
    this.assignedTo,
    this.userId,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketFromJson(json);

  Map<String, dynamic> toJson() => _$SupportTicketToJson(this);

  SupportTicket copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    String? description,
    TicketPriority? priority,
    String? resolutionNotes,
    DateTime? resolvedAt,
    TicketStatus? status,
    String? subject,
    TicketType? ticketType,
    String? userEmail,
    String? userPhone,
    int? assignedTo,
    int? userId,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      status: status ?? this.status,
      subject: subject ?? this.subject,
      ticketType: ticketType ?? this.ticketType,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      assignedTo: assignedTo ?? this.assignedTo,
      userId: userId ?? this.userId,
    );
  }

  String get priorityDisplayName {
    switch (priority) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
      default:
        return 'Medium';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
      default:
        return 'Open';
    }
  }

  String get typeDisplayName {
    switch (ticketType) {
      case TicketType.technical:
        return 'Technical';
      case TicketType.medical:
        return 'Medical';
      case TicketType.account:
        return 'Account';
      case TicketType.feedback:
        return 'Feedback';
      case TicketType.complaint:
        return 'Complaint';
      case TicketType.suggestion:
        return 'Suggestion';
    }
  }
}

enum TicketPriority {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high,
  @JsonValue('URGENT')
  urgent,
}

enum TicketStatus {
  @JsonValue('OPEN')
  open,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('RESOLVED')
  resolved,
  @JsonValue('CLOSED')
  closed,
}

enum TicketType {
  @JsonValue('TECHNICAL')
  technical,
  @JsonValue('MEDICAL')
  medical,
  @JsonValue('ACCOUNT')
  account,
  @JsonValue('FEEDBACK')
  feedback,
  @JsonValue('COMPLAINT')
  complaint,
  @JsonValue('SUGGESTION')
  suggestion,
}
