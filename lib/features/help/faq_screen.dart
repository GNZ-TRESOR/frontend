import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Ni gute nshobora kwiyandikisha muri app ya Ubuzima?',
      answer: 'Kugira ngo wiyandikishe:\n1. Kanda "Kwiyandikisha" ku rupapuro rw\'ibanze\n2. Uzuza amakuru yawe\n3. Emeza email yawe\n4. Shyiraho ijambo ry\'ibanga rikomeye\n5. Kanda "Kuraguza kwiyandikisha"',
      category: 'Konti',
      tags: ['kwiyandikisha', 'konti', 'gutangira'],
    ),
    FAQItem(
      question: 'Ni ubuhe buryo bwiza bwo kurinda inda?',
      answer: 'Hari uburyo butandukanye bwo kurinda inda:\n• Imiti y\'kurinda inda (pills)\n• Inshinge\n• Condom\n• IUD\n• Implant\n\nBuri buryo bufite inyungu n\'ingaruka zabwo. Saba inama ku muganga cyangwa umujyanama w\'ubuzima.',
      category: 'Ubwiyunge',
      tags: ['kurinda inda', 'ubwiyunge', 'uburyo'],
    ),
    FAQItem(
      question: 'Ni gute nkoresha ijwi mu app?',
      answer: 'Kugira ngo ukoreshe ijwi:\n1. Kanda button y\'ijwi (microphone)\n2. Tegereza ijwi "ding"\n3. Vuga icyo ushaka gukora\n4. App izakora icyo usabye\n\nUrugero: Vuga "Gukurikirana ubuzima" kugira ngo ugere ku gukurikirana ubuzima.',
      category: 'Gukoresha',
      tags: ['ijwi', 'voice', 'gukoresha'],
    ),
    FAQItem(
      question: 'Mbese nshobora gukoresha app nta murandasi?',
      answer: 'Yego! App ya Ubuzima ikora nta murandasi:\n• Amakuru yawe abikwa ku telefoni yawe\n• Ushobora gusoma amasomo\n• Ushobora gukurikirana ubuzima bwawe\n• Iyo murandasi ugarutse, amakuru azasync',
      category: 'Gukoresha',
      tags: ['offline', 'nta murandasi', 'sync'],
    ),
    FAQItem(
      question: 'Ni gute nshobora guhindura ururimi?',
      answer: 'Kugira ngo uhindure ururimi:\n1. Jya ku "Umwirondoro"\n2. Hitamo "Igenamiterere"\n3. Hitamo "Ururimi"\n4. Hitamo ururimi ushaka\n5. App izahinduka mu rurimi rwahisemo',
      category: 'Igenamiterere',
      tags: ['ururimi', 'language', 'guhindura'],
    ),
    FAQItem(
      question: 'Amakuru yanjye ni amahanga?',
      answer: 'Yego, amakuru yawe ni amahanga cyane:\n• Amakuru yawe ashyirwa mu banga\n• Ntabwo dusangira amakuru yawe n\'abandi\n• Ukoresha encryption kugira ngo amakuru yawe abe amahanga\n• Wowe gusa ushobora kubona amakuru yawe',
      category: 'Ubwite',
      tags: ['ubwite', 'amahanga', 'umutekano'],
    ),
    FAQItem(
      question: 'Ni gute nshobora gusaba ubufasha?',
      answer: 'Hari inzira nyinshi zo gusaba ubufasha:\n• Koresha "Ubufasha" muri app\n• Hamagara 114 (ubufasha bw\'ubuzima)\n• Vugana n\'umujyanama w\'ubuzima\n• Ohereza email kuri support@ubuzima.rw',
      category: 'Ubufasha',
      tags: ['ubufasha', 'support', 'hamagara'],
    ),
    FAQItem(
      question: 'Ni gute nkurikirana imihango yanjye?',
      answer: 'Kugira ngo ukurikire imihango yawe:\n1. Jya ku "Gukurikirana ubuzima"\n2. Hitamo "Imihango"\n3. Andika itariki y\'imihango yawe ya nyuma\n4. App izakugirira calendar\n5. Uzabona amamenyo mbere y\'imihango',
      category: 'Ubuzima',
      tags: ['imihango', 'gukurikirana', 'calendar'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Ibibazo bikunze kubazwa'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(isTablet),
          Expanded(
            child: _buildFAQList(isTablet),
          ),
        ],
      ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga ikibazo cyawe cyangwa "Gushaka" kugira ngo ushake',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gushaka ibibazo',
      ),
    );
  }

  Widget _buildSearchAndFilter(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Shakisha ibibazo...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          SizedBox(height: AppTheme.spacing16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'all',
                'Konti',
                'Ubwiyunge',
                'Gukoresha',
                'Igenamiterere',
                'Ubwite',
                'Ubufasha',
                'Ubuzima'
              ].map((category) {
                final isSelected = _selectedCategory == category;
                return Container(
                  margin: EdgeInsets.only(right: AppTheme.spacing8),
                  child: FilterChip(
                    label: Text(category == 'all' ? 'Byose' : category),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => _selectedCategory = category),
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQList(bool isTablet) {
    final filteredFAQs = _faqItems.where((faq) {
      final matchesSearch = faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      
      final matchesCategory = _selectedCategory == 'all' || faq.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();

    if (filteredFAQs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: isTablet ? 64 : 48,
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: AppTheme.spacing16),
            Text(
              'Nta bibazo biboneka',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textTertiary),
            ),
            SizedBox(height: AppTheme.spacing8),
            TextButton(
              onPressed: () => setState(() {
                _searchQuery = '';
                _selectedCategory = 'all';
              }),
              child: const Text('Garura byose'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
      itemCount: filteredFAQs.length,
      itemBuilder: (context, index) {
        final faq = filteredFAQs[index];
        return _buildFAQCard(faq, isTablet, index);
      },
    );
  }

  Widget _buildFAQCard(FAQItem faq, bool isTablet, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(AppTheme.spacing8),
          decoration: BoxDecoration(
            color: _getCategoryColor(faq.category).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(
            _getCategoryIcon(faq.category),
            color: _getCategoryColor(faq.category),
            size: 20,
          ),
        ),
        title: Text(
          faq.question,
          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          faq.category,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq.answer,
                  style: AppTheme.bodyMedium.copyWith(height: 1.5),
                ),
                SizedBox(height: AppTheme.spacing12),
                Wrap(
                  spacing: AppTheme.spacing8,
                  runSpacing: AppTheme.spacing4,
                  children: faq.tags.map((tag) => Chip(
                    label: Text(
                      tag,
                      style: AppTheme.bodySmall,
                    ),
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    side: BorderSide.none,
                  )).toList(),
                ),
                SizedBox(height: AppTheme.spacing12),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _markHelpful(faq),
                      icon: const Icon(Icons.thumb_up_outlined, size: 16),
                      label: const Text('Byafasha'),
                    ),
                    TextButton.icon(
                      onPressed: () => _markNotHelpful(faq),
                      icon: const Icon(Icons.thumb_down_outlined, size: 16),
                      label: const Text('Ntibifasha'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Konti':
        return AppTheme.primaryColor;
      case 'Ubwiyunge':
        return AppTheme.secondaryColor;
      case 'Gukoresha':
        return AppTheme.accentColor;
      case 'Igenamiterere':
        return AppTheme.warningColor;
      case 'Ubwite':
        return AppTheme.errorColor;
      case 'Ubufasha':
        return AppTheme.successColor;
      case 'Ubuzima':
        return AppTheme.primaryColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Konti':
        return Icons.account_circle;
      case 'Ubwiyunge':
        return Icons.family_restroom;
      case 'Gukoresha':
        return Icons.help_outline;
      case 'Igenamiterere':
        return Icons.settings;
      case 'Ubwite':
        return Icons.privacy_tip;
      case 'Ubufasha':
        return Icons.support_agent;
      case 'Ubuzima':
        return Icons.health_and_safety;
      default:
        return Icons.help_outline;
    }
  }

  void _handleVoiceCommand(String command) {
    setState(() => _searchQuery = command);
  }

  void _markHelpful(FAQItem faq) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Murakoze! Igitekerezo cyawe cyafasha.')),
    );
  }

  void _markNotHelpful(FAQItem faq) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mbabarira. Tuzagerageza kunoza igisubizo.')),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;
  final List<String> tags;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
    required this.tags,
  });
}
