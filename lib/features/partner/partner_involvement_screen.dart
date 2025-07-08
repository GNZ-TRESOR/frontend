import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/contraception_model.dart';
import '../../widgets/voice_button.dart';
import 'partner_invitation_screen.dart';
import 'shared_decisions_screen.dart';

class PartnerInvolvementScreen extends StatefulWidget {
  const PartnerInvolvementScreen({super.key});

  @override
  State<PartnerInvolvementScreen> createState() =>
      _PartnerInvolvementScreenState();
}

class _PartnerInvolvementScreenState extends State<PartnerInvolvementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PartnerInvolvement? _partnerInfo;
  List<SharedDecision> _sharedDecisions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPartnerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPartnerData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));

      _partnerInfo = PartnerInvolvement(
        id: '1',
        userId: 'current_user_id',
        partnerName: 'Jean Baptiste',
        partnerPhone: '+250788123456',
        partnerEmail: 'jean@example.com',
        isInvolved: true,
        sharedDecisions: ['contraception_method', 'family_planning_timeline'],
        consent: ContraceptionConsent.fullConsent,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      _sharedDecisions = [
        SharedDecision(
          id: '1',
          type: 'contraception_method',
          title: 'Guhitamo uburyo bwo kurinda inda',
          description: 'Twahisemo gukoresha imiti y\'kurinda inda',
          decidedDate: DateTime.now().subtract(const Duration(days: 15)),
          partnerAgreement: true,
          notes: 'Twumvikanye ko ari uburyo bukwiye',
        ),
        SharedDecision(
          id: '2',
          type: 'family_planning_timeline',
          title: 'Igihe cyo gushaka inda',
          description: 'Twahisemo gutegereza imyaka 2',
          decidedDate: DateTime.now().subtract(const Duration(days: 30)),
          partnerAgreement: true,
          notes: 'Dushaka gutegura neza mbere yo gushaka inda',
        ),
      ];
    } catch (e) {
      _showErrorSnackBar('Habaye ikosa mu gushaka amakuru');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('tuma') || lowerCommand.contains('invite')) {
      _invitePartner();
    } else if (lowerCommand.contains('ibyemezo') ||
        lowerCommand.contains('decisions')) {
      _tabController.animateTo(1);
    } else if (lowerCommand.contains('ubwumvikane') ||
        lowerCommand.contains('consent')) {
      _tabController.animateTo(2);
    } else if (lowerCommand.contains('vugurura') ||
        lowerCommand.contains('update')) {
      _updatePartnerInfo();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(isTablet),
            _buildPartnerInfoCard(isTablet),
            _buildTabBar(isTablet),
          ];
        },
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(isTablet),
                    _buildDecisionsTab(isTablet),
                    _buildConsentTab(isTablet),
                  ],
                ),
      ),
      floatingActionButton: VoiceButton(
        prompt:
            'Vuga: "Tuma" kugira ngo utume umukunzi wawe, "Ibyemezo" kugira ngo ugere ku byemezo, cyangwa "Ubwumvikane" kugira ngo ugere ku bwumvikane',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gucunga umukunzi',
      ),
    );
  }

  Widget _buildAppBar(bool isTablet) {
    return SliverAppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      title: const Text('Ubufatanye n\'umukunzi'),
      actions: [
        if (_partnerInfo == null)
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: _invitePartner,
            tooltip: 'Tuma umukunzi',
          ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'update_info':
                _updatePartnerInfo();
                break;
              case 'communication_settings':
                _communicationSettings();
                break;
              case 'privacy_settings':
                _privacySettings();
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'update_info',
                  child: Text('Vugurura amakuru'),
                ),
                const PopupMenuItem(
                  value: 'communication_settings',
                  child: Text('Igenamiterere y\'itumanaho'),
                ),
                const PopupMenuItem(
                  value: 'privacy_settings',
                  child: Text('Igenamiterere y\'ibanga'),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildPartnerInfoCard(bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            isTablet ? AppTheme.spacing32 : AppTheme.spacing24,
          ),
          child:
              _partnerInfo != null
                  ? _buildPartnerInfo(_partnerInfo!, isTablet)
                  : _buildNoPartnerCard(isTablet),
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, duration: 600.ms),
    );
  }

  Widget _buildPartnerInfo(PartnerInvolvement partner, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: isTablet ? 32 : 24,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: isTablet ? 32 : 24,
              ),
            ),
            SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.partnerName,
                    style: AppTheme.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: isTablet ? 24 : 20,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  if (partner.partnerPhone != null)
                    Text(
                      partner.partnerPhone!,
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  SizedBox(height: AppTheme.spacing4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                      vertical: AppTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          partner.isInvolved
                              ? AppTheme.successColor.withValues(alpha: 0.2)
                              : AppTheme.warningColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.spacing4),
                    ),
                    child: Text(
                      partner.isInvolved ? 'Arafatanya' : 'Ntafatanya',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacing24),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Ibyemezo',
                '${partner.sharedDecisions.length}',
                Icons.check_circle_rounded,
                isTablet,
              ),
            ),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildInfoCard(
                'Ubwumvikane',
                _getConsentLabel(partner.consent),
                Icons.handshake_rounded,
                isTablet,
              ),
            ),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildInfoCard(
                'Igihe',
                '${DateTime.now().difference(partner.createdAt).inDays} iminsi',
                Icons.calendar_today_rounded,
                isTablet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoPartnerCard(bool isTablet) {
    return Column(
      children: [
        Icon(
          Icons.people_rounded,
          color: Colors.white.withValues(alpha: 0.7),
          size: isTablet ? 64 : 48,
        ),
        SizedBox(height: AppTheme.spacing16),
        Text(
          'Nta mukunzi ufatanya nawe',
          style: AppTheme.headingMedium.copyWith(
            color: Colors.white,
            fontSize: isTablet ? 20 : 18,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacing8),
        Text(
          'Tuma umukunzi wawe kugira ngo mufatanye mu gufata ibyemezo',
          style: AppTheme.bodyLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacing24),
        ElevatedButton.icon(
          onPressed: _invitePartner,
          icon: const Icon(Icons.person_add_rounded),
          label: const Text('Tuma umukunzi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? AppTheme.spacing24 : AppTheme.spacing20,
              vertical: isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing16 : AppTheme.spacing12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: isTablet ? 24 : 20),
          SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(
              color: Colors.white,
              fontSize: isTablet ? 16 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spacing4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: isTablet ? 12 : 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isTablet) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          labelStyle: AppTheme.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 14 : 12,
          ),
          unselectedLabelStyle: AppTheme.labelMedium.copyWith(
            fontSize: isTablet ? 14 : 12,
          ),
          tabs: const [
            Tab(text: 'Incamake'),
            Tab(text: 'Ibyemezo'),
            Tab(text: 'Ubwumvikane'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ubufatanye mu buzima', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildPartnershipBenefits(isTablet),

          SizedBox(height: AppTheme.spacing24),

          _buildSectionTitle('Ibikorwa byihuse', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildQuickActions(isTablet),

          SizedBox(height: AppTheme.spacing24),

          _buildSectionTitle('Inama z\'ubufatanye', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildPartnershipTips(isTablet),
        ],
      ),
    );
  }

  Widget _buildDecisionsTab(bool isTablet) {
    return ListView.builder(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      itemCount: _sharedDecisions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Ibyemezo byafashwe hamwe', isTablet),
                  ElevatedButton.icon(
                    onPressed: _addSharedDecision,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Ongeraho'),
                    style: AppTheme.primaryButtonStyle,
                  ),
                ],
              ),
              SizedBox(height: AppTheme.spacing16),
            ],
          );
        }

        final decision = _sharedDecisions[index - 1];
        return _buildDecisionCard(decision, isTablet);
      },
    );
  }

  Widget _buildConsentTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ubwumvikane bw\'umukunzi', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildConsentStatus(isTablet),

          SizedBox(height: AppTheme.spacing24),

          _buildSectionTitle('Uburenganzira n\'inshingano', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildRightsAndResponsibilities(isTablet),

          SizedBox(height: AppTheme.spacing24),

          _buildSectionTitle('Guhindura ubwumvikane', isTablet),
          SizedBox(height: AppTheme.spacing16),
          _buildConsentActions(isTablet),
        ],
      ),
    );
  }

  // Helper methods and widgets would continue here...
  // Due to length constraints, I'll create the remaining methods in the next part

  Widget _buildSectionTitle(String title, bool isTablet) {
    return Text(
      title,
      style: AppTheme.headingMedium.copyWith(
        fontSize: isTablet ? 20 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _getConsentLabel(ContraceptionConsent consent) {
    switch (consent) {
      case ContraceptionConsent.fullConsent:
        return 'Yemeje byose';
      case ContraceptionConsent.partialConsent:
        return 'Yemeje igice';
      case ContraceptionConsent.noConsent:
        return 'Ntiyemeje';
      case ContraceptionConsent.unknown:
        return 'Ntibizi';
    }
  }

  // Action methods
  void _invitePartner() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PartnerInvitationScreen()),
    );
  }

  void _updatePartnerInfo() {
    _showErrorSnackBar('Vugurura amakuru - Izaza vuba');
  }

  void _communicationSettings() {
    _showErrorSnackBar('Igenamiterere y\'itumanaho - Izaza vuba');
  }

  void _privacySettings() {
    _showErrorSnackBar('Igenamiterere y\'ibanga - Izaza vuba');
  }

  void _addSharedDecision() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SharedDecisionsScreen()),
    );
  }

  // Placeholder methods for remaining widgets
  Widget _buildPartnershipBenefits(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Inyungu z\'ubufatanye mu buzima...'),
    );
  }

  Widget _buildQuickActions(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Ibikorwa byihuse...'),
    );
  }

  Widget _buildPartnershipTips(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Inama z\'ubufatanye...'),
    );
  }

  Widget _buildDecisionCard(SharedDecision decision, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing12),
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Icyemezo: ${decision.title}'),
    );
  }

  Widget _buildConsentStatus(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Ubwumvikane bw\'umukunzi...'),
    );
  }

  Widget _buildRightsAndResponsibilities(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Uburenganzira n\'inshingano...'),
    );
  }

  Widget _buildConsentActions(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(
        isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text('Ibikorwa by\'ubwumvikane...'),
    );
  }
}

// Helper classes
class SharedDecision {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime decidedDate;
  final bool partnerAgreement;
  final String? notes;

  SharedDecision({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.decidedDate,
    required this.partnerAgreement,
    this.notes,
  });
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppTheme.backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
