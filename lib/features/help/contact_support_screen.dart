import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/voice_button.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _selectedCategory = 'general';
  String _selectedPriority = 'medium';
  bool _isSubmitting = false;

  final List<ContactMethod> _contactMethods = [
    ContactMethod(
      title: 'Hamagara',
      description: 'Hamagara ubufasha bw\'ihutirwa',
      icon: Icons.phone,
      color: AppTheme.primaryColor,
      action: '114',
      actionLabel: 'Hamagara 114',
    ),
    ContactMethod(
      title: 'WhatsApp',
      description: 'Tuvugane kuri WhatsApp',
      icon: Icons.chat,
      color: AppTheme.successColor,
      action: '+250788123456',
      actionLabel: 'Fungura WhatsApp',
    ),
    ContactMethod(
      title: 'Email',
      description: 'Ohereza email',
      icon: Icons.email,
      color: AppTheme.secondaryColor,
      action: 'support@ubuzima.rw',
      actionLabel: 'Ohereza email',
    ),
    ContactMethod(
      title: 'Ubufasha bw\'ihutirwa',
      description: 'Igihe cy\'ihutirwa cy\'ubuzima',
      icon: Icons.emergency,
      color: AppTheme.errorColor,
      action: '912',
      actionLabel: 'Hamagara 912',
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase();
    if (lowerCommand.contains('ohereza') || lowerCommand.contains('send')) {
      _submitForm();
    } else if (lowerCommand.contains('hamagara') || lowerCommand.contains('call')) {
      _makeCall('114');
    } else if (lowerCommand.contains('ihutirwa') || lowerCommand.contains('emergency')) {
      _makeCall('912');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Hamagara ubufasha'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? AppTheme.spacing24 : AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactMethods(isTablet),
            SizedBox(height: AppTheme.spacing32),
            _buildContactForm(isTablet),
          ],
        ),
      ),
      floatingActionButton: VoiceButton(
        prompt: 'Vuga: "Ohereza" kugira ngo wohereze ubutumwa, "Hamagara" kugira ngo uhamagare, cyangwa "Ihutirwa" kugira ngo uhamagare ubufasha bw\'ihutirwa',
        onResult: _handleVoiceCommand,
        tooltip: 'Koresha ijwi gusaba ubufasha',
      ),
    );
  }

  Widget _buildContactMethods(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inzira zo gusaba ubufasha',
          style: AppTheme.headingMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppTheme.spacing16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 2 : 1,
            crossAxisSpacing: AppTheme.spacing16,
            mainAxisSpacing: AppTheme.spacing16,
            childAspectRatio: isTablet ? 2.5 : 3.5,
          ),
          itemCount: _contactMethods.length,
          itemBuilder: (context, index) {
            final method = _contactMethods[index];
            return _buildContactMethodCard(method, isTablet, index);
          },
        ),
      ],
    );
  }

  Widget _buildContactMethodCard(ContactMethod method, bool isTablet, int index) {
    return Card(
      child: InkWell(
        onTap: () => _handleContactMethod(method),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing16),
          child: Row(
            children: [
              Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                decoration: BoxDecoration(
                  color: method.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 30 : 25),
                ),
                child: Icon(
                  method.icon,
                  color: method.color,
                  size: isTablet ? 28 : 24,
                ),
              ),
              SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      method.title,
                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      method.description,
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                    ),
                    SizedBox(height: AppTheme.spacing8),
                    Text(
                      method.actionLabel,
                      style: AppTheme.bodySmall.copyWith(
                        color: method.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX();
  }

  Widget _buildContactForm(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.softShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ohereza ubutumwa',
              style: AppTheme.headingMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacing16),
            
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Amazina yawe',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Andika amazina yawe';
                }
                return null;
              },
            ),
            SizedBox(height: AppTheme.spacing16),
            
            // Email field
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email yawe',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Andika email yawe';
                }
                if (!value.contains('@')) {
                  return 'Andika email nyayo';
                }
                return null;
              },
            ),
            SizedBox(height: AppTheme.spacing16),
            
            // Phone field
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefoni yawe',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: AppTheme.spacing16),
            
            // Category dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Ubwoko bw\'ikibazo',
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('Rusange')),
                DropdownMenuItem(value: 'technical', child: Text('Tekinike')),
                DropdownMenuItem(value: 'health', child: Text('Ubuzima')),
                DropdownMenuItem(value: 'account', child: Text('Konti')),
                DropdownMenuItem(value: 'billing', child: Text('Kwishyura')),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            SizedBox(height: AppTheme.spacing16),
            
            // Priority dropdown
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Ubwihuse',
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Buke')),
                DropdownMenuItem(value: 'medium', child: Text('Hagati')),
                DropdownMenuItem(value: 'high', child: Text('Byihutirwa')),
                DropdownMenuItem(value: 'urgent', child: Text('Byihutirwa cyane')),
              ],
              onChanged: (value) => setState(() => _selectedPriority = value!),
            ),
            SizedBox(height: AppTheme.spacing16),
            
            // Subject field
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Ingingo',
                prefixIcon: Icon(Icons.subject),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Andika ingingo';
                }
                return null;
              },
            ),
            SizedBox(height: AppTheme.spacing16),
            
            // Message field
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Ubutumwa',
                prefixIcon: Icon(Icons.message),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Andika ubutumwa';
                }
                return null;
              },
            ),
            SizedBox(height: AppTheme.spacing24),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitForm,
                icon: _isSubmitting 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSubmitting ? 'Irohereza...' : 'Ohereza ubutumwa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? AppTheme.spacing20 : AppTheme.spacing16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  void _handleContactMethod(ContactMethod method) {
    switch (method.title) {
      case 'Hamagara':
        _makeCall(method.action);
        break;
      case 'WhatsApp':
        _openWhatsApp(method.action);
        break;
      case 'Email':
        _sendEmail(method.action);
        break;
      case 'Ubufasha bw\'ihutirwa':
        _makeCall(method.action);
        break;
    }
  }

  void _makeCall(String number) {
    // TODO: Implement phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Guhamagara $number - Izaza vuba...')),
    );
  }

  void _openWhatsApp(String number) {
    // TODO: Implement WhatsApp
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gufungura WhatsApp $number - Izaza vuba...')),
    );
  }

  void _sendEmail(String email) {
    // TODO: Implement email
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kohereza email kuri $email - Izaza vuba...')),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // TODO: Submit form to API
      await Future.delayed(const Duration(seconds: 2));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubutumwa bwoherejwe neza! Tuzagusubiza vuba.')),
      );
      
      // Clear form
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _subjectController.clear();
      _messageController.clear();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habaye ikosa. Ongera ugerageze.')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

class ContactMethod {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String action;
  final String actionLabel;

  ContactMethod({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.action,
    required this.actionLabel,
  });
}
