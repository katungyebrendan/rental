import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _privacyPolicyUrl = 'https://rental-e533e.web.app/privacy-policy';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailUpdates = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111111)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFD9AE)),
                ),
                child: const Text(
                  'Manage your account preferences and privacy from one place.',
                  style: TextStyle(
                    color: Color(0xFF7E5A2A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _SettingsCard(
                title: 'Notifications',
                children: [
                  SwitchListTile.adaptive(
                    value: _pushNotifications,
                    activeThumbColor: const Color(0xFFFF4967),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Push notifications'),
                    subtitle: const Text(
                      'Messages and property activity alerts',
                    ),
                    onChanged: (value) {
                      setState(() => _pushNotifications = value);
                    },
                  ),
                  const Divider(height: 18),
                  SwitchListTile.adaptive(
                    value: _emailUpdates,
                    activeThumbColor: const Color(0xFFFF4967),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Email updates'),
                    subtitle: const Text(
                      'Occasional product and feature updates',
                    ),
                    onChanged: (value) {
                      setState(() => _emailUpdates = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _SettingsCard(
                title: 'Appearance',
                children: [
                  SwitchListTile.adaptive(
                    value: _darkMode,
                    activeThumbColor: const Color(0xFFFF4967),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark mode'),
                    subtitle: const Text(
                      'Reduce brightness in low-light environments',
                    ),
                    onChanged: (value) {
                      setState(() => _darkMode = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _SettingsCard(
                title: 'Legal',
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Policy'),
                    subtitle: const Text(
                      'How Rentals App handles your information',
                    ),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 20),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.maybeOf(context);
                      final opened = await launchUrl(
                        Uri.parse(_privacyPolicyUrl),
                        mode: LaunchMode.externalApplication,
                      );
                      if (!opened && mounted) {
                        messenger?.showSnackBar(
                          const SnackBar(
                            content: Text('Could not open the Privacy Policy.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E3DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}
