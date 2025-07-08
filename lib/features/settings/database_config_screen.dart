import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/language_service.dart';
import '../../core/services/postgres_service.dart';

class DatabaseConfigScreen extends StatefulWidget {
  const DatabaseConfigScreen({super.key});

  @override
  State<DatabaseConfigScreen> createState() => _DatabaseConfigScreenState();
}

class _DatabaseConfigScreenState extends State<DatabaseConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _databaseController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isTestingConnection = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _databaseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadCurrentConfig() {
    // Set default values
    _hostController.text = 'localhost';
    _portController.text = '5432';
    _databaseController.text = 'ubuzima_db';
    _usernameController.text = 'postgres';
    _passwordController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _getTitle(languageService.currentLocale.languageCode),
              style: AppTheme.headingMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getInstructionsTitle(languageService.currentLocale.languageCode),
                            style: AppTheme.headingSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getInstructions(languageService.currentLocale.languageCode),
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getConfigTitle(languageService.currentLocale.languageCode),
                            style: AppTheme.headingSmall,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _hostController,
                            label: _getHostLabel(languageService.currentLocale.languageCode),
                            hint: 'localhost or IP address',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return _getRequiredFieldError(languageService.currentLocale.languageCode);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _portController,
                            label: _getPortLabel(languageService.currentLocale.languageCode),
                            hint: '5432',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return _getRequiredFieldError(languageService.currentLocale.languageCode);
                              }
                              final port = int.tryParse(value);
                              if (port == null || port < 1 || port > 65535) {
                                return _getInvalidPortError(languageService.currentLocale.languageCode);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _databaseController,
                            label: _getDatabaseLabel(languageService.currentLocale.languageCode),
                            hint: 'ubuzima_db',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return _getRequiredFieldError(languageService.currentLocale.languageCode);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _usernameController,
                            label: _getUsernameLabel(languageService.currentLocale.languageCode),
                            hint: 'postgres',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return _getRequiredFieldError(languageService.currentLocale.languageCode);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            label: _getPasswordLabel(languageService.currentLocale.languageCode),
                            hint: 'Enter password',
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return _getRequiredFieldError(languageService.currentLocale.languageCode);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isTestingConnection ? null : _testConnection,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.secondaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: _isTestingConnection
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(_getTestConnectionText(languageService.currentLocale.languageCode)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveConfiguration,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(_getSaveText(languageService.currentLocale.languageCode)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTestingConnection = true;
    });

    try {
      final postgresService = PostgresService();
      final success = await postgresService.testConnection(
        host: _hostController.text.trim(),
        port: int.parse(_portController.text.trim()),
        database: _databaseController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? 'Connection successful!' 
                : 'Connection failed. Please check your settings.',
            ),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTestingConnection = false;
        });
      }
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final postgresService = PostgresService();
      await postgresService.saveConfiguration(
        host: _hostController.text.trim(),
        port: int.parse(_portController.text.trim()),
        database: _databaseController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      // Try to initialize with new configuration
      final success = await postgresService.initialize();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? 'Configuration saved and connected successfully!' 
                : 'Configuration saved but connection failed.',
            ),
            backgroundColor: success ? AppTheme.successColor : AppTheme.warningColor,
          ),
        );

        if (success) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
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

  // Localization methods
  String _getTitle(String language) {
    switch (language) {
      case 'rw': return 'Igenamiterere rya Database';
      case 'fr': return 'Configuration Base de Données';
      default: return 'Database Configuration';
    }
  }

  String _getInstructionsTitle(String language) {
    switch (language) {
      case 'rw': return 'Amabwiriza';
      case 'fr': return 'Instructions';
      default: return 'Instructions';
    }
  }

  String _getInstructions(String language) {
    switch (language) {
      case 'rw': return 'Shyiramo amakuru ya PostgreSQL database yawe kugira ngo ubone amakuru nyayo.';
      case 'fr': return 'Entrez les détails de votre base de données PostgreSQL pour accéder aux données réelles.';
      default: return 'Enter your PostgreSQL database details to connect to real data.';
    }
  }

  String _getConfigTitle(String language) {
    switch (language) {
      case 'rw': return 'Igenamiterere rya Database';
      case 'fr': return 'Configuration';
      default: return 'Database Configuration';
    }
  }

  String _getHostLabel(String language) {
    switch (language) {
      case 'rw': return 'Host/Server';
      case 'fr': return 'Hôte/Serveur';
      default: return 'Host/Server';
    }
  }

  String _getPortLabel(String language) {
    switch (language) {
      case 'rw': return 'Port';
      case 'fr': return 'Port';
      default: return 'Port';
    }
  }

  String _getDatabaseLabel(String language) {
    switch (language) {
      case 'rw': return 'Izina rya Database';
      case 'fr': return 'Nom de la Base';
      default: return 'Database Name';
    }
  }

  String _getUsernameLabel(String language) {
    switch (language) {
      case 'rw': return 'Izina ry\'umukoresha';
      case 'fr': return 'Nom d\'utilisateur';
      default: return 'Username';
    }
  }

  String _getPasswordLabel(String language) {
    switch (language) {
      case 'rw': return 'Ijambo ry\'ibanga';
      case 'fr': return 'Mot de passe';
      default: return 'Password';
    }
  }

  String _getTestConnectionText(String language) {
    switch (language) {
      case 'rw': return 'Gerageza';
      case 'fr': return 'Tester';
      default: return 'Test Connection';
    }
  }

  String _getSaveText(String language) {
    switch (language) {
      case 'rw': return 'Bika';
      case 'fr': return 'Enregistrer';
      default: return 'Save & Connect';
    }
  }

  String _getRequiredFieldError(String language) {
    switch (language) {
      case 'rw': return 'Iki gice ni ngombwa';
      case 'fr': return 'Ce champ est requis';
      default: return 'This field is required';
    }
  }

  String _getInvalidPortError(String language) {
    switch (language) {
      case 'rw': return 'Port ntabwo ari yo';
      case 'fr': return 'Port invalide';
      default: return 'Invalid port number';
    }
  }
}
