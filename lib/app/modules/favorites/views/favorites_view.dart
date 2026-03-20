import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.primaryTextColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Mes préférences',
          style: context.h5.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Notifications
            _buildSectionTitle(context, 'Notifications'),
            SizedBox(height: context.elementSpacing),
            _buildPreferenceCard(
              context,
              children: [
                Obx(() => _buildSwitchTile(
                      context,
                      title: 'Notifications push',
                      subtitle: 'Recevoir des notifications sur votre appareil',
                      icon: Icons.notifications_active,
                      value: controller.pushNotifications.value,
                      onChanged: (value) => controller.pushNotifications.value = value,
                    )),
                Divider(color: context.borderColor, height: 1),
                Obx(() => _buildSwitchTile(
                      context,
                      title: 'Notifications email',
                      subtitle: 'Recevoir des emails de mise à jour',
                      icon: Icons.email,
                      value: controller.emailNotifications.value,
                      onChanged: (value) => controller.emailNotifications.value = value,
                    )),
                Divider(color: context.borderColor, height: 1),
                Obx(() => _buildSwitchTile(
                      context,
                      title: 'Sons',
                      subtitle: 'Activer les sons de notification',
                      icon: Icons.volume_up,
                      value: controller.notificationSounds.value,
                      onChanged: (value) => controller.notificationSounds.value = value,
                    )),
              ],
            ),

            SizedBox(height: context.sectionSpacing),

            // Section Apparence
            _buildSectionTitle(context, 'Apparence'),
            SizedBox(height: context.elementSpacing),
            _buildPreferenceCard(
              context,
              children: [
                Obx(() => _buildRadioTile(
                      context,
                      title: 'Thème sombre',
                      subtitle: 'Interface sombre',
                      icon: Icons.dark_mode,
                      value: 'dark',
                      groupValue: controller.themeMode.value,
                      onChanged: (value) => controller.themeMode.value = value ?? 'light',
                    )),
                Divider(color: context.borderColor, height: 1),
                Obx(() => _buildRadioTile(
                      context,
                      title: 'Thème clair',
                      subtitle: 'Interface claire',
                      icon: Icons.light_mode,
                      value: 'light',
                      groupValue: controller.themeMode.value,
                      onChanged: (value) => controller.themeMode.value = value ?? 'light',
                    )),
                Divider(color: context.borderColor, height: 1),
                Obx(() => _buildRadioTile(
                      context,
                      title: 'Automatique',
                      subtitle: 'Suivre le système',
                      icon: Icons.brightness_auto,
                      value: 'system',
                      groupValue: controller.themeMode.value,
                      onChanged: (value) => controller.themeMode.value = value ?? 'system',
                    )),
              ],
            ),

            SizedBox(height: context.sectionSpacing),

            // Section Langue
            _buildSectionTitle(context, 'Langue'),
            SizedBox(height: context.elementSpacing),
            _buildPreferenceCard(
              context,
              children: [
                Obx(() => _buildRadioTile(
                      context,
                      title: 'Français',
                      subtitle: 'French',
                      icon: Icons.language,
                      value: 'fr',
                      groupValue: controller.language.value,
                      onChanged: (value) => controller.language.value = value ?? 'fr',
                    )),
                Divider(color: context.borderColor, height: 1),
                Obx(() => _buildRadioTile(
                      context,
                      title: 'English',
                      subtitle: 'Anglais',
                      icon: Icons.language,
                      value: 'en',
                      groupValue: controller.language.value,
                      onChanged: (value) => controller.language.value = value ?? 'fr',
                    )),
              ],
            ),

            SizedBox(height: context.sectionSpacing),

            // Section Confidentialité
            _buildSectionTitle(context, 'Confidentialité'),
            SizedBox(height: context.elementSpacing),
            _buildPreferenceCard(
              context,
              children: [
                Obx(() => _buildSwitchTile(
                      context,
                      title: 'Partage de position',
                      subtitle: 'Autoriser l\'accès à votre position',
                      icon: Icons.location_on,
                      value: controller.locationSharing.value,
                      onChanged: (value) => controller.locationSharing.value = value,
                    )),
                Divider(color: context.borderColor, height: 1),
                Obx(() => _buildSwitchTile(
                      context,
                      title: 'Analyses',
                      subtitle: 'Partager les données d\'utilisation',
                      icon: Icons.analytics,
                      value: controller.analytics.value,
                      onChanged: (value) => controller.analytics.value = value,
                    )),
              ],
            ),

            SizedBox(height: context.sectionSpacing),

            // Bouton sauvegarder
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeSystem.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Sauvegarder les préférences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.h6.copyWith(
        fontWeight: FontWeight.bold,
        color: AppThemeSystem.primaryColor,
      ),
    );
  }

  Widget _buildPreferenceCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: context.borderRadius(BorderRadiusType.medium),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
          borderRadius: context.borderRadius(BorderRadiusType.small),
        ),
        child: Icon(icon, color: AppThemeSystem.primaryColor, size: 20),
      ),
      title: Text(title, style: context.body2.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: context.caption),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppThemeSystem.primaryColor.withValues(alpha: 0.5),
        activeThumbColor: AppThemeSystem.primaryColor,
      ),
    );
  }

  Widget _buildRadioTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    final isSelected = value == groupValue;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeSystem.primaryColor.withValues(alpha: 0.1)
              : AppThemeSystem.grey200,
          borderRadius: context.borderRadius(BorderRadiusType.small),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppThemeSystem.primaryColor : context.secondaryTextColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: context.body2.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle, style: context.caption),
      trailing: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: AppThemeSystem.primaryColor,
      ),
    );
  }
}
