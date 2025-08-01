import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/partner_invitation.dart';
import '../../core/providers/family_planning_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';

/// Partner Invitation Form Screen for sending invitations
class PartnerInvitationFormScreen extends ConsumerStatefulWidget {
  const PartnerInvitationFormScreen({super.key});

  @override
  ConsumerState<PartnerInvitationFormScreen> createState() =>
      _PartnerInvitationFormScreenState();
}

class _PartnerInvitationFormScreenState
    extends ConsumerState<PartnerInvitationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  InvitationType _invitationType = InvitationType.partnerLink;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyPlanningState = ref.watch(familyPlanningProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Invite Partner'),
        backgroundColor: AppColors.pregnancyPurple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _sendInvitation,
            child: Text(
              'Send',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading || familyPlanningState.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('Partner Information'),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPhoneField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Invitation Type'),
                const SizedBox(height: 16),
                _buildInvitationTypeField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Personal Message (Optional)'),
                const SizedBox(height: 16),
                _buildMessageField(),
                const SizedBox(height: 32),
                _buildSendButton(),
                const SizedBox(height: 16),
                _buildInfoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.pregnancyPurple,
            AppColors.pregnancyPurple.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.pregnancyPurple.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite Your Partner',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Share your family planning journey together',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: 'Partner\'s Email *',
        hintText: 'Enter your partner\'s email address',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.email, color: AppColors.pregnancyPurple),
        suffixIcon:
            _emailController.text.isNotEmpty
                ? Icon(
                  _isValidEmail(_emailController.text)
                      ? Icons.check_circle
                      : Icons.error,
                  color:
                      _isValidEmail(_emailController.text)
                          ? AppColors.success
                          : AppColors.error,
                )
                : null,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        if (!_isValidEmail(value.trim())) {
          return 'Please enter a valid email address';
        }
        // Check if it's not the user's own email
        // This would require getting current user email
        return null;
      },
      onChanged: (value) {
        setState(() {}); // Update suffix icon
      },
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Partner\'s Phone (Optional)',
        hintText: 'Enter your partner\'s phone number',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.phone, color: AppColors.pregnancyPurple),
        suffixIcon:
            _phoneController.text.isNotEmpty
                ? Icon(
                  _isValidPhone(_phoneController.text)
                      ? Icons.check_circle
                      : Icons.error,
                  color:
                      _isValidPhone(_phoneController.text)
                          ? AppColors.success
                          : AppColors.error,
                )
                : null,
      ),
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          if (!_isValidPhone(value.trim())) {
            return 'Please enter a valid phone number';
          }
          if (value.trim().length < 10) {
            return 'Phone number must be at least 10 digits';
          }
        }
        return null;
      },
      onChanged: (value) {
        setState(() {}); // Update suffix icon
      },
    );
  }

  bool _isValidPhone(String phone) {
    // Remove all non-digit characters for validation
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }

  Widget _buildInvitationTypeField() {
    return Column(
      children: [
        _buildInvitationTypeOption(
          InvitationType.partnerLink,
          'Partner Link',
          'Basic partner connection for shared planning',
          Icons.link,
        ),
        const SizedBox(height: 12),
        _buildInvitationTypeOption(
          InvitationType.healthSharing,
          'Health Sharing',
          'Share health information and medical records',
          Icons.health_and_safety,
        ),
        const SizedBox(height: 12),
        _buildInvitationTypeOption(
          InvitationType.decisionMaking,
          'Decision Making',
          'Collaborate on family planning decisions',
          Icons.how_to_vote,
        ),
      ],
    );
  }

  Widget _buildInvitationTypeOption(
    InvitationType type,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _invitationType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _invitationType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.pregnancyPurple.withValues(alpha: 0.1)
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.pregnancyPurple : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.pregnancyPurple
                        : AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? AppColors.pregnancyPurple
                              : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              Icon(
                Icons.check_circle,
                color: AppColors.pregnancyPurple,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return TextFormField(
      controller: _messageController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Add a personal message to your invitation...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _sendInvitation,
        icon: Icon(Icons.send),
        label: Text(
          'Send Invitation',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pregnancyPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'How it works',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Your partner will receive an invitation via email\n'
            '• They can accept or decline the invitation\n'
            '• Once accepted, you can collaborate on family planning\n'
            '• You can manage invitations in the Partner Management section',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendInvitation() async {
    // Clear any previous errors
    ref.read(familyPlanningProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Additional validation
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (phone.isNotEmpty && !_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Generate a unique invitation code
      final invitationCode = _generateInvitationCode();

      final invitation = PartnerInvitation(
        senderId: currentUser.id!,
        recipientEmail: _emailController.text.trim(),
        recipientPhone:
            _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
        invitationType: _invitationType,
        invitationMessage:
            _messageController.text.trim().isNotEmpty
                ? _messageController.text.trim()
                : null,
        invitationCode: invitationCode,
        expiresAt: DateTime.now().add(const Duration(days: 7)), // 7 days expiry
      );

      final success = await ref
          .read(familyPlanningProvider.notifier)
          .sendPartnerInvitation(invitation);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Partner invitation sent successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        final error = ref.read(familyPlanningProvider).error;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to send partner invitation'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _generateInvitationCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(8, (index) => chars[random % chars.length]).join();
  }
}
