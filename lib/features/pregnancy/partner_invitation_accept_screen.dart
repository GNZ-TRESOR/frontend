import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/family_planning_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_overlay.dart';

/// Partner Invitation Accept Screen for accepting invitations via code
class PartnerInvitationAcceptScreen extends ConsumerStatefulWidget {
  final String? invitationCode;

  const PartnerInvitationAcceptScreen({
    super.key,
    this.invitationCode,
  });

  @override
  ConsumerState<PartnerInvitationAcceptScreen> createState() =>
      _PartnerInvitationAcceptScreenState();
}

class _PartnerInvitationAcceptScreenState
    extends ConsumerState<PartnerInvitationAcceptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.invitationCode != null) {
      _codeController.text = widget.invitationCode!;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyPlanningState = ref.watch(familyPlanningProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Accept Invitation'),
        backgroundColor: AppColors.pregnancyPurple,
        foregroundColor: Colors.white,
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
                const SizedBox(height: 32),
                _buildInvitationCodeField(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 32),
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
      padding: const EdgeInsets.all(24),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people_alt,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join Your Partner',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Enter the invitation code to connect',
                      style: TextStyle(
                        fontSize: 16,
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

  Widget _buildInvitationCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invitation Code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Enter 8-character invitation code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(Icons.vpn_key, color: AppColors.pregnancyPurple),
            suffixIcon: IconButton(
              onPressed: _pasteFromClipboard,
              icon: Icon(Icons.content_paste, color: AppColors.pregnancyPurple),
              tooltip: 'Paste from clipboard',
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Invitation code is required';
            }
            if (value.trim().length != 8) {
              return 'Invitation code must be 8 characters';
            }
            return null;
          },
          onChanged: (value) {
            // Auto-format to uppercase
            final formatted = value.toUpperCase();
            if (formatted != value) {
              _codeController.value = _codeController.value.copyWith(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Ask your partner for the 8-character invitation code they received',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _acceptInvitation,
            icon: Icon(Icons.check_circle),
            label: Text(
              'Accept Invitation',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _declineInvitation,
            icon: Icon(Icons.cancel),
            label: Text(
              'Decline Invitation',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
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
                'What happens next?',
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
            '• Accepting will connect you with your partner\n'
            '• You\'ll be able to share family planning information\n'
            '• Both partners can collaborate on decisions\n'
            '• You can disconnect at any time in settings',
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

  Future<void> _pasteFromClipboard() async {
    // TODO: Implement clipboard paste functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paste functionality not implemented yet'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  Future<void> _acceptInvitation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final invitationCode = _codeController.text.trim().toUpperCase();
      
      final success = await ref
          .read(familyPlanningProvider.notifier)
          .acceptPartnerInvitation(invitationCode);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Partner invitation accepted successfully!'),
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
              content: Text(error ?? 'Failed to accept partner invitation'),
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

  Future<void> _declineInvitation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Invitation'),
        content: const Text(
          'Are you sure you want to decline this partner invitation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Decline'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final invitationCode = _codeController.text.trim().toUpperCase();
      
      final success = await ref
          .read(familyPlanningProvider.notifier)
          .declinePartnerInvitation(invitationCode);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Partner invitation declined'),
              backgroundColor: AppColors.warning,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        final error = ref.read(familyPlanningProvider).error;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to decline partner invitation'),
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
}
