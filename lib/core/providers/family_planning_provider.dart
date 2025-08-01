import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pregnancy_plan.dart';
import '../models/partner_invitation.dart';
import '../models/partner_decision.dart';
import '../services/api_service.dart';
import '../utils/family_planning_access_control.dart';
import 'auth_provider.dart';

/// Family Planning State
class FamilyPlanningState {
  final List<PregnancyPlan> pregnancyPlans;
  final List<PartnerInvitation> partnerInvitations;
  final List<PartnerDecision> partnerDecisions;
  final bool isLoading;
  final String? error;

  const FamilyPlanningState({
    this.pregnancyPlans = const [],
    this.partnerInvitations = const [],
    this.partnerDecisions = const [],
    this.isLoading = false,
    this.error,
  });

  FamilyPlanningState copyWith({
    List<PregnancyPlan>? pregnancyPlans,
    List<PartnerInvitation>? partnerInvitations,
    List<PartnerDecision>? partnerDecisions,
    bool? isLoading,
    String? error,
  }) {
    return FamilyPlanningState(
      pregnancyPlans: pregnancyPlans ?? this.pregnancyPlans,
      partnerInvitations: partnerInvitations ?? this.partnerInvitations,
      partnerDecisions: partnerDecisions ?? this.partnerDecisions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Family Planning Provider
class FamilyPlanningNotifier extends StateNotifier<FamilyPlanningState> {
  final ApiService _apiService;
  final Ref _ref;

  FamilyPlanningNotifier(this._apiService, this._ref)
    : super(const FamilyPlanningState());

  /// Load all family planning data
  Future<void> loadFamilyPlanningData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load pregnancy plans
      final pregnancyPlansResponse = await _apiService.getPregnancyPlans();
      List<PregnancyPlan> pregnancyPlans = [];

      if (pregnancyPlansResponse.success &&
          pregnancyPlansResponse.data != null) {
        final data = pregnancyPlansResponse.data as Map<String, dynamic>;
        if (data.containsKey('pregnancyPlans') &&
            data['pregnancyPlans'] is List) {
          final plansList = data['pregnancyPlans'] as List;
          pregnancyPlans =
              plansList
                  .map(
                    (json) =>
                        PregnancyPlan.fromJson(json as Map<String, dynamic>),
                  )
                  .toList();
        }
      }

      // Load partner invitations
      final invitationsResponse = await _apiService.getPartnerInvitations();
      List<PartnerInvitation> partnerInvitations = [];

      if (invitationsResponse.success && invitationsResponse.data != null) {
        final data = invitationsResponse.data as Map<String, dynamic>;
        if (data.containsKey('invitations') && data['invitations'] is List) {
          final invitationsList = data['invitations'] as List;
          partnerInvitations =
              invitationsList
                  .map(
                    (json) => PartnerInvitation.fromJson(
                      json as Map<String, dynamic>,
                    ),
                  )
                  .toList();
        }
      }

      // Load partner decisions
      final decisionsResponse = await _apiService.getPartnerDecisions();
      List<PartnerDecision> partnerDecisions = [];

      if (decisionsResponse.success && decisionsResponse.data != null) {
        final data = decisionsResponse.data as Map<String, dynamic>;
        if (data.containsKey('decisions') && data['decisions'] is List) {
          final decisionsList = data['decisions'] as List;
          partnerDecisions =
              decisionsList
                  .map(
                    (json) =>
                        PartnerDecision.fromJson(json as Map<String, dynamic>),
                  )
                  .toList();
        }
      }

      state = state.copyWith(
        pregnancyPlans: pregnancyPlans,
        partnerInvitations: partnerInvitations,
        partnerDecisions: partnerDecisions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load family planning data: ${e.toString()}',
      );
    }
  }

  /// Create pregnancy plan
  Future<bool> createPregnancyPlan(PregnancyPlan plan) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.createPregnancyPlan(plan.toJson());

      if (response.success && response.data != null) {
        final newPlan = PregnancyPlan.fromJson(
          response.data as Map<String, dynamic>,
        );
        final updatedPlans = [...state.pregnancyPlans, newPlan];

        state = state.copyWith(pregnancyPlans: updatedPlans, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to create pregnancy plan',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create pregnancy plan: ${e.toString()}',
      );
      return false;
    }
  }

  /// Update pregnancy plan
  Future<bool> updatePregnancyPlan(PregnancyPlan plan) async {
    if (plan.id == null) return false;

    // Check access control
    final currentUser = _ref.read(currentUserProvider);
    if (!FamilyPlanningAccessControl.canEditPregnancyPlan(currentUser, plan)) {
      state = state.copyWith(
        isLoading: false,
        error: 'You do not have permission to edit this pregnancy plan',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.updatePregnancyPlan(
        plan.id!,
        plan.toJson(),
      );

      if (response.success && response.data != null) {
        final updatedPlan = PregnancyPlan.fromJson(
          response.data as Map<String, dynamic>,
        );
        final updatedPlans =
            state.pregnancyPlans
                .map((p) => p.id == updatedPlan.id ? updatedPlan : p)
                .toList();

        state = state.copyWith(pregnancyPlans: updatedPlans, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to update pregnancy plan',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update pregnancy plan: ${e.toString()}',
      );
      return false;
    }
  }

  /// Delete pregnancy plan
  Future<bool> deletePregnancyPlan(int planId) async {
    // Find the plan to check access control
    final plan = state.pregnancyPlans.firstWhere(
      (p) => p.id == planId,
      orElse: () => throw Exception('Plan not found'),
    );

    // Check access control
    final currentUser = _ref.read(currentUserProvider);
    if (!FamilyPlanningAccessControl.canDeletePregnancyPlan(
      currentUser,
      plan,
    )) {
      state = state.copyWith(
        isLoading: false,
        error: 'You do not have permission to delete this pregnancy plan',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.deletePregnancyPlan(planId);

      if (response.success) {
        final updatedPlans =
            state.pregnancyPlans.where((p) => p.id != planId).toList();

        state = state.copyWith(pregnancyPlans: updatedPlans, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to delete pregnancy plan',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete pregnancy plan: ${e.toString()}',
      );
      return false;
    }
  }

  /// Send partner invitation
  Future<bool> sendPartnerInvitation(PartnerInvitation invitation) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.sendPartnerInvitation(
        invitation.toJson(),
      );

      if (response.success && response.data != null) {
        final newInvitation = PartnerInvitation.fromJson(
          response.data as Map<String, dynamic>,
        );
        final updatedInvitations = [...state.partnerInvitations, newInvitation];

        state = state.copyWith(
          partnerInvitations: updatedInvitations,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to send partner invitation',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send partner invitation: ${e.toString()}',
      );
      return false;
    }
  }

  /// Accept partner invitation
  Future<bool> acceptPartnerInvitation(String invitationCode) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.acceptPartnerInvitation(
        invitationCode,
      );

      if (response.success) {
        // Reload invitations to get updated status
        await loadFamilyPlanningData();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to accept partner invitation',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to accept partner invitation: ${e.toString()}',
      );
      return false;
    }
  }

  /// Decline partner invitation
  Future<bool> declinePartnerInvitation(String invitationCode) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.declinePartnerInvitation(
        invitationCode,
      );

      if (response.success) {
        // Reload invitations to get updated status
        await loadFamilyPlanningData();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to decline partner invitation',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to decline partner invitation: ${e.toString()}',
      );
      return false;
    }
  }

  /// Create partner decision
  Future<bool> createPartnerDecision(PartnerDecision decision) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.createPartnerDecision(
        decision.toJson(),
      );

      if (response.success && response.data != null) {
        final newDecision = PartnerDecision.fromJson(
          response.data as Map<String, dynamic>,
        );
        final updatedDecisions = [...state.partnerDecisions, newDecision];

        state = state.copyWith(
          partnerDecisions: updatedDecisions,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to create partner decision',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create partner decision: ${e.toString()}',
      );
      return false;
    }
  }

  /// Update partner decision
  Future<bool> updatePartnerDecision(PartnerDecision decision) async {
    if (decision.id == null) return false;

    // Check access control
    final currentUser = _ref.read(currentUserProvider);
    if (!FamilyPlanningAccessControl.canEditPartnerDecision(
      currentUser,
      decision,
    )) {
      state = state.copyWith(
        isLoading: false,
        error: 'You do not have permission to edit this partner decision',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.updatePartnerDecision(
        decision.id!,
        decision.toJson(),
      );

      if (response.success && response.data != null) {
        final updatedDecision = PartnerDecision.fromJson(
          response.data as Map<String, dynamic>,
        );
        final updatedDecisions =
            state.partnerDecisions
                .map((d) => d.id == updatedDecision.id ? updatedDecision : d)
                .toList();

        state = state.copyWith(
          partnerDecisions: updatedDecisions,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to update partner decision',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update partner decision: ${e.toString()}',
      );
      return false;
    }
  }

  /// Delete partner decision
  Future<bool> deletePartnerDecision(int decisionId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.deletePartnerDecision(decisionId);

      if (response.success) {
        final updatedDecisions =
            state.partnerDecisions.where((d) => d.id != decisionId).toList();

        state = state.copyWith(
          partnerDecisions: updatedDecisions,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to delete partner decision',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete partner decision: ${e.toString()}',
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Family Planning Provider
final familyPlanningProvider =
    StateNotifierProvider<FamilyPlanningNotifier, FamilyPlanningState>((ref) {
      return FamilyPlanningNotifier(ApiService.instance, ref);
    });

/// Pregnancy Plans Provider
final pregnancyPlansProvider = Provider<List<PregnancyPlan>>((ref) {
  return ref.watch(familyPlanningProvider).pregnancyPlans;
});

/// Partner Invitations Provider
final partnerInvitationsProvider = Provider<List<PartnerInvitation>>((ref) {
  return ref.watch(familyPlanningProvider).partnerInvitations;
});

/// Partner Decisions Provider
final partnerDecisionsProvider = Provider<List<PartnerDecision>>((ref) {
  return ref.watch(familyPlanningProvider).partnerDecisions;
});

/// Active Pregnancy Plans Provider
final activePregnancyPlansProvider = Provider<List<PregnancyPlan>>((ref) {
  final plans = ref.watch(pregnancyPlansProvider);
  return plans.where((plan) => plan.isActive).toList();
});

/// Pending Partner Invitations Provider
final pendingPartnerInvitationsProvider = Provider<List<PartnerInvitation>>((
  ref,
) {
  final invitations = ref.watch(partnerInvitationsProvider);
  return invitations.where((invitation) => invitation.canBeAccepted).toList();
});

/// Pending Partner Decisions Provider
final pendingPartnerDecisionsProvider = Provider<List<PartnerDecision>>((ref) {
  final decisions = ref.watch(partnerDecisionsProvider);
  return decisions.where((decision) => decision.isPending).toList();
});
