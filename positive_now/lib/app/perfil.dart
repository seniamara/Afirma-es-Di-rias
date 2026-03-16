import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:positive_now/providers/theme_provider.dart';
import 'package:positive_now/providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/afirmacao_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'auth/login_screen.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool _notificationsEnabled = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  List<bool> _selectedDays = List.generate(7, (index) => true);

  final List<String> _weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final afirmacaoProvider = Provider.of<AfirmacaoProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('profile')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do perfil
            _buildProfileHeader(authProvider, localizations),
            
            const SizedBox(height: 24),
            
            // Se não for anônimo, mostrar informações da conta
            if (!authProvider.isAnonymous) ...[
              _buildAccountInfo(authProvider, localizations),
              const SizedBox(height: 24),
            ],
            
            // Configurações
            Text(
              localizations.translate('settings'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Notificações
            _buildNotificationSettings(localizations),
            
            const SizedBox(height: 16),
            
            // Tema
            _buildThemeSetting(themeProvider, localizations),
            
            const SizedBox(height: 16),
            
            // Horários
            _buildTimeSettings(localizations),
            
            const SizedBox(height: 16),
            
            // Seletor de Idioma
            _buildLanguageSelector(localeProvider, localizations),
            
            const SizedBox(height: 24),
            
            // Estatísticas completas
            Text(
              localizations.translate('complete_stats'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildStatisticsComplete(afirmacaoProvider, localizations),
            
            const SizedBox(height: 24),
            
            // Sobre
            _buildAboutSection(localizations),
            
            const SizedBox(height: 16),
            
            // Botão de sair
            _buildLogoutButton(authProvider, localizations),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPink,
            AppColors.darkPink,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                authProvider.userName != null
                    ? authProvider.userName![0].toUpperCase()
                    : authProvider.isAnonymous
                        ? '👤'
                        : 'U',
                style: TextStyle(
                  fontSize: authProvider.isAnonymous ? 40 : 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkPink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // Informações do usuário
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.userName ?? 
                      (authProvider.isAnonymous 
                          ? localizations.translate('anonymous_account') 
                          : 'Usuário'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                if (!authProvider.isAnonymous && authProvider.userEmail != null)
                  Text(
                    authProvider.userEmail!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    authProvider.isAnonymous 
                        ? localizations.translate('anonymous_account')
                        : localizations.translate('registered_account'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(AuthProvider authProvider, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.email, color: AppColors.darkPink),
            title: Text(localizations.translate('email')),
            subtitle: Text(authProvider.userEmail ?? ''),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: AppColors.darkPink),
            title: Text(localizations.translate('member_since')),
            subtitle: const Text('Fevereiro 2025'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(localizations.translate('notifications')),
            subtitle: Text(localizations.translate('receive_daily_reminders')),
            value: _notificationsEnabled,
            activeColor: AppColors.darkPink,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          if (_notificationsEnabled) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.access_time, color: AppColors.darkPink),
              title: Text(localizations.translate('preferred_time')),
              subtitle: Text(_selectedTime.format(context)),
              onTap: _selectTime,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                localizations.translate('week_days'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDays[index] = !_selectedDays[index];
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedDays[index]
                          ? AppColors.primaryPink
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedDays[index]
                            ? Colors.transparent
                            : AppColors.greyMedium,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _weekDays[index],
                        style: TextStyle(
                          color: _selectedDays[index]
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeSetting(ThemeProvider themeProvider, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.dark_mode, color: AppColors.darkPink),
              const SizedBox(width: 16),
              Text(
                localizations.translate('dark_theme'),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (_) => themeProvider.toggleTheme(),
            activeColor: AppColors.darkPink,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSettings(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.timer, color: AppColors.darkPink),
            title: const Text('Timer de foco'),
            subtitle: const Text('25 minutos'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.greyMedium),
          ),
          ListTile(
            leading: const Icon(Icons.repeat, color: AppColors.darkPink),
            title: const Text('Lembretes diários'),
            subtitle: const Text('2x ao dia'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.greyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(LocaleProvider provider, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Idioma / Language',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLanguageButton('🇧🇷', 'pt', provider),
              _buildLanguageButton('🇺🇸', 'en', provider),
              _buildLanguageButton('🇩🇪', 'de', provider),
              _buildLanguageButton('🇫🇷', 'fr', provider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String flag, String code, LocaleProvider provider) {
    final isSelected = provider.locale.languageCode == code;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => provider.setLocale(code),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primaryPink, AppColors.darkPink],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.transparent : (isDark ? Colors.grey[600]! : AppColors.greyMedium),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            flag,
            style: TextStyle(
              fontSize: 24,
              color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsComplete(AfirmacaoProvider provider, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatItem(
            localizations.translate('total_affirmations'),
            '${provider.historico.length}',
            Icons.remove_red_eye,
          ),
          _buildStatItem(
            localizations.translate('favorite_count'),
            '${provider.favoritos.length}',
            Icons.favorite,
          ),
          _buildStatItem(
            localizations.translate('active_days'),
            '${provider.registrosHumor.length}',
            Icons.calendar_today,
          ),
          _buildStatItem(
            localizations.translate('average_mood'),
            provider.registrosHumor.isEmpty
                ? '-'
                : (provider.registrosHumor
                        .map((r) => r.humor)
                        .reduce((a, b) => a + b) /
                    provider.registrosHumor.length)
                    .toStringAsFixed(1),
            Icons.emoji_emotions,
          ),
          _buildStatItem(
            localizations.translate('current_streak'),
            '${provider.streakAtual} ${provider.streakAtual == 1 ? localizations.translate('day') : localizations.translate('days')}',
            Icons.local_fire_department,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.darkPink,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.darkPink),
            title: Text(localizations.translate('about')),
            subtitle: Text(localizations.translate('version')),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.darkPink),
            title: Text(localizations.translate('privacy_policy')),
            trailing: const Icon(Icons.chevron_right, color: AppColors.greyMedium),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.darkPink),
            title: Text(localizations.translate('help')),
            trailing: const Icon(Icons.chevron_right, color: AppColors.greyMedium),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider, AppLocalizations localizations) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: TextButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(localizations.translate('logout')),
              content: Text(localizations.translate('logout_confirm')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(localizations.translate('cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: Text(localizations.translate('logout')),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await authProvider.signOut();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          }
        },
        child: Text(
          localizations.translate('logout'),
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkPink,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
}