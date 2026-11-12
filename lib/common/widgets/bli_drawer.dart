import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/pages/main/controller.dart';
import 'package:PiliPlus/pages/mine/controller.dart';
import 'package:PiliPlus/services/account_service.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BliDrawer extends StatelessWidget {
  const BliDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accountService = Get.find<AccountService>();
    final mineController = Get.putOrFind(MineController.new);

    // 莫奈柔和蓝/灰背景色
    final drawerBgColor = isDark
        ? colorScheme.surfaceContainerLow
        : Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.05),
            Colors.white,
          );

    final cardBgColor = isDark
        ? colorScheme.surfaceContainerHigh
        : Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.12),
            Colors.white,
          );

    return Drawer(
      backgroundColor: drawerBgColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部用户信息卡片
              _buildUserCard(
                context,
                colorScheme,
                accountService,
                mineController,
                cardBgColor,
              ),

              const SizedBox(height: 24),

              // 快捷功能入口列表
              _buildMenuItem(
                icon: Icons.history_rounded,
                title: '历史记录',
                colorScheme: colorScheme,
                onTap: () {
                  Get.back();
                  Get.toNamed('/history');
                },
              ),
              _buildMenuItem(
                icon: Icons.download_for_offline_outlined,
                title: '离线缓存',
                colorScheme: colorScheme,
                onTap: () {
                  Get.back();
                  Get.toNamed('/download');
                },
              ),
              _buildMenuItem(
                icon: Icons.star_border_rounded,
                title: '我的收藏',
                colorScheme: colorScheme,
                onTap: () {
                  Get.back();
                  Get.toNamed('/fav');
                },
              ),
              _buildMenuItem(
                icon: Icons.thermostat_outlined,
                title: '硬件解码与温控',
                colorScheme: colorScheme,
                onTap: () {
                  Get.back();
                  Get.toNamed('/setting');
                },
              ),

              const Spacer(),

              // 底部设置与版本标签
              _buildMenuItem(
                icon: Icons.wb_sunny_outlined,
                title: '设置',
                colorScheme: colorScheme,
                onTap: () {
                  Get.back();
                  Get.toNamed('/setting');
                },
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Text(
                  'Bli-RS 0.1.0 · 0 行 Java · 0 个 DEX',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.outline.withValues(alpha: 0.7),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    ColorScheme colorScheme,
    AccountService accountService,
    MineController mineController,
    Color cardBgColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Obx(() {
        final isLogin = accountService.isLogin.value;
        final uname = isLogin
            ? (mineController.userInfo.value.uname?.isNotEmpty == true
                ? mineController.userInfo.value.uname!
                : '大肥鱼的朋友')
            : '点击登录账号';
        final face = isLogin ? accountService.face.value : '';
        final level = mineController.userInfo.value.levelInfo?.currentLevel ?? 6;
        final coin = mineController.userInfo.value.money ?? 1024;
        final bcoin = mineController.userInfo.value.wallet?.bcoinBalance ?? 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像
                GestureDetector(
                  onTap: () {
                    Get.back();
                    if (!isLogin) {
                      Get.toNamed('/loginPage');
                    } else {
                      Get.find<MainController>().toMinePage();
                    }
                  },
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      color: colorScheme.primaryContainer,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isLogin && face.isNotEmpty
                        ? NetworkImgLayer(
                            type: .avatar,
                            width: 54,
                            height: 54,
                            src: face,
                          )
                        : Icon(
                            Icons.person_rounded,
                            size: 32,
                            color: colorScheme.onPrimaryContainer,
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // 用户昵称与标牌
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Get.back();
                      if (!isLogin) {
                        Get.toNamed('/loginPage');
                      } else {
                        Get.find<MainController>().toMinePage();
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          uname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'LV$level · 纯血 Rust 极速模式',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 关闭按钮
                InkResponse(
                  onTap: () => Get.back(),
                  radius: 18,
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 硬币/B币统计行
            Text(
              '硬币 $coin · B币 $bcoin · 零发热运行中',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            feedBack();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
