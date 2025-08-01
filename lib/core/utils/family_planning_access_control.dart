import '../models/pregnancy_plan.dart';
import '../models/partner_invitation.dart';
import '../models/partner_decision.dart';
import '../models/user.dart';

/// Family Planning Access Control Utility
/// Provides methods to check user permissions for family planning operations
class FamilyPlanningAccessControl {
  /// Check if user can edit a pregnancy plan
  static bool canEditPregnancyPlan(User? currentUser, PregnancyPlan plan) {
    if (currentUser == null) return false;
    
    // User can edit their own plans
    if (plan.userId == currentUser.id) return true;
    
    // Partner can edit shared plans (if partnerId matches)
    if (plan.partnerId == currentUser.id) return true;
    
    return false;
  }

  /// Check if user can delete a pregnancy plan
  static bool canDeletePregnancyPlan(User? currentUser, PregnancyPlan plan) {
    if (currentUser == null) return false;
    
    // Only the plan creator can delete
    return plan.userId == currentUser.id;
  }

  /// Check if user can view a pregnancy plan
  static bool canViewPregnancyPlan(User? currentUser, PregnancyPlan plan) {
    if (currentUser == null) return false;
    
    // User can view their own plans
    if (plan.userId == currentUser.id) return true;
    
    // Partner can view shared plans
    if (plan.partnerId == currentUser.id) return true;
    
    return false;
  }

  /// Check if user can respond to a partner invitation
  static bool canRespondToInvitation(User? currentUser, PartnerInvitation invitation) {
    if (currentUser == null) return false;
    
    // User can respond to invitations sent to them
    // Note: This would require checking recipient email against user email
    // For now, we'll assume the API handles this filtering
    return invitation.status == InvitationStatus.sent && !invitation.isExpired;
  }

  /// Check if user can cancel a partner invitation
  static bool canCancelInvitation(User? currentUser, PartnerInvitation invitation) {
    if (currentUser == null) return false;
    
    // Only the sender can cancel
    if (invitation.senderId == currentUser.id) {
      // Can only cancel if not yet accepted
      return invitation.status == InvitationStatus.sent || 
             invitation.status == InvitationStatus.delivered;
    }
    
    return false;
  }

  /// Check if user can edit a partner decision
  static bool canEditPartnerDecision(User? currentUser, PartnerDecision decision) {
    if (currentUser == null) return false;
    
    // User can edit their own decisions
    if (decision.userId == currentUser.id) return true;
    
    // Partner can edit shared decisions (if partnerId matches)
    if (decision.partnerId == currentUser.id) return true;
    
    return false;
  }

  /// Check if user can delete a partner decision
  static bool canDeletePartnerDecision(User? currentUser, PartnerDecision decision) {
    if (currentUser == null) return false;
    
    // Only the decision creator can delete
    return decision.userId == currentUser.id;
  }

  /// Check if user can change decision status
  static bool canChangeDecisionStatus(User? currentUser, PartnerDecision decision, DecisionStatus newStatus) {
    if (currentUser == null) return false;
    
    // User can change status of their own decisions
    if (decision.userId == currentUser.id) return true;
    
    // Partner can respond to decisions (change to discussing, agreed, disagreed)
    if (decision.partnerId == currentUser.id) {
      return newStatus == DecisionStatus.discussing ||
             newStatus == DecisionStatus.agreed ||
             newStatus == DecisionStatus.disagreed;
    }
    
    return false;
  }

  /// Check if user can view a partner decision
  static bool canViewPartnerDecision(User? currentUser, PartnerDecision decision) {
    if (currentUser == null) return false;
    
    // User can view their own decisions
    if (decision.userId == currentUser.id) return true;
    
    // Partner can view shared decisions
    if (decision.partnerId == currentUser.id) return true;
    
    return false;
  }

  /// Check if user can create a new pregnancy plan
  static bool canCreatePregnancyPlan(User? currentUser) {
    // Any authenticated user can create a pregnancy plan
    return currentUser != null;
  }

  /// Check if user can send partner invitations
  static bool canSendPartnerInvitation(User? currentUser) {
    // Any authenticated user can send partner invitations
    return currentUser != null;
  }

  /// Check if user can create partner decisions
  static bool canCreatePartnerDecision(User? currentUser) {
    // Any authenticated user can create partner decisions
    return currentUser != null;
  }

  /// Get filtered pregnancy plans for current user
  static List<PregnancyPlan> filterPregnancyPlans(User? currentUser, List<PregnancyPlan> plans) {
    if (currentUser == null) return [];
    
    return plans.where((plan) => canViewPregnancyPlan(currentUser, plan)).toList();
  }

  /// Get filtered partner invitations for current user
  static List<PartnerInvitation> filterPartnerInvitations(User? currentUser, List<PartnerInvitation> invitations) {
    if (currentUser == null) return [];
    
    // User can see invitations they sent or received
    return invitations.where((invitation) => 
        invitation.senderId == currentUser.id ||
        // Note: For received invitations, we'd need to check recipient email
        // The API should handle this filtering
        true
    ).toList();
  }

  /// Get filtered partner decisions for current user
  static List<PartnerDecision> filterPartnerDecisions(User? currentUser, List<PartnerDecision> decisions) {
    if (currentUser == null) return [];
    
    return decisions.where((decision) => canViewPartnerDecision(currentUser, decision)).toList();
  }

  /// Check if user has partner access (has active partner connections)
  static bool hasPartnerAccess(User? currentUser, List<PartnerInvitation> invitations) {
    if (currentUser == null) return false;
    
    // Check if user has any accepted partner invitations
    return invitations.any((invitation) => 
        invitation.status == InvitationStatus.accepted &&
        (invitation.senderId == currentUser.id || 
         // Note: Would need to check recipient email for received invitations
         false)
    );
  }

  /// Get user's role display name for UI
  static String getUserRoleDisplayName(User? currentUser) {
    if (currentUser == null) return 'Guest';
    
    // This would depend on your user role system
    // For now, return a generic user role
    return 'User';
  }

  /// Check if operation requires partner confirmation
  static bool requiresPartnerConfirmation(PartnerDecision decision) {
    // Decisions in proposed or discussing status require partner input
    return decision.decisionStatus == DecisionStatus.proposed ||
           decision.decisionStatus == DecisionStatus.discussing;
  }

  /// Get available actions for a pregnancy plan
  static List<String> getAvailableActionsForPlan(User? currentUser, PregnancyPlan plan) {
    final actions = <String>[];
    
    if (canViewPregnancyPlan(currentUser, plan)) {
      actions.add('view');
    }
    
    if (canEditPregnancyPlan(currentUser, plan)) {
      actions.add('edit');
    }
    
    if (canDeletePregnancyPlan(currentUser, plan)) {
      actions.add('delete');
    }
    
    return actions;
  }

  /// Get available actions for a partner invitation
  static List<String> getAvailableActionsForInvitation(User? currentUser, PartnerInvitation invitation) {
    final actions = <String>[];
    
    if (canRespondToInvitation(currentUser, invitation)) {
      actions.addAll(['accept', 'decline']);
    }
    
    if (canCancelInvitation(currentUser, invitation)) {
      actions.add('cancel');
    }
    
    return actions;
  }

  /// Get available actions for a partner decision
  static List<String> getAvailableActionsForDecision(User? currentUser, PartnerDecision decision) {
    final actions = <String>[];
    
    if (canViewPartnerDecision(currentUser, decision)) {
      actions.add('view');
    }
    
    if (canEditPartnerDecision(currentUser, decision)) {
      actions.add('edit');
    }
    
    if (canDeletePartnerDecision(currentUser, decision)) {
      actions.add('delete');
    }
    
    // Add status change actions
    if (decision.partnerId == currentUser?.id && decision.isPending) {
      actions.addAll(['discuss', 'agree', 'disagree']);
    }
    
    return actions;
  }

  /// Validate access before performing operation
  static bool validateAccess(String operation, User? currentUser, dynamic item) {
    switch (operation) {
      case 'edit_plan':
        return item is PregnancyPlan && canEditPregnancyPlan(currentUser, item);
      case 'delete_plan':
        return item is PregnancyPlan && canDeletePregnancyPlan(currentUser, item);
      case 'edit_decision':
        return item is PartnerDecision && canEditPartnerDecision(currentUser, item);
      case 'delete_decision':
        return item is PartnerDecision && canDeletePartnerDecision(currentUser, item);
      case 'cancel_invitation':
        return item is PartnerInvitation && canCancelInvitation(currentUser, item);
      default:
        return false;
    }
  }
}
