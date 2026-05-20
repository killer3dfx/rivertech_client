import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:rivertech_client/main.dart';
import 'package:rivertech_client/password_service.dart';
import 'package:rivertech_client/preferences.dart';

import 'brand.dart';
import 'l10n/app_localizations.dart';
import 'settings_screen.dart';
import 'status_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool trackingEnabled = false;
  bool? isMoving;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    final state = await bg.BackgroundGeolocation.state;
    setState(() {
      trackingEnabled = state.enabled;
      isMoving = state.isMoving;
    });
    bg.BackgroundGeolocation.onEnabledChange((bool enabled) {
      setState(() {
        trackingEnabled = enabled;
      });
    });
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      setState(() {
        isMoving = location.isMoving;
      });
    });
  }

  Color _trackingStateColor(ColorScheme colors) {
    if (!trackingEnabled) return colors.outline;
    if (isMoving == false) return RiverTechBrand.accent;
    return colors.secondary;
  }

  IconData _trackingStateIcon() {
    if (!trackingEnabled) return Icons.location_disabled_outlined;
    if (isMoving == false) return Icons.radio_button_checked;
    return Icons.near_me_outlined;
  }

  Future<void> _checkBatteryOptimizations(BuildContext context) async {
    try {
      if (!await bg.DeviceSettings.isIgnoringBatteryOptimizations) {
        final request =
            await bg.DeviceSettings.showIgnoreBatteryOptimizations();
        if (!request.seen && context.mounted) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  scrollable: true,
                  content: Text(
                    AppLocalizations.of(context)!.optimizationMessage,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        bg.DeviceSettings.show(request);
                      },
                      child: Text(AppLocalizations.of(context)!.okButton),
                    ),
                  ],
                ),
          );
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> _toggleTracking(bool value) async {
    if (!await PasswordService.authenticate(context) || !mounted) return;
    if (value) {
      try {
        FirebaseCrashlytics.instance.log('tracking_toggle_start');
        await bg.BackgroundGeolocation.start();
        if (mounted) {
          _checkBatteryOptimizations(context);
        }
      } on PlatformException catch (error) {
        final providerState = await bg.BackgroundGeolocation.providerState;
        final isPermissionError =
            providerState.status ==
                bg.ProviderChangeEvent.AUTHORIZATION_STATUS_DENIED ||
            providerState.status ==
                bg.ProviderChangeEvent.AUTHORIZATION_STATUS_RESTRICTED;
        if (!mounted) return;
        messengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(error.message ?? error.code),
            duration: const Duration(seconds: 4),
            action:
                isPermissionError
                    ? SnackBarAction(
                      label: AppLocalizations.of(context)!.settingsTitle,
                      onPressed:
                          () => AppSettings.openAppSettings(
                            type: AppSettingsType.settings,
                          ),
                    )
                    : null,
          ),
        );
      }
    } else {
      FirebaseCrashlytics.instance.log('tracking_toggle_stop');
      bg.BackgroundGeolocation.stop();
    }
  }

  Future<void> _sendLocation() async {
    try {
      await bg.BackgroundGeolocation.getCurrentPosition(
        samples: 1,
        persist: true,
        extras: {'manual': true},
      );
    } on PlatformException catch (error) {
      messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(error.message ?? error.code)),
      );
    }
  }

  Future<void> _openSettings() async {
    if (await PasswordService.authenticate(context) && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      );
      setState(() {});
    }
  }

  Widget _buildBrandHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(
            'assets/brand/rivertech_logo.png',
            height: 44,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
          ),
        ),
        const SizedBox(width: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/brand/rivertech_app_icon.png',
            width: 58,
            height: 58,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingPanel() {
    final colors = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final stateColor = _trackingStateColor(colors);
    final stateLabel =
        trackingEnabled
            ? localizations.trackingLabel
            : localizations.disabledValue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconBadge(_trackingStateIcon(), stateColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.trackingTitle,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stateLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: trackingEnabled,
                  activeTrackColor:
                      isMoving == false
                          ? RiverTechBrand.accent.withValues(alpha: 0.38)
                          : null,
                  onChanged: _toggleTracking,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildInfoRow(
              Icons.badge_outlined,
              localizations.idLabel,
              Preferences.instance.getString(Preferences.id) ?? '',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.dns_outlined,
              localizations.urlLabel,
              Preferences.instance.getString(Preferences.url) ?? '',
            ),
            if (Platform.isAndroid) ...[
              const SizedBox(height: 16),
              Text(
                localizations.disclosureMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _sendLocation,
                    icon: const Icon(Icons.my_location_outlined),
                    label: Text(
                      localizations.locationButton,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StatusScreen()),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: Text(
                      localizations.statusButton,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _openSettings,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              _buildIconBadge(
                Icons.tune_outlined,
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.settingsTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.settingsButton,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconBadge(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(RiverTechBrand.appName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBrandHeader(),
            const SizedBox(height: 24),
            _buildTrackingPanel(),
            const SizedBox(height: 12),
            _buildSettingsPanel(),
          ],
        ),
      ),
    );
  }
}
