import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/chatdetail_controller.dart';

class ChatdetailView extends GetView<ChatdetailController> {
  const ChatdetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppThemeSystem.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeSystem.darkCardColor : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppThemeSystem.getPrimaryTextColor(context),
          ),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppThemeSystem.primaryColor,
                        AppThemeSystem.tertiaryColor,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      controller.conversation['avatar'] ?? 'U',
                      style: context.textStyle(
                        FontSizeType.body1,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (controller.conversation['isOnline'] == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppThemeSystem.darkCardColor : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.conversation['name'] ?? 'Utilisateur',
                    style: context.textStyle(
                      FontSizeType.body1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(() => controller.isTyping.value
                      ? Text(
                          'En train d\'écrire...',
                          style: context.textStyle(
                            FontSizeType.caption,
                            color: AppThemeSystem.primaryColor,
                          ),
                        )
                      : Text(
                          controller.conversation['isOnline'] == true ? 'En ligne' : 'Hors ligne',
                          style: context.textStyle(
                            FontSizeType.caption,
                            color: AppThemeSystem.grey600,
                          ),
                        )),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.phone_rounded,
              color: AppThemeSystem.getPrimaryTextColor(context),
            ),
            onPressed: () {
              Get.snackbar(
                'Appel',
                'Fonction d\'appel en cours de développement',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppThemeSystem.getPrimaryTextColor(context),
            ),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() => ListView.builder(
              controller: controller.scrollController,
              padding: EdgeInsets.all(16),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                return _buildMessageBubble(context, message);
              },
            )),
          ),

          // Typing indicator
          Obx(() {
            if (!controller.isTyping.value) return SizedBox.shrink();
            return _buildTypingIndicator(context);
          }),

          // Input bar
          _buildInputBar(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Map<String, dynamic> message) {
    final isSentByMe = message['isSentByMe'] as bool;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByMe)
            Container(
              width: 32,
              height: 32,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppThemeSystem.primaryColor,
                    AppThemeSystem.tertiaryColor,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  controller.conversation['avatar'] ?? 'U',
                  style: context.textStyle(
                    FontSizeType.caption,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSentByMe
                    ? AppThemeSystem.primaryColor
                    : AppThemeSystem.getSurfaceColor(context),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(isSentByMe ? 16 : 4),
                  bottomRight: Radius.circular(isSentByMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: context.textStyle(
                      FontSizeType.body2,
                      color: isSentByMe
                          ? Colors.white
                          : AppThemeSystem.getPrimaryTextColor(context),
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message['timestamp'],
                        style: context.textStyle(
                          FontSizeType.caption,
                          color: isSentByMe
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppThemeSystem.grey600,
                        ),
                      ),
                      if (isSentByMe) ...[
                        SizedBox(width: 4),
                        Icon(
                          message['isRead']
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 14,
                          color: message['isRead']
                              ? Colors.blue[300]
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isSentByMe) SizedBox(width: 40),
          if (!isSentByMe) SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeSystem.primaryColor,
                  AppThemeSystem.tertiaryColor,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                controller.conversation['avatar'] ?? 'U',
                style: context.textStyle(
                  FontSizeType.caption,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppThemeSystem.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: 4),
                _buildDot(1),
                SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value + delay) % 1.0;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppThemeSystem.grey600.withValues(
              alpha: 0.3 + (animValue * 0.7),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildInputBar(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeSystem.darkCardColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.add_circle_rounded,
                color: AppThemeSystem.primaryColor,
                size: 28,
              ),
              onPressed: () {
                _showAttachmentOptions(context);
              },
            ),
            SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemeSystem.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    hintText: 'Tapez votre message...',
                    hintStyle: context.textStyle(
                      FontSizeType.body2,
                      color: AppThemeSystem.grey600,
                    ),
                    border: InputBorder.none,
                  ),
                  style: context.textStyle(FontSizeType.body2),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppThemeSystem.primaryColor,
                    AppThemeSystem.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: controller.sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppThemeSystem.getBackgroundColor(context),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppThemeSystem.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              _buildMenuItem(
                context,
                Icons.search_rounded,
                'Rechercher dans la conversation',
                () {
                  Get.back();
                  Get.snackbar('Recherche', 'Fonction en cours de développement');
                },
              ),
              _buildMenuItem(
                context,
                Icons.notifications_off_rounded,
                'Désactiver les notifications',
                () {
                  Get.back();
                  Get.snackbar('Notifications', 'Notifications désactivées');
                },
              ),
              _buildMenuItem(
                context,
                Icons.block_rounded,
                'Bloquer l\'utilisateur',
                () {
                  Get.back();
                  Get.snackbar('Bloquer', 'Utilisateur bloqué');
                },
              ),
              _buildMenuItem(
                context,
                Icons.delete_rounded,
                'Supprimer la conversation',
                () {
                  Get.back();
                  Get.back();
                  Get.snackbar('Suppression', 'Conversation supprimée');
                },
                isDestructive: true,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppThemeSystem.getBackgroundColor(context),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppThemeSystem.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAttachmentOption(
                      context,
                      Icons.image_rounded,
                      'Photo',
                      AppThemeSystem.primaryColor,
                    ),
                    _buildAttachmentOption(
                      context,
                      Icons.camera_alt_rounded,
                      'Caméra',
                      Colors.pink,
                    ),
                    _buildAttachmentOption(
                      context,
                      Icons.insert_drive_file_rounded,
                      'Document',
                      Colors.blue,
                    ),
                    _buildAttachmentOption(
                      context,
                      Icons.location_on_rounded,
                      'Position',
                      Colors.green,
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppThemeSystem.errorColor : AppThemeSystem.grey700,
      ),
      title: Text(
        title,
        style: context.textStyle(
          FontSizeType.body1,
          color: isDestructive
              ? AppThemeSystem.errorColor
              : AppThemeSystem.getPrimaryTextColor(context),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        Get.back();
        Get.snackbar(label, 'Fonction en cours de développement');
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: context.textStyle(
              FontSizeType.caption,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
