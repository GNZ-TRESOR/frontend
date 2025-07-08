import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';
import 'faq_screen.dart';
import 'tutorial_screen.dart';
import 'contact_support_screen.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  bool _isLoading = false;
  String _searchQuery = '';

  final List<HelpCategory> _helpCategories = [
    HelpCategory(
      title: 'Gutangira',
      description: 'Menya uko ukoresha app ya Ubuzima',
      icon: Icons.play_circle_outline,
      color: AppTheme.primaryColor,
      items: [
        'Kwiyandikisha konti',
        'Gushyiraho profil yawe',
        'Koresha ijwi',
        'Gukoresha offline',
      ],
    ),
    HelpCategory(
      title: 'Ubuzima',
      description: 'Amakuru ku buzima n\'ubwiyunge',
      icon: Icons.health_and_safety,
      color: AppTheme.secondaryColor,
      items: [
        'Gukurikirana ubuzima',
        'Ubwiyunge',
        'Kurinda indwara',
        'Inama z\'ubuzima',
      ],
    ),
    HelpCategory(
      title: 'Umuryango',
      description: 'Kwinjira mu muryango no gusangira',
      icon: Icons.group,
      color: AppTheme.accentColor,
      items: [
        'Kwinjira mu matsinda',
        'Gusangira mu biganiro',
        'Ibirori by\'umuryango',
        'Gusabana ubufasha',
      ],
    ),
    HelpCategory(
      title: 'Igenamiterere',
      description: 'Gena app yawe nk\'uko ushaka',
      icon: Icons.settings,
      color: AppTheme.warningColor,
      items: [
        'Guhindura ururimi',
        'Amamenyo',
        'Ubwite',
        'Umutekano',
      ],
    ),
  ];

  final List<QuickHelp> _quickHelps = [
    QuickHelp(
      title: 'Ibibazo bikunze kubazwa',
      description: 'Subiza ibibazo bikunze kubazwa',
      icon: Icons.help_outline,
      onTap: 'faq',
    ),
    QuickHelp(
      title: 'Amasomo',
      description: 'Iga uko ukoresha app',
      icon: Icons.school,
      onTap: 'tutorial',
    ),
    QuickHelp(
      title: 'Hamagara ubufasha',
      description: 'Vugana n\'itsinda ry\'ubufasha',
      icon: Icons.support_agent,
      onTap: 'contact',
    ),
    QuickHelp(
      title: 'Tanga igitekerezo',
      description: 'Dutumire igitekerezo cyawe',
      icon: Icons.feedback,
      onTap: 'feedback',
    ),
  ];

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('ibibazo') || lowerCommand.contains('faq')) {
      _navigateToFAQ();
    } else if (lowerCommand.contains('amasomo') || lowerCommand.contains('tutorial')) {
      _navigateToTutorial();
    } else if (lowerCommand.contains('ubufasha') || lowerCommand.contains('support')) {
      _navigateToSupport();
    } else if (lowerCommand.contains('gushaka') || lowerCommand.contains('search')) {
      // Focus search field
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Ubufasha'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(isTablet),
            SizedBox(height: AppTheme.spacing32),
            _buildSearchSection(isTablet),
            SizedBox(height: AppTheme.spacing32),
            _buildQuickHelp(isTablet),
            SizedBox(height: AppTheme.spacing32),
            _buildHelpCategories(isTablet),
            SizedBox(height: AppTheme.spacing32),
            _buildEmergencyContact(isTablet),
          ],
        ),
      ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga: "Ibibazo" kugira ngo ugere ku bibazo bikunze kubazwa, "Amasomo" kugira ngo ugere ku masomo, cyangwa "Ubufasha" kugira ngo uhamagare ubufasha',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gushaka ubufasha',
      ),
    );
  }

  Widget _buildWelcomeSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent,
                color: Colors.white,
                size: isTablet ? 40 : 32,
              ),
              SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Murakaza neza ku bufasha',
                      style: AppTheme.headingLarge.copyWith(
                        color: Colors.white,
                        fontSize: isTablet ? 24 : 20,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing8),
                    Text(
                      'Turi hano kugira ngo dufashe. Shakisha ubufasha cyangwa uvugane natwe.',
                      style: AppTheme.bodyLarge.copyWith(
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
    ).animate().fadeIn().slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildSearchSection(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing16),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Shakisha ubufasha...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppTheme.backgroundColor,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
    );
  }

  Widget _buildQuickHelp(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubufasha bwihuse',
          style: AppTheme.headingMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppTheme.spacing16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 4 : 2,
            crossAxisSpacing: AppTheme.spacing16,
            mainAxisSpacing: AppTheme.spacing16,
            childAspectRatio: 1.1,
          ),
          itemCount: _quickHelps.length,
          itemBuilder: (context, index) {
            final help = _quickHelps[index];
            return _buildQuickHelpCard(help, isTablet, index);
          },
        ),
      ],
    );
  }

  Widget _buildQuickHelpCard(QuickHelp help, bool isTablet, int index) {
    return Card(
      child: InkWell(
        onTap: () => _handleQuickHelp(help.onTap),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                help.icon,
                color: AppTheme.primaryColor,
                size: isTablet ? 32 : 28,
              ),
              SizedBox(height: AppTheme.spacing8),
              Text(
                help.title,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.spacing4),
              Text(
                help.description,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX();
  }

  Widget _buildHelpCategories(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ibyiciro by\'ubufasha',
          style: AppTheme.headingMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppTheme.spacing16),
        ...List.generate(_helpCategories.length, (index) {
          final category = _helpCategories[index];
          return _buildCategoryCard(category, isTablet, index);
        }),
      ],
    );
  }

  Widget _buildCategoryCard(HelpCategory category, bool isTablet, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(AppTheme.spacing8),
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(category.icon, color: category.color),
        ),
        title: Text(
          category.title,
          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          category.description,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
        ),
        children: category.items.map((item) {
          return ListTile(
            leading: Icon(Icons.help_outline, color: AppTheme.textTertiary, size: 20),
            title: Text(item),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showHelpItem(category.title, item),
          );
        }).toList(),
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideY();
  }

  Widget _buildEmergencyContact(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency, color: AppTheme.errorColor),
              SizedBox(width: AppTheme.spacing12),
              Text(
                'Igihe cy\'ihutirwa',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing12),
          Text(
            'Niba ufite ikibazo cy\'ihutirwa cy\'ubuzima, hamagara:',
            style: AppTheme.bodyMedium,
          ),
          SizedBox(height: AppTheme.spacing8),
          Row(
            children: [
              Icon(Icons.phone, color: AppTheme.errorColor, size: 20),
              SizedBox(width: AppTheme.spacing8),
              Text(
                '912 - Ubufasha bw\'ihutirwa',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          Row(
            children: [
              Icon(Icons.local_hospital, color: AppTheme.errorColor, size: 20),
              SizedBox(width: AppTheme.spacing8),
              Text(
                '114 - Ubufasha bw\'ubuzima',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleQuickHelp(String action) {
    switch (action) {
      case 'faq':
        _navigateToFAQ();
        break;
      case 'tutorial':
        _navigateToTutorial();
        break;
      case 'contact':
        _navigateToSupport();
        break;
      case 'feedback':
        _showFeedbackDialog();
        break;
    }
  }

  void _navigateToFAQ() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FAQScreen()),
    );
  }

  void _navigateToTutorial() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TutorialScreen()),
    );
  }

  void _navigateToSupport() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ContactSupportScreen()),
    );
  }

  void _showHelpItem(String category, String item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item),
        content: Text('Ubufasha bwa "$item" mu cyiciro cya "$category" - Buzaza vuba...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sawa'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tanga igitekerezo'),
        content: const TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Andika igitekerezo cyawe hano...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Siga'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Igitekerezo cyoherejwe! Murakoze.')),
              );
            },
            child: const Text('Ohereza'),
          ),
        ],
      ),
    );
  }
}

class HelpCategory {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> items;

  HelpCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class QuickHelp {
  final String title;
  final String description;
  final IconData icon;
  final String onTap;

  QuickHelp({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });
}
