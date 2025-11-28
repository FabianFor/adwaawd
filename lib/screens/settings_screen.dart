import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart'; // ✅ CORREGIDO
import '../providers/settings_provider.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: TextStyle(fontSize: 18.sp)),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        children: [
          // ==================== MONEDA ====================
          _buildSectionHeader(
            context,
            icon: Icons.attach_money,
            title: l10n.currency, // ✅ TRADUCIDO
            subtitle: _getCurrencySubtitle(l10n), // ✅ TRADUCIDO
          ),
          
          _buildCurrencyTile(
            context,
            currentCode: settingsProvider.currencyCode,
            onTap: () => _showCurrencySelector(context),
          ),

          Divider(height: 32.h, thickness: 1),

          // ==================== IDIOMA ====================
          _buildSectionHeader(
            context,
            icon: Icons.language,
            title: l10n.language, // ✅ TRADUCIDO
            subtitle: _getLanguageSubtitle(l10n), // ✅ TRADUCIDO
          ),
          
          _buildLanguageTile(
            context,
            currentLocale: settingsProvider.locale,
            onTap: () => _showLanguageSelector(context),
          ),

          Divider(height: 32.h, thickness: 1),

          // ==================== PERFIL DEL NEGOCIO ====================
          _buildSectionHeader(
            context,
            icon: Icons.store,
            title: l10n.businessProfile, // ✅ TRADUCIDO
            subtitle: _getBusinessSubtitle(l10n), // ✅ TRADUCIDO
          ),
          
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.edit,
                color: const Color(0xFF2196F3),
                size: 24.sp,
              ),
            ),
            title: Text(
              _getEditProfileText(l10n), // ✅ TRADUCIDO
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              _getEditProfileSubtitle(l10n), // ✅ TRADUCIDO
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          SizedBox(height: 24.h),

          // ==================== VERSIÓN ====================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Center(
              child: Text(
                'MiNegocio v1.0.0',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Funciones helper para traducciones dinámicas
  String _getCurrencySubtitle(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Selecciona tu moneda preferida';
      case 'en':
        return 'Select your preferred currency';
      case 'pt':
        return 'Selecione sua moeda preferida';
      case 'zh':
        return '选择您的首选货币';
      default:
        return 'Select your preferred currency';
    }
  }

  String _getLanguageSubtitle(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Selecciona tu idioma preferido';
      case 'en':
        return 'Select your preferred language';
      case 'pt':
        return 'Selecione seu idioma preferido';
      case 'zh':
        return '选择您的首选语言';
      default:
        return 'Select your preferred language';
    }
  }

  String _getBusinessSubtitle(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Configura la información de tu negocio';
      case 'en':
        return 'Configure your business information';
      case 'pt':
        return 'Configure as informações do seu negócio';
      case 'zh':
        return '配置您的业务信息';
      default:
        return 'Configure your business information';
    }
  }

  String _getEditProfileText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Editar perfil';
      case 'en':
        return 'Edit profile';
      case 'pt':
        return 'Editar perfil';
      case 'zh':
        return '编辑资料';
      default:
        return 'Edit profile';
    }
  }

  String _getEditProfileSubtitle(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Nombre, logo, contacto, etc.';
      case 'en':
        return 'Name, logo, contact, etc.';
      case 'pt':
        return 'Nome, logo, contato, etc.';
      case 'zh':
        return '名称、徽标、联系方式等';
      default:
        return 'Name, logo, contact, etc.';
    }
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: const Color(0xFF2196F3)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyTile(
    BuildContext context, {
    required String currentCode,
    required VoidCallback onTap,
  }) {
    final currency = SettingsProvider.supportedCurrencies[currentCode]!;
    
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          currency['flag']!,
          style: TextStyle(fontSize: 24.sp),
        ),
      ),
      title: Text(
        currency['name']!,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${currency['symbol']} - $currentCode',
        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
      onTap: onTap,
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required Locale currentLocale,
    required VoidCallback onTap,
  }) {
    final language = SettingsProvider.supportedLanguages[currentLocale.languageCode]!;
    
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          language['flag']!,
          style: TextStyle(fontSize: 24.sp),
        ),
      ),
      title: Text(
        language['name']!,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        currentLocale.languageCode.toUpperCase(),
        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
      onTap: onTap,
    );
  }

  void _showCurrencySelector(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              _getSelectCurrencyText(l10n), // ✅ TRADUCIDO
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: SettingsProvider.supportedCurrencies.length,
                itemBuilder: (context, index) {
                  final code = SettingsProvider.supportedCurrencies.keys.elementAt(index);
                  final currency = SettingsProvider.supportedCurrencies[code]!;
                  final isSelected = code == settingsProvider.currencyCode;
                  
                  return ListTile(
                    leading: Text(currency['flag']!, style: TextStyle(fontSize: 28.sp)),
                    title: Text(
                      currency['name']!,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${currency['symbol']} - $code',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Colors.green, size: 24.sp)
                        : null,
                    onTap: () {
                      settingsProvider.setCurrency(code);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ ${_getCurrencyChangedText(l10n)} ${currency['name']}'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              _getSelectLanguageText(l10n), // ✅ TRADUCIDO
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            ...SettingsProvider.supportedLanguages.entries.map((entry) {
              final code = entry.key;
              final language = entry.value;
              final isSelected = code == settingsProvider.locale.languageCode;
              
              return ListTile(
                leading: Text(language['flag']!, style: TextStyle(fontSize: 28.sp)),
                title: Text(
                  language['name']!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  code.toUpperCase(),
                  style: TextStyle(fontSize: 13.sp),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Colors.green, size: 24.sp)
                    : null,
                onTap: () {
                  settingsProvider.setLanguage(code);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ ${_getLanguageChangedText(l10n)} ${language['name']}'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getSelectCurrencyText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Seleccionar Moneda';
      case 'en':
        return 'Select Currency';
      case 'pt':
        return 'Selecionar Moeda';
      case 'zh':
        return '选择货币';
      default:
        return 'Select Currency';
    }
  }

  String _getSelectLanguageText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Seleccionar Idioma';
      case 'en':
        return 'Select Language';
      case 'pt':
        return 'Selecionar Idioma';
      case 'zh':
        return '选择语言';
      default:
        return 'Select Language';
    }
  }

  String _getCurrencyChangedText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Moneda cambiada a';
      case 'en':
        return 'Currency changed to';
      case 'pt':
        return 'Moeda alterada para';
      case 'zh':
        return '货币已更改为';
      default:
        return 'Currency changed to';
    }
  }

  String _getLanguageChangedText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es':
        return 'Idioma cambiado a';
      case 'en':
        return 'Language changed to';
      case 'pt':
        return 'Idioma alterado para';
      case 'zh':
        return '语言已更改为';
      default:
        return 'Language changed to';
    }
  }
}
