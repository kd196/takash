import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/providers/theme_provider.dart';
import '../../auth/data/auth_repository.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationSharing = true;
  bool _profileVisibility = true;
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadVersion();
  }

  Future<void> _loadSettings() async {
    final service = ref.read(settingsServiceProvider);
    final notifications = await service.getNotificationsEnabled();
    final location = await service.getLocationSharing();
    final visibility = await service.getProfileVisibility();
    setState(() {
      _notificationsEnabled = notifications;
      _locationSharing = location;
      _profileVisibility = visibility == 'public';
    });
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _version = '${info.version}+${info.buildNumber}';
      });
    } catch (_) {}
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          // ── HESAP ──
          _buildSectionHeader('Hesap'),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('E-posta Değiştir'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/change-email'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Şifre Değiştir'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/change-password'),
          ),

          // ── GÖRÜNÜM ──
          _buildSectionHeader('Görünüm'),
          RadioListTile<ThemeMode>(
            title: const Text('Açık Tema'),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Koyu Tema'),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Sistem Varsayılanı'),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),

          // ── BİLDİRİMLER ──
          _buildSectionHeader('Bildirimler'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Push Bildirimleri'),
            subtitle: const Text('Mesaj ve takas bildirimleri'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              await ref
                  .read(settingsServiceProvider)
                  .setNotificationsEnabled(value);
            },
          ),

          // ── GİZLİLİK ──
          _buildSectionHeader('Gizlilik'),
          SwitchListTile(
            secondary: const Icon(Icons.location_on_outlined),
            title: const Text('Konum Paylaşımı'),
            subtitle: const Text('Yakındaki kullanıcılara görün'),
            value: _locationSharing,
            onChanged: (value) async {
              setState(() => _locationSharing = value);
              await ref.read(settingsServiceProvider).setLocationSharing(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_outlined),
            title: const Text('Profil Görünürlüğü'),
            subtitle: const Text('Profiliniz herkese açık'),
            value: _profileVisibility,
            onChanged: (value) async {
              setState(() => _profileVisibility = value);
              await ref
                  .read(settingsServiceProvider)
                  .setProfileVisibility(value ? 'public' : 'private');
            },
          ),

          // ── DESTEK ──
          _buildSectionHeader('Destek'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Yardım Merkezi'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _launchUrl('https://takash.app/yardim'),
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail_outlined),
            title: const Text('Bize Ulaşın'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _launchUrl('mailto:destek@takash.app'),
          ),

          // ── HAKKINDA ──
          _buildSectionHeader('Hakkında'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versiyon'),
            trailing: Text(_version,
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Gizlilik Politikası'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _launchUrl('https://takash.app/gizlilik'),
          ),

          const SizedBox(height: 16),

          // ── ÇIKIŞ YAP ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Çıkış Yap'),
                    content:
                        const Text('Çıkış yapmak istediğinize emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            await ref.read(authRepositoryProvider).signOut();
                          } catch (_) {}
                          if (context.mounted) {
                            context.go('/');
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.error,
                        ),
                        child: const Text('Çıkış Yap'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout, color: colorScheme.error),
              label:
                  Text('Çıkış Yap', style: TextStyle(color: colorScheme.error)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
