import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkModeEnabled = false;
  bool _colorblindModeEnabled = false;
  double _soundVolume = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Audio & Haptics'),
          _buildSwitchTile(
            'Sound Effects',
            'Enable game sound effects',
            Icons.volume_up,
            _soundEnabled,
            (value) => setState(() => _soundEnabled = value),
          ),
          if (_soundEnabled) ...[
            _buildSliderTile(
              'Sound Volume',
              Icons.volume_down,
              _soundVolume,
              (value) => setState(() => _soundVolume = value),
            ),
          ],
          _buildSwitchTile(
            'Vibration',
            'Enable haptic feedback',
            Icons.vibration,
            _vibrationEnabled,
            (value) => setState(() => _vibrationEnabled = value),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Display'),
          _buildSwitchTile(
            'Dark Mode',
            'Use dark theme',
            Icons.dark_mode,
            _darkModeEnabled,
            (value) => setState(() => _darkModeEnabled = value),
          ),
          _buildSwitchTile(
            'Colorblind Mode',
            'Optimize colors for colorblind users',
            Icons.accessibility,
            _colorblindModeEnabled,
            (value) => setState(() => _colorblindModeEnabled = value),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Game'),
          _buildListTile(
            'Reset Progress',
            'Clear all saved progress',
            Icons.refresh,
            () => _showResetProgressDialog(),
          ),
          _buildListTile(
            'Tutorial',
            'Show tutorial again',
            Icons.help_outline,
            () => _showTutorial(),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildListTile(
            'Version',
            '1.0.0',
            Icons.info_outline,
            null,
          ),
          _buildListTile(
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip_outlined,
            () => _showPrivacyPolicy(),
          ),
          _buildListTile(
            'Terms of Service',
            'Read our terms of service',
            Icons.description_outlined,
            () => _showTermsOfService(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon, color: AppTheme.primaryColor),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    IconData icon,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 16),
                Text(title),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: value,
              onChanged: onChanged,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: '${(value * 100).round()}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(icon, color: AppTheme.primaryColor),
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios) : null,
        onTap: onTap,
      ),
    );
  }

  void _showResetProgressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'Are you sure you want to reset all progress? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement reset progress
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showTutorial() {
    // TODO: Implement tutorial
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tutorial coming soon!')),
    );
  }

  void _showPrivacyPolicy() {
    // TODO: Implement privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy coming soon!')),
    );
  }

  void _showTermsOfService() {
    // TODO: Implement terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service coming soon!')),
    );
  }
}
