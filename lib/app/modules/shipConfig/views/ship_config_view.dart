import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/ship_config_controller.dart';
import '../models/delivery_person_models.dart';

class ShipConfigView extends GetView<ShipConfigController> {
  const ShipConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Obx(() => controller.currentStep.value > 0
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios, color: context.primaryTextColor),
                onPressed: controller.previousStep,
              )
            : IconButton(
                icon: Icon(Icons.close, color: context.primaryTextColor),
                onPressed: () => Get.back(),
              )),
        title: Text(
          'Devenir Livreur',
          style: context.h5.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        switch (controller.currentStep.value) {
          case 0:
            return _AcceptanceStep();
          case 1:
            return _TypeSelectionStep();
          case 2:
            return _CompanyConfigStep();
          default:
            return const SizedBox.shrink();
        }
      }),
    );
  }
}

/// Étape 0: Acceptation des termes et permission
class _AcceptanceStep extends GetView<ShipConfigController> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Illustration
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: Icon(
              Icons.delivery_dining,
              size: 120,
              color: AppThemeSystem.primaryColor,
            ),
          ),

          SizedBox(height: context.sectionSpacing),

          // Titre
          Text(
            'Bienvenue parmi nos livreurs',
            style: context.h3.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: context.elementSpacing),

          // Description
          Text(
            'Gagnez de l\'argent en livrant des colis dans votre zone. Flexible, simple et rémunérateur.',
            style: context.body1.copyWith(color: context.secondaryTextColor),
          ),

          SizedBox(height: context.sectionSpacing),

          // Conditions
          _buildConditionsSection(context),

          SizedBox(height: context.sectionSpacing),

          // Bouton continuer
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.termsAccepted.value
                      ? controller.nextStep
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeSystem.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: AppThemeSystem.grey300,
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsSection(BuildContext context) {
    return Column(
      children: [
        // Termes
        Obx(() => CheckboxListTile(
              value: controller.termsAccepted.value,
              onChanged: (value) {
                controller.termsAccepted.value = value ?? false;
                // Demander automatiquement la permission si accepté
                if (value == true && !controller.locationPermissionGranted.value) {
                  controller.requestLocationPermission();
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text('J\'accepte les conditions générales'),
              subtitle: const Text(
                'En devenant livreur, j\'accepte de respecter les règles de livraison',
                style: TextStyle(fontSize: 12),
              ),
            )),

        const SizedBox(height: 12),

        // Partage de localisation
        Obx(() {
          final hasPermission = controller.locationPermissionGranted.value;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasPermission
                  ? AppThemeSystem.successColor.withValues(alpha: 0.1)
                  : context.surfaceColor,
              borderRadius: context.borderRadius(BorderRadiusType.medium),
              border: Border.all(
                color: hasPermission
                    ? AppThemeSystem.successColor
                    : context.borderColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hasPermission ? Icons.check_circle : Icons.location_on,
                      color: hasPermission
                          ? AppThemeSystem.successColor
                          : AppThemeSystem.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Partage de localisation',
                        style: context.body1.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Nous devons connaître votre position pour vous proposer des livraisons à proximité',
                  style: context.caption.copyWith(color: context.secondaryTextColor),
                ),
                if (!hasPermission) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: controller.requestLocationPermission,
                      icon: const Icon(Icons.location_on),
                      label: const Text('Autoriser l\'accès'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppThemeSystem.primaryColor),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// Étape 1: Sélection du type de livreur
class _TypeSelectionStep extends GetView<ShipConfigController> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type de livreur',
            style: context.h3.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: context.elementSpacing),

          Text(
            'Sélectionnez le type de compte qui vous convient',
            style: context.body1.copyWith(color: context.secondaryTextColor),
          ),

          SizedBox(height: context.sectionSpacing),

          // Options
          _buildTypeOption(
            context,
            type: DeliveryPersonType.personal,
            icon: Icons.person,
            title: 'Personnel',
            description: 'Je livre en tant que particulier avec mon propre véhicule',
          ),

          const SizedBox(height: 16),

          _buildTypeOption(
            context,
            type: DeliveryPersonType.company,
            icon: Icons.business,
            title: 'Entreprise',
            description: 'Je représente une entreprise de livraison',
          ),

          SizedBox(height: context.sectionSpacing),

          // Bouton continuer
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.selectedType.value != null
                      ? controller.nextStep
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeSystem.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: AppThemeSystem.grey300,
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context, {
    required DeliveryPersonType type,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Obx(() {
      final isSelected = controller.selectedType.value == type;

      return InkWell(
        onTap: () => controller.selectedType.value = type,
        borderRadius: context.borderRadius(BorderRadiusType.medium),
        child: Container(
          padding: EdgeInsets.all(context.horizontalPadding),
          decoration: BoxDecoration(
            color: isSelected
                ? AppThemeSystem.primaryColor.withValues(alpha: 0.1)
                : context.surfaceColor,
            borderRadius: context.borderRadius(BorderRadiusType.medium),
            border: Border.all(
              color: isSelected ? AppThemeSystem.primaryColor : context.borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppThemeSystem.primaryColor
                      : AppThemeSystem.grey200,
                  borderRadius: context.borderRadius(BorderRadiusType.small),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : context.secondaryTextColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.h6.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppThemeSystem.primaryColor
                            : context.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: context.caption.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppThemeSystem.primaryColor,
                  size: 28,
                ),
            ],
          ),
        ),
      );
    });
  }
}

/// Étape 2: Configuration entreprise
class _CompanyConfigStep extends GetView<ShipConfigController> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuration entreprise',
            style: context.h3.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: context.elementSpacing),

          Text(
            'Renseignez les informations de votre entreprise',
            style: context.body1.copyWith(color: context.secondaryTextColor),
          ),

          SizedBox(height: context.sectionSpacing),

          // Logo
          Center(
            child: Obx(() {
              final logo = controller.companyLogo.value;

              return GestureDetector(
                onTap: controller.pickCompanyLogo,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppThemeSystem.grey100,
                    borderRadius: context.borderRadius(BorderRadiusType.medium),
                    border: Border.all(
                      color: AppThemeSystem.grey300,
                      width: 2,
                    ),
                  ),
                  child: logo != null
                      ? ClipRRect(
                          borderRadius: context.borderRadius(BorderRadiusType.medium),
                          child: Image.file(logo, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 40,
                              color: AppThemeSystem.grey500,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Logo entreprise',
                              style: context.caption.copyWith(
                                color: AppThemeSystem.grey500,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),
          ),

          SizedBox(height: context.sectionSpacing),

          // Nom entreprise
          Text(
            'Nom de l\'entreprise',
            style: context.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.companyNameController,
            decoration: InputDecoration(
              hintText: 'Ex: Transport Express',
              border: OutlineInputBorder(
                borderRadius: context.borderRadius(BorderRadiusType.small),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'Description',
            style: context.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.companyDescriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Décrivez votre entreprise de livraison...',
              border: OutlineInputBorder(
                borderRadius: context.borderRadius(BorderRadiusType.small),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Emplacement
          Text(
            'Emplacement',
            style: context.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(() => InkWell(
                onTap: controller.openMapPicker,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppThemeSystem.grey300),
                    borderRadius: context.borderRadius(BorderRadiusType.small),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppThemeSystem.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.companyLocation.value.isEmpty
                              ? 'Sélectionner sur la carte'
                              : controller.companyLocation.value,
                          style: context.body2.copyWith(
                            color: controller.companyLocation.value.isEmpty
                                ? AppThemeSystem.grey500
                                : context.primaryTextColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppThemeSystem.grey500,
                      ),
                    ],
                  ),
                ),
              )),

          SizedBox(height: context.sectionSpacing),

          // Bouton terminer
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeSystem.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Terminer',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                )),
          ),
        ],
      ),
    );
  }
}
