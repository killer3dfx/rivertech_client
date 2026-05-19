import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rivertech_client/main.dart';
import 'package:rivertech_client/password_service.dart';
import 'package:rivertech_client/preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

import 'brand.dart';
import 'l10n/app_localizations.dart';
import 'status_screen.dart';
import 'settings_screen.dart';

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
    if (isMoving == false) return colors.tertiary;
    return colors.secondary;
  }

  IconData _trackingStateIcon() {
    if (!trackingEnabled) return Icons.pause_circle_outline;
    if (isMoving == false) return Icons.anchor_outlined;
    return Icons.navigation_outlined;
  }

  Widget _buildHeader() {
    final colors = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final deviceId = Preferences.instance.getString(Preferences.id) ?? '';
    final serverUrl = Preferences.instance.getString(Preferences.url) ?? '';
    final stateColor = _trackingStateColor(colors);
    final stateLabel = trackingEnabled
        ? localizations.trackingLabel
        : localizations.disabledValue;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RiverTechBrand.deepWater, RiverTechBrand.harborBlue],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const RiverTechMark(size: 46),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        RiverTechBrand.gatewayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        RiverTechBrand.appName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildStatusChip(stateColor, stateLabel),
                _buildHeaderMetric(
                  Icons.badge_outlined,
                  localizations.idLabel,
                  deviceId,
                ),
                _buildHeaderMetric(
                  Icons.dns_outlined,
                  localizations.urlLabel,
                  serverUrl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Color stateColor, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_trackingStateIcon(), color: stateColor, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMetric(IconData icon, String label, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 148, maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: RiverTechBrand.aqua, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.white60),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkBatteryOptimizations(BuildContext context) async {
    try {
      if (!await bg.DeviceSettings.isIgnoringBatteryOptimizations) {
        final request =
            await bg.DeviceSettings.showIgnoreBatteryOptimizations();
        if (!request.seen && context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              scrollable: true,
              content: Text(AppLocalizations.of(context)!.optimizationMessage),
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

  Widget _buildTrackingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sensors_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.trackingTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.badge_outlined),
              title: Text(AppLocalizations.of(context)!.idLabel),
              subtitle: Text(
                Preferences.instance.getString(Preferences.id) ?? '',
              ),
            ),
            if (Platform.isAndroid) ...[
              Text(
                AppLocalizations.of(context)!.disclosureMessage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(_trackingStateIcon()),
              title: Text(AppLocalizations.of(context)!.trackingLabel),
              value: trackingEnabled,
              activeTrackColor: isMoving == false
                  ? Theme.of(context).colorScheme.secondary
                  : null,
              onChanged: (bool value) async {
                if (await PasswordService.authenticate(context) && mounted) {
                  if (value) {
                    try {
                      FirebaseCrashlytics.instance.log('tracking_toggle_start');
                      await bg.BackgroundGeolocation.start();
                      if (mounted) {
                        _checkBatteryOptimizations(context);
                      }
                    } on PlatformException catch (error) {
                      final providerState =
                          await bg.BackgroundGeolocation.providerState;
                      final isPermissionError =
                          providerState.status ==
                              bg
                                  .ProviderChangeEvent
                                  .AUTHORIZATION_STATUS_DENIED ||
                          providerState.status ==
                              bg
                                  .ProviderChangeEvent
                                  .AUTHORIZATION_STATUS_RESTRICTED;
                      if (!mounted) return;
                      messengerKey.currentState?.showSnackBar(
                        SnackBar(
                          content: Text(error.message ?? error.code),
                          duration: const Duration(seconds: 4),
                          action: isPermissionError
                              ? SnackBarAction(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.settingsTitle,
                                  onPressed: () => AppSettings.openAppSettings(
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
              },
            ),
            const SizedBox(height: 8),
            OverflowBar(
              spacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () async {
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
                  },
                  icon: const Icon(Icons.my_location_outlined),
                  label: Text(AppLocalizations.of(context)!.locationButton),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatusScreen()),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: Text(AppLocalizations.of(context)!.statusButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.settingsTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.dns_outlined),
              title: Text(AppLocalizations.of(context)!.urlLabel),
              subtitle: Text(
                Preferences.instance.getString(Preferences.url) ?? '',
              ),
            ),
            const SizedBox(height: 8),
            OverflowBar(
              spacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () async {
                    if (await PasswordService.authenticate(context) &&
                        mounted) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.settings_outlined),
                  label: Text(AppLocalizations.of(context)!.settingsButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(RiverTechBrand.appName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTrackingCard(),
            const SizedBox(height: 16),
            _buildSettingsCard(),
          ],
        ),
      ),
    );
  }
}
