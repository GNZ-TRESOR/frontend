import 'package:flutter/material.dart';

class ContraceptionMethod {
  final String id;
  final ContraceptionType type;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final double effectiveness;
  final List<String> sideEffects;
  final String instructions;
  final DateTime? nextAppointment;
  final bool isActive;
  final String? prescribedBy;
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContraceptionMethod({
    required this.id,
    required this.type,
    required this.name,
    this.description = '',
    required this.startDate,
    this.endDate,
    required this.effectiveness,
    this.sideEffects = const [],
    required this.instructions,
    this.nextAppointment,
    this.isActive = true,
    this.prescribedBy,
    this.additionalData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContraceptionMethod.fromJson(Map<String, dynamic> json) {
    return ContraceptionMethod(
      id: json['id'] as String,
      type: ContraceptionType.values.firstWhere(
        (e) => e.toString() == 'ContraceptionType.${json['type']}',
      ),
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] != null
              ? DateTime.parse(json['endDate'] as String)
              : null,
      effectiveness: (json['effectiveness'] as num).toDouble(),
      sideEffects:
          (json['sideEffects'] as List<dynamic>?)?.cast<String>() ?? [],
      instructions: json['instructions'] as String,
      nextAppointment:
          json['nextAppointment'] != null
              ? DateTime.parse(json['nextAppointment'] as String)
              : null,
      isActive: json['isActive'] as bool? ?? true,
      prescribedBy: json['prescribedBy'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'effectiveness': effectiveness,
      'sideEffects': sideEffects,
      'instructions': instructions,
      'nextAppointment': nextAppointment?.toIso8601String(),
      'isActive': isActive,
      'prescribedBy': prescribedBy,
      'additionalData': additionalData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ContraceptionReminder {
  final String id;
  final String methodId;
  final ReminderType type;
  final TimeOfDay? time;
  final DateTime? scheduledDate;
  final String message;
  final bool isActive;
  final List<int> daysOfWeek;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContraceptionReminder({
    required this.id,
    required this.methodId,
    required this.type,
    this.time,
    this.scheduledDate,
    required this.message,
    this.isActive = true,
    this.daysOfWeek = const [],
    required this.createdAt,
    required this.updatedAt,
  });
}

class ContraceptionHistory {
  final String id;
  final ContraceptionType methodType;
  final String methodName;
  final DateTime startDate;
  final DateTime? endDate;
  final String reason;
  final double effectiveness;
  final List<String> sideEffectsExperienced;
  final int satisfaction; // 1-5 rating
  final String? notes;
  final String? discontinuationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContraceptionHistory({
    required this.id,
    required this.methodType,
    required this.methodName,
    required this.startDate,
    this.endDate,
    required this.reason,
    required this.effectiveness,
    this.sideEffectsExperienced = const [],
    this.satisfaction = 3,
    this.notes,
    this.discontinuationReason,
    required this.createdAt,
    required this.updatedAt,
  });
}

class FertilityWindow {
  final String id;
  final String userId;
  final DateTime cycleStartDate;
  final DateTime ovulationDate;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
  final double probability;
  final FertilityStatus status;
  final DateTime createdAt;

  FertilityWindow({
    required this.id,
    required this.userId,
    required this.cycleStartDate,
    required this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.probability,
    required this.status,
    required this.createdAt,
  });
}

class PregnancyPlan {
  final String id;
  final String userId;
  final DateTime targetConceptionDate;
  final DateTime? actualConceptionDate;
  final PregnancyPlanStatus status;
  final List<String> preparationSteps;
  final Map<String, bool> healthChecks;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PregnancyPlan({
    required this.id,
    required this.userId,
    required this.targetConceptionDate,
    this.actualConceptionDate,
    required this.status,
    this.preparationSteps = const [],
    this.healthChecks = const {},
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
}

class PartnerInvolvement {
  final String id;
  final String userId;
  final String partnerName;
  final String? partnerPhone;
  final String? partnerEmail;
  final bool isInvolved;
  final List<String> sharedDecisions;
  final ContraceptionConsent consent;
  final DateTime createdAt;
  final DateTime updatedAt;

  PartnerInvolvement({
    required this.id,
    required this.userId,
    required this.partnerName,
    this.partnerPhone,
    this.partnerEmail,
    this.isInvolved = false,
    this.sharedDecisions = const [],
    required this.consent,
    required this.createdAt,
    required this.updatedAt,
  });
}

class STIPreventionRecord {
  final String id;
  final String userId;
  final DateTime testDate;
  final STITestType testType;
  final STITestResult result;
  final List<String> testedFor;
  final String? notes;
  final DateTime? nextTestDate;
  final bool isConfidential;
  final DateTime createdAt;
  final DateTime updatedAt;

  STIPreventionRecord({
    required this.id,
    required this.userId,
    required this.testDate,
    required this.testType,
    required this.result,
    this.testedFor = const [],
    this.notes,
    this.nextTestDate,
    this.isConfidential = true,
    required this.createdAt,
    required this.updatedAt,
  });
}

class EmergencyContraception {
  final String id;
  final String userId;
  final DateTime incidentDate;
  final EmergencyContraceptiveType type;
  final DateTime takenDate;
  final String? reason;
  final bool wasEffective;
  final List<String> sideEffects;
  final String? notes;
  final DateTime createdAt;

  EmergencyContraception({
    required this.id,
    required this.userId,
    required this.incidentDate,
    required this.type,
    required this.takenDate,
    this.reason,
    this.wasEffective = true,
    this.sideEffects = const [],
    this.notes,
    required this.createdAt,
  });
}

// Enums
enum ContraceptionType {
  pill,
  iud,
  implant,
  injection,
  patch,
  ring,
  condom,
  diaphragm,
  spermicide,
  naturalFamilyPlanning,
  sterilization,
  emergency,
}

enum ReminderType {
  dailyPill,
  weeklyPatch,
  monthlyRing,
  quarterlyInjection,
  appointment,
  refill,
  sideEffectCheck,
}

enum FertilityStatus { fertile, notFertile, ovulating, unknown }

enum PregnancyPlanStatus { planning, trying, conceived, postponed, cancelled }

enum ContraceptionConsent { fullConsent, partialConsent, noConsent, unknown }

enum STITestType {
  routine,
  symptomatic,
  partnerNotification,
  preConception,
  postExposure,
}

enum STITestResult { negative, positive, pending, inconclusive }

enum EmergencyContraceptiveType { planB, ella, copperIUD, other }

// Helper extensions
extension ContraceptionTypeExtension on ContraceptionType {
  String get displayName {
    switch (this) {
      case ContraceptionType.pill:
        return 'Imiti y\'kurinda inda';
      case ContraceptionType.iud:
        return 'IUD';
      case ContraceptionType.implant:
        return 'Implant';
      case ContraceptionType.injection:
        return 'Urushinge';
      case ContraceptionType.patch:
        return 'Patch';
      case ContraceptionType.ring:
        return 'Ring';
      case ContraceptionType.condom:
        return 'Condom';
      case ContraceptionType.diaphragm:
        return 'Diaphragm';
      case ContraceptionType.spermicide:
        return 'Spermicide';
      case ContraceptionType.naturalFamilyPlanning:
        return 'Gahunda y\'umuryango kamere';
      case ContraceptionType.sterilization:
        return 'Guca';
      case ContraceptionType.emergency:
        return 'Kurinda inda mu ihutirwa';
    }
  }

  String get description {
    switch (this) {
      case ContraceptionType.pill:
        return 'Imiti ifatwa buri munsi kugira ngo irinde inda';
      case ContraceptionType.iud:
        return 'Igikoresho gishyirwa mu nyababyeyi kugira ngo kirinde inda';
      case ContraceptionType.implant:
        return 'Igikoresho gishyirwa mu ukuboko kugira ngo kirinde inda';
      case ContraceptionType.injection:
        return 'Urushinge ruterwa buri mezi atatu kugira ngo rurinde inda';
      case ContraceptionType.patch:
        return 'Patch ishyirwa ku ruhu kugira ngo irinde inda';
      case ContraceptionType.ring:
        return 'Ring ishyirwa mu nyababyeyi kugira ngo irinde inda';
      case ContraceptionType.condom:
        return 'Igikoresho gikoresha mu gihe cy\'imibonano kugira ngo kirinde inda';
      case ContraceptionType.diaphragm:
        return 'Igikoresho gishyirwa mu nyababyeyi mbere y\'imibonano';
      case ContraceptionType.spermicide:
        return 'Imiti ikoresha hamwe n\'ubundi buryo bwo kurinda inda';
      case ContraceptionType.naturalFamilyPlanning:
        return 'Gukoresha ubumenyi bw\'umubiri kugira ngo urinde inda';
      case ContraceptionType.sterilization:
        return 'Ubuvuzi burangiza ubushobozi bwo kubyara';
      case ContraceptionType.emergency:
        return 'Imiti ikoresha nyuma y\'imibonano kugira ngo irinde inda';
    }
  }

  double get typicalEffectiveness {
    switch (this) {
      case ContraceptionType.pill:
        return 91.0;
      case ContraceptionType.iud:
        return 99.2;
      case ContraceptionType.implant:
        return 99.95;
      case ContraceptionType.injection:
        return 94.0;
      case ContraceptionType.patch:
        return 91.0;
      case ContraceptionType.ring:
        return 91.0;
      case ContraceptionType.condom:
        return 82.0;
      case ContraceptionType.diaphragm:
        return 88.0;
      case ContraceptionType.spermicide:
        return 72.0;
      case ContraceptionType.naturalFamilyPlanning:
        return 76.0;
      case ContraceptionType.sterilization:
        return 99.85;
      case ContraceptionType.emergency:
        return 89.0;
    }
  }
}
