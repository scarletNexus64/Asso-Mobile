import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/help_controller.dart';

class HelpView extends GetView<HelpController> {
  const HelpView({super.key});

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
          'Aide et Support',
          style: context.h5.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section contact rapide
            _buildQuickContactSection(context),

            SizedBox(height: context.sectionSpacing),

            // Titre des sujets d'aide
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
              child: Text(
                'Sujets d\'aide',
                style: context.h6.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppThemeSystem.primaryColor,
                ),
              ),
            ),

            SizedBox(height: context.elementSpacing),

            // Grille des sujets d'aide
            _buildSupportTopicsGrid(context),

            SizedBox(height: context.sectionSpacing),

            // Section informations de contact
            _buildContactInfoSection(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickContactSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(context.horizontalPadding),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeSystem.primaryColor,
            AppThemeSystem.primaryColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: context.borderRadius(BorderRadiusType.medium),
        boxShadow: [
          BoxShadow(
            color: AppThemeSystem.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.headset_mic,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 16),
          const Text(
            'Besoin d\'aide ?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Notre équipe est disponible pour vous aider 24h/24 et 7j/7',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.contactByEmail,
                  icon: const Icon(Icons.email, size: 18),
                  label: const Text('Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppThemeSystem.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.contactByPhone,
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Appeler'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppThemeSystem.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTopicsGrid(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.deviceType == DeviceType.mobile ? 2 : 4,
          childAspectRatio: 1.1,
          crossAxisSpacing: context.elementSpacing,
          mainAxisSpacing: context.elementSpacing,
        ),
        itemCount: controller.supportTopics.length,
        itemBuilder: (context, index) {
          final topic = controller.supportTopics[index];
          return _buildTopicCard(context, topic);
        },
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, SupportTopic topic) {
    return InkWell(
      onTap: () => controller.openTopic(topic),
      borderRadius: context.borderRadius(BorderRadiusType.medium),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                topic.icon,
                color: AppThemeSystem.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                topic.title,
                style: context.body1.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                topic.description,
                style: context.caption,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.horizontalPadding),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: context.borderRadius(BorderRadiusType.medium),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de contact',
            style: context.body1.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            context,
            icon: Icons.email,
            title: 'Email',
            value: 'support@asso.com',
            onTap: controller.contactByEmail,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            context,
            icon: Icons.phone,
            title: 'Téléphone',
            value: '+237 670 00 00 00',
            onTap: controller.contactByPhone,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            context,
            icon: Icons.chat,
            title: 'WhatsApp',
            value: '+237 670 00 00 00',
            onTap: controller.contactByWhatsApp,
            iconColor: const Color(0xFF25D366),
          ),
          const SizedBox(height: 16),
          Divider(color: context.borderColor),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, size: 20, color: context.secondaryTextColor),
              const SizedBox(width: 8),
              Text(
                'Horaires: 24h/24 - 7j/7',
                style: context.body2.copyWith(color: context.secondaryTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppThemeSystem.primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppThemeSystem.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.caption,
                  ),
                  Text(
                    value,
                    style: context.body2.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
