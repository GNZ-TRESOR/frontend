import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class SharedDecisionsScreen extends StatefulWidget {
  const SharedDecisionsScreen({super.key});

  @override
  State<SharedDecisionsScreen> createState() => _SharedDecisionsScreenState();
}

class _SharedDecisionsScreenState extends State<SharedDecisionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedDecisionType = 'contraception_method';
  bool _partnerAgreement = false;
  bool _isLoading = false;

  final List<DecisionType> _decisionTypes = [
    DecisionType(
      id: 'contraception_method',
      title: 'Uburyo bwo kurinda inda',
      description: 'Guhitamo uburyo bukwiye bwo kurinda inda',
      icon: Icons.medical_services_rounded,
      color: AppTheme.primaryColor,
    ),
    DecisionType(
      id: 'family_planning_timeline',
      title: 'Igihe cyo gushaka inda',
      description: 'Gushyiraho igihe cyo gushaka inda',
      icon: Icons.schedule_rounded,
      color: AppTheme.accentColor,
    ),
    DecisionType(
      id: 'health_checkups',
      title: 'Gusuzuma ubuzima',
      description: 'Gahunda yo gusuzuma ubuzima',
      icon: Icons.health_and_safety_rounded,
      color: AppTheme.successColor,
    ),
    DecisionType(
      id: 'lifestyle_changes',
      title: 'Guhindura ubuzima',
      description: 'Guhindura imyitwarire y\'ubuzima',
      icon: Icons.fitness_center_rounded,
      color: AppTheme.warningColor,
    ),
    DecisionType(
      id: 'financial_planning',
      title: 'Gahunda y\'amafaranga',
      description: 'Gutegura amafaranga y\'umuryango',
      icon: Icons.savings_rounded,
      color: AppTheme.infoColor,
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('bika') || lowerCommand.contains('save')) {
      _saveDecision();
    } else if (lowerCommand.contains('yemera') ||
        lowerCommand.contains('agree')) {
      setState(() {
        _partnerAgreement = true;
      });
    } else if (lowerCommand.contains('anga') ||
        lowerCommand.contains('disagree')) {
      setState(() {
        _partnerAgreement = false;
      });
    }
  }

  Future<void> _saveDecision() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Save decision via API
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu kubika icyemezo');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Icyemezo cyabitswe'),
            content: const Text(
              'Icyemezo cyawe cyabitswe neza. Umukunzi wawe azakibona akemeze cyangwa akange.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Sawa'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Icyemezo gishya'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          isTablet ? AppTheme.spacing24 : AppTheme.spacing16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction card
              _buildIntroductionCard(isTablet),

              SizedBox(height: AppTheme.spacing24),

              // Decision type selection
              _buildDecisionTypeSection(isTablet),

              SizedBox(height: AppTheme.spacing24),

              // Decision details
              _buildDecisionDetailsSection(isTablet),

              SizedBox(height: AppTheme.spacing24),

              // Partner agreement
              _buildPartnerAgreementSection(isTablet),

              SizedBox(height: AppTheme.spacing32),

              // Save button
              _buildSaveButton(isTablet),

              SizedBox(height: AppTheme.spacing24),

              // Guidelines
              _buildGuidelinesCard(isTablet),
            ],
          ),
        ),
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga ubwoko bw\'icyemezo cyangwa "Bika" kugira ngo ubike icyemezo',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gukora icyemezo',
      ),
    );
  }

  Widget _buildIntroductionCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: isTablet ? 32 : 24,
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  'Icyemezo gishya',
                  style: AppTheme.headingLarge.copyWith(
                    color: Colors.white,
                    fontSize: isTablet ? 24 : 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'Kora icyemezo gishya mwafata hamwe n\'umukunzi wawe. Icyemezo gizafasha gufata ibyemezo byiza by\'umuryango.',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildDecisionTypeSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hitamo ubwoko bw\'icyemezo',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(height: AppTheme.spacing20),

          ..._decisionTypes.map(
            (type) => _buildDecisionTypeOption(type, isTablet),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.3, duration: 600.ms);
  }

  Widget _buildDecisionTypeOption(DecisionType type, bool isTablet) {
    final isSelected = _selectedDecisionType == type.id;

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color:
              isSelected
                  ? type.color
                  : AppTheme.primaryColor.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedDecisionType = type.id;
            });
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(
              isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: type.id,
                  groupValue: _selectedDecisionType,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDecisionType = newValue!;
                    });
                  },
                  activeColor: type.color,
                ),
                Container(
                  padding: EdgeInsets.all(
                    isTablet ? AppTheme.spacing12 : AppTheme.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  ),
                  child: Icon(
                    type.icon,
                    color: type.color,
                    size: isTablet ? 24 : 20,
                  ),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.title,
                        style: AppTheme.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? type.color : AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        type.description,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionDetailsSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ibisobanuro by\'icyemezo',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(height: AppTheme.spacing20),

          // Title field
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Umutwe w\'icyemezo *',
              hintText: 'Andika umutwe w\'icyemezo',
              prefixIcon: const Icon(Icons.title_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Andika umutwe w\'icyemezo';
              }
              return null;
            },
          ),

          SizedBox(height: AppTheme.spacing16),

          // Description field
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Ibisobanuro *',
              hintText: 'Sobanura icyemezo mwafashe...',
              prefixIcon: const Icon(Icons.description_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Andika ibisobanuro by\'icyemezo';
              }
              return null;
            },
          ),

          SizedBox(height: AppTheme.spacing16),

          // Notes field
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Inyongera (optional)',
              hintText: 'Andika inyongera ku cyemezo...',
              prefixIcon: const Icon(Icons.note_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.3, duration: 600.ms);
  }

  Widget _buildPartnerAgreementSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ubwumvikane bw\'umukunzi',
            style: AppTheme.headingMedium.copyWith(
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),

          Container(
            padding: EdgeInsets.all(
              isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
            ),
            decoration: BoxDecoration(
              color:
                  _partnerAgreement
                      ? AppTheme.successColor.withValues(alpha: 0.1)
                      : AppTheme.warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color:
                    _partnerAgreement
                        ? AppTheme.successColor.withValues(alpha: 0.3)
                        : AppTheme.warningColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _partnerAgreement,
                  onChanged: (value) {
                    setState(() {
                      _partnerAgreement = value ?? false;
                    });
                  },
                  activeColor: AppTheme.successColor,
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _partnerAgreement
                            ? 'Umukunzi yemeje'
                            : 'Umukunzi ntiyemeje',
                        style: AppTheme.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              _partnerAgreement
                                  ? AppTheme.successColor
                                  : AppTheme.warningColor,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        _partnerAgreement
                            ? 'Umukunzi wawe yemeje iki cyemezo'
                            : 'Umukunzi wawe ntiyemeje iki cyemezo',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildSaveButton(bool isTablet) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveDecision,
        icon:
            _isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Icon(Icons.save_rounded),
        label: Text(
          _isLoading ? 'Urabika...' : 'Bika icyemezo',
          style: AppTheme.labelLarge.copyWith(
            color: Colors.white,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
        style: AppTheme.primaryButtonStyle.copyWith(
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(
              vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildGuidelinesCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.infoColor,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(
                'Inama z\'ibyemezo',
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.infoColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          _buildGuidelineItem(
            'Ganira n\'umukunzi wawe mbere yo gufata icyemezo',
            isTablet,
          ),
          _buildGuidelineItem('Sobanura neza icyemezo mwafashe', isTablet),
          _buildGuidelineItem('Emeza ko mwemvikanye byose', isTablet),
          _buildGuidelineItem('Genzura icyemezo buri gihe', isTablet),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildGuidelineItem(String text, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 6 : 4,
            height: isTablet ? 6 : 4,
            margin: EdgeInsets.only(
              top: isTablet ? 8 : 6,
              right: AppTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: AppTheme.infoColor,
              borderRadius: BorderRadius.circular(isTablet ? 3 : 2),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class DecisionType {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  DecisionType({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
