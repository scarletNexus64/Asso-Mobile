import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/tracking_controller.dart';

class TrackingView extends GetView<TrackingController> {
  const TrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppThemeSystem.getBackgroundColor(context),
      body: Column(
        children: [
          // Header
          _buildHeader(context, isDark),

          SizedBox(height: 16),

          // Barre de recherche
          _buildSearchBar(context),

          SizedBox(height: 12),

          // Filtres
          _buildFilters(context),

          SizedBox(height: 8),

          // Liste des commandes
          Expanded(
            child: Obx(() {
              final shipments = controller.filteredShipments;

              if (shipments.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: shipments.length,
                itemBuilder: (context, index) {
                  final shipment = shipments[index];
                  return _buildShipmentCard(context, shipment);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppThemeSystem.getHorizontalPadding(context)),
      decoration: BoxDecoration(
        color: isDark ? AppThemeSystem.darkCardColor : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppThemeSystem.getBorderColor(context).withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Suivi de commandes',
            style: context.textStyle(
              FontSizeType.h4,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(
              Icons.support_agent_rounded,
              color: AppThemeSystem.primaryColor,
            ),
            onPressed: controller.contactSupport,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher par numéro de commande...',
          hintStyle: context.textStyle(
            FontSizeType.body2,
            color: AppThemeSystem.grey600,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppThemeSystem.grey600,
          ),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppThemeSystem.grey600,
                  ),
                  onPressed: controller.clearSearch,
                )
              : SizedBox.shrink()),
          filled: true,
          fillColor: AppThemeSystem.getSurfaceColor(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: context.textStyle(FontSizeType.body2),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.filters.length,
        itemBuilder: (context, index) {
          final filter = controller.filters[index];
          return Obx(() {
            final isSelected = controller.selectedFilter.value == filter;
            return GestureDetector(
              onTap: () => controller.selectFilter(filter),
              child: Container(
                margin: EdgeInsets.only(right: 12),
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppThemeSystem.primaryColor
                      : AppThemeSystem.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? AppThemeSystem.primaryColor
                        : AppThemeSystem.getBorderColor(context),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter,
                  style: context.textStyle(
                    FontSizeType.body2,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildShipmentCard(BuildContext context, Map<String, dynamic> shipment) {
    final statusColor = Color(shipment['statusColor']);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppThemeSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTrackingDetails(context, shipment),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec ID et statut
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        shipment['status'],
                        style: context.textStyle(
                          FontSizeType.caption,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      shipment['id'],
                      style: context.textStyle(
                        FontSizeType.caption,
                        color: AppThemeSystem.grey600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Produit
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(shipment['productImage']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shipment['productName'],
                            style: context.textStyle(
                              FontSizeType.body1,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            shipment['seller'],
                            style: context.textStyle(
                              FontSizeType.caption,
                              color: AppThemeSystem.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),
                Divider(height: 1),
                SizedBox(height: 12),

                // Informations
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: AppThemeSystem.grey600,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Commandé le ${shipment['orderDate']}',
                      style: context.textStyle(
                        FontSizeType.caption,
                        color: AppThemeSystem.grey600,
                      ),
                    ),
                  ],
                ),

                if (shipment['status'] == 'En cours') ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping_rounded,
                        size: 16,
                        color: AppThemeSystem.primaryColor,
                      ),
                      SizedBox(width: 6),
                      Text(
                        shipment['currentLocation'],
                        style: context.textStyle(
                          FontSizeType.caption,
                          color: AppThemeSystem.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppThemeSystem.grey600,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Livraison estimée: ${shipment['estimatedDelivery']}',
                        style: context.textStyle(
                          FontSizeType.caption,
                          color: AppThemeSystem.grey600,
                        ),
                      ),
                    ],
                  ),
                ],

                if (shipment['status'] == 'Livré') ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: Colors.green,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Livré le ${shipment['deliveredDate']}',
                        style: context.textStyle(
                          FontSizeType.caption,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],

                if (shipment['status'] == 'Annulé') ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.cancel_rounded,
                        size: 16,
                        color: Colors.red,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Raison: ${shipment['cancelReason']}',
                          style: context.textStyle(
                            FontSizeType.caption,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 12),

                // Bouton voir détails
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Voir le suivi',
                      style: context.textStyle(
                        FontSizeType.body2,
                        color: AppThemeSystem.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppThemeSystem.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: AppThemeSystem.primaryColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Aucune commande',
            style: context.textStyle(
              FontSizeType.h5,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Vos commandes apparaîtront ici',
            style: context.textStyle(
              FontSizeType.body2,
              color: AppThemeSystem.grey600,
            ),
          ),
        ],
      ),
    );
  }

  void _showTrackingDetails(BuildContext context, Map<String, dynamic> shipment) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: BoxDecoration(
          color: AppThemeSystem.getBackgroundColor(context),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppThemeSystem.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Suivi de commande',
                    style: context.textStyle(
                      FontSizeType.h5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            Divider(height: 1),

            // Contenu
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Infos commande
                    _buildOrderInfo(context, shipment),

                    SizedBox(height: 24),

                    // Timeline de suivi
                    Text(
                      'Suivi de livraison',
                      style: context.textStyle(
                        FontSizeType.body1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTrackingTimeline(context, shipment['trackingSteps']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildOrderInfo(BuildContext context, Map<String, dynamic> shipment) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(shipment['productImage']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipment['productName'],
                      style: context.textStyle(
                        FontSizeType.body1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      shipment['seller'],
                      style: context.textStyle(
                        FontSizeType.caption,
                        color: AppThemeSystem.grey600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      shipment['price'],
                      style: context.textStyle(
                        FontSizeType.body1,
                        fontWeight: FontWeight.bold,
                        color: AppThemeSystem.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (shipment['deliveryAddress'] != null) ...[
            SizedBox(height: 16),
            Divider(height: 1),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 20,
                  color: AppThemeSystem.grey600,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adresse de livraison',
                        style: context.textStyle(
                          FontSizeType.caption,
                          color: AppThemeSystem.grey600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        shipment['deliveryAddress'],
                        style: context.textStyle(
                          FontSizeType.body2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline(BuildContext context, List<dynamic> steps) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        final isCompleted = step['completed'];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppThemeSystem.primaryColor
                        : AppThemeSystem.grey300,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppThemeSystem.primaryColor
                          : AppThemeSystem.grey400,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted
                        ? AppThemeSystem.primaryColor
                        : AppThemeSystem.grey300,
                  ),
              ],
            ),

            SizedBox(width: 12),

            // Step info
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'],
                      style: context.textStyle(
                        FontSizeType.body2,
                        fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                        color: isCompleted ? null : AppThemeSystem.grey600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      step['date'],
                      style: context.textStyle(
                        FontSizeType.caption,
                        color: AppThemeSystem.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
