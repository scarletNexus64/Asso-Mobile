import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/complete_profile_controller.dart';

class CompleteProfileView extends GetView<CompleteProfileController> {
  const CompleteProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.backgroundColor,
        title: Text(
          'Compléter votre profil',
          style: context.h5.copyWith(
            color: context.primaryTextColor,
          ),
        ),
        centerTitle: true,
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with description
            _buildHeaderSection(context),

            SizedBox(height: context.sectionSpacing),

            // Form content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Name Field
                  _buildTextFieldLabel(context, 'Prénom', true),
                  SizedBox(height: context.elementSpacing),
                  _buildTextField(
                    context,
                    controller.firstNameController,
                    'Entrez votre prénom',
                    Icons.person_outline,
                  ),
                  SizedBox(height: context.sectionSpacing),

                  // Last Name Field
                  _buildTextFieldLabel(context, 'Nom', true),
                  SizedBox(height: context.elementSpacing),
                  _buildTextField(
                    context,
                    controller.lastNameController,
                    'Entrez votre nom',
                    Icons.person_outline,
                  ),
                  SizedBox(height: context.sectionSpacing),

                  // Email Field (Optional)
                  _buildTextFieldLabel(context, 'Email', false),
                  SizedBox(height: context.elementSpacing),
                  _buildTextField(
                    context,
                    controller.emailController,
                    'Entrez votre email (optionnel)',
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: context.sectionSpacing),

                  // Gender Selection
                  _buildTextFieldLabel(context, 'Genre', false),
                  SizedBox(height: context.elementSpacing),
                  _buildGenderSelection(context),
                  SizedBox(height: context.sectionSpacing),

                  // Birth Date Picker
                  _buildTextFieldLabel(context, 'Date de naissance', false),
                  SizedBox(height: context.elementSpacing),
                  _buildBirthDatePicker(context),
                  SizedBox(height: context.sectionSpacing),

                  // Address Field
                  _buildTextFieldLabel(context, 'Adresse', false),
                  SizedBox(height: context.elementSpacing),
                  _buildTextField(
                    context,
                    TextEditingController()..text = controller.address.value,
                    'Entrez votre adresse (optionnelle)',
                    Icons.location_on_outlined,
                    maxLines: 3,
                    onChanged: (value) => controller.address.value = value,
                  ),
                  SizedBox(height: context.sectionSpacing * 2),

                  // Save Button
                  _buildSaveButton(context),

                  SizedBox(height: context.verticalPadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.horizontalPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeSystem.primaryColor,
            AppThemeSystem.tertiaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_add_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: context.elementSpacing * 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Finalisez votre profil',
                      style: context.h5.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Complétez vos informations pour continuer',
                      style: context.body2.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldLabel(
    BuildContext context,
    String label,
    bool isRequired,
  ) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: context.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
          ),
          if (isRequired) ...[
            TextSpan(
              text: ' *',
              style: context.body2.copyWith(
                color: AppThemeSystem.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController textController,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: textController,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: AppThemeSystem.primaryColor,
        ),
        filled: true,
        fillColor: context.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppThemeSystem.primaryColor,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
          vertical: context.verticalPadding * 0.75,
        ),
        hintStyle: context.body2.copyWith(
          color: context.secondaryTextColor,
        ),
      ),
      style: context.body1.copyWith(
        color: context.primaryTextColor,
      ),
    );
  }

  Widget _buildGenderSelection(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildGenderChip(
              context,
              'Homme',
              'H',
              controller.selectedGender.value == 'H',
              () => controller.selectGender('H'),
            ),
          ),
          SizedBox(width: context.elementSpacing),
          Expanded(
            child: _buildGenderChip(
              context,
              'Femme',
              'F',
              controller.selectedGender.value == 'F',
              () => controller.selectGender('F'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(
    BuildContext context,
    String label,
    String value,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.verticalPadding * 0.75,
          horizontal: context.horizontalPadding * 0.5,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeSystem.primaryColor
              : context.surfaceColor,
          border: Border.all(
            color: isSelected
                ? AppThemeSystem.primaryColor
                : context.borderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              value == 'H' ? Icons.male_outlined : Icons.female_outlined,
              color: isSelected
                  ? Colors.white
                  : context.secondaryTextColor,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: context.body1.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : context.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthDatePicker(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: controller.birthDate.value ?? DateTime.now(),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppThemeSystem.primaryColor,
                    onPrimary: Colors.white,
                    surface: context.surfaceColor,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            controller.selectBirthDate(picked);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.horizontalPadding,
            vertical: context.verticalPadding * 0.75,
          ),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            border: Border.all(color: context.borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: AppThemeSystem.primaryColor,
              ),
              SizedBox(width: context.horizontalPadding),
              Expanded(
                child: Text(
                  controller.birthDate.value != null
                      ? '${controller.birthDate.value!.day.toString().padLeft(2, '0')}/${controller.birthDate.value!.month.toString().padLeft(2, '0')}/${controller.birthDate.value!.year}'
                      : 'Sélectionnez une date',
                  style: context.body1.copyWith(
                    color: controller.birthDate.value != null
                        ? context.primaryTextColor
                        : context.secondaryTextColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppThemeSystem.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: context.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.saveProfile(),
          icon: controller.isLoading.value
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                )
              : Icon(Icons.check_circle_outline),
          label: Text(
            controller.isLoading.value
                ? 'Enregistrement...'
                : 'Enregistrer le profil',
            style: context.button.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppThemeSystem.primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppThemeSystem.grey400,
            disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }
}
