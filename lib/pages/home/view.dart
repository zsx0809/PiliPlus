import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/common/widgets/custom_height_widget.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/scroll_physics.dart' show tabBarView;
import 'package:PiliPlus/pages/common/common_page.dart';
import 'package:PiliPlus/pages/home/controller.dart';
import 'package:PiliPlus/pages/main/controller.dart';
import 'package:PiliPlus/pages/main/view.dart' show mainScaffoldKey;
import 'package:PiliPlus/pages/mine/controller.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/utils/extension/size_ext.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_ui/material_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends CommonPageState<HomePage>
    with AutomaticKeepAliveClientMixin {
  late ColorScheme _colorScheme;
  final _homeController = Get.putOrFind(HomeController.new);
  final _mainController = Get.find<MainController>();

  @override
  bool get needsCorrection => _homeController.hideTopBar;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorScheme = ColorScheme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = _colorScheme.brightness == Brightness.dark;

    // 莫奈柔和蓝色调 (顶部)
    final topBarBgColor = isDark
        ? _colorScheme.surface
        : Color.alphaBlend(
            _colorScheme.primary.withValues(alpha: 0.08),
            const Color(0xFFF1F5FB),
          );

    // 视频流纯白底色
    final contentBgColor = isDark ? _colorScheme.surface : Colors.white;

    // 胶囊 Tab 栏
    Widget capsuleTabBar = _buildCapsuleTabs();

    return Container(
      color: topBarBgColor,
      child: Column(
        children: [
          if (!_mainController.useSideBar &&
              MediaQuery.sizeOf(context).isPortrait)
            customAppBar(),
          capsuleTabBar,
          const SizedBox(height: 8),
          Expanded(
            child: Material(
              color: contentBgColor,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // 在最左侧 Tab (直播) 继续向右划呼出侧边栏抽屉
                  if (_homeController.tabController.index == 0) {
                    if (notification is OverscrollNotification &&
                        notification.overscroll < -15) {
                      mainScaffoldKey.currentState?.openDrawer();
                      return true;
                    }
                  }
                  return false;
                },
                child: onBuild(
                  tabBarView(
                    controller: _homeController.tabController,
                    children: _homeController.tabs.map((e) => e.page).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleTabs() {
    if (_homeController.tabs.length <= 1) {
      return const SizedBox(height: 6);
    }

    final isDark = _colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedBuilder(
        animation: _homeController.tabController.animation ??
            _homeController.tabController,
        builder: (context, _) {
          final currentIndex = _homeController.tabController.index;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_homeController.tabs.length, (index) {
              final tab = _homeController.tabs[index];
              final isSelected = currentIndex == index;

              // 莫奈胶囊轮廓线与背景配色
              final borderColor = isSelected
                  ? _colorScheme.primary
                  : _colorScheme.outline.withValues(alpha: 0.35);

              final bgColor = isSelected
                  ? _colorScheme.primary
                  : (isDark
                      ? _colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.8));

              final textColor = isSelected
                  ? _colorScheme.onPrimary
                  : _colorScheme.onSurfaceVariant;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      feedBack();
                      _homeController.tabController.animateTo(index);
                      if (currentIndex == index) {
                        _homeController.animateToTop();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: borderColor,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget customAppBar() {
    const padding = EdgeInsets.fromLTRB(14, 6, 14, 0);
    // 左头像 - 中间搜索 - 右消息
    final child = Row(
      children: [
        userAvatar(colorScheme: _colorScheme, mainController: _mainController),
        const SizedBox(width: 10),
        searchBar(),
        const SizedBox(width: 8),
        msgBadge(_mainController),
      ],
    );

    if (_homeController.hideTopBar) {
      if (_mainController.barOffset case final barOffset?) {
        return Obx(
          () {
            final offset = barOffset.value;
            return CustomHeightWidget(
              offset: Offset(0, -offset),
              height: Style.topBarHeight - offset,
              child: Padding(
                padding: padding,
                child: child,
              ),
            );
          },
        );
      }
      if (_homeController.showTopBar case final showTopBar?) {
        return Obx(() {
          final showSearchBar = showTopBar.value;
          return AnimatedOpacity(
            opacity: showSearchBar ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedContainer(
              curve: Curves.easeInOutCubicEmphasized,
              duration: const Duration(milliseconds: 500),
              height: showSearchBar ? Style.topBarHeight : 0,
              padding: padding,
              child: child,
            ),
          );
        });
      }
    }
    return Container(
      height: Style.topBarHeight,
      padding: padding,
      child: child,
    );
  }

  Widget searchBar() {
    const borderRadius = BorderRadius.all(Radius.circular(25));
    final isDark = _colorScheme.brightness == Brightness.dark;

    return Expanded(
      child: SizedBox(
        height: 42,
        child: Material(
          borderRadius: borderRadius,
          color: isDark
              ? _colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : Colors.white,
          child: InkWell(
            borderRadius: borderRadius,
            splashColor: _colorScheme.primaryContainer.withValues(
              alpha: 0.3,
            ),
            onTap: () => Get.toNamed(
              '/search',
              parameters: _homeController.enableSearchWord
                  ? {'hintText': _homeController.defaultSearch.value}
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border.all(
                  color: _colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: _colorScheme.outline,
                    size: 20,
                    semanticLabel: '搜索',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () {
                        final text = _homeController.defaultSearch.value.isNotEmpty
                            ? _homeController.defaultSearch.value
                            : '搜索视频、UP 主';
                        return Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: _colorScheme.outline,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget userAvatar({
  required ColorScheme colorScheme,
  required MainController mainController,
}) {
  return Semantics(
    label: "我的 / 侧边栏",
    child: Obx(
      () {
        void openDrawer() {
          mainScaffoldKey.currentState?.openDrawer();
        }

        if (mainController.accountService.isLogin.value) {
          return Stack(
            clipBehavior: .none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: NetworkImgLayer(
                  type: .avatar,
                  width: 38,
                  height: 38,
                  src: mainController.accountService.face.value,
                ),
              ),
              Positioned.fill(
                child: Material(
                  type: .transparency,
                  child: InkWell(
                    onTap: openDrawer,
                    splashColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    customBorder: const CircleBorder(),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Obx(
                  () => MineController.anonymity.value
                      ? IgnorePointer(
                          child: Container(
                            padding: const .all(2),
                            decoration: BoxDecoration(
                              shape: .circle,
                              color: colorScheme.secondaryContainer,
                            ),
                            child: Icon(
                              size: 12,
                              MdiIcons.incognito,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          );
        }
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            tooltip: '呼出侧边栏',
            style: IconButton.styleFrom(
              padding: .zero,
              backgroundColor: Colors.transparent,
            ),
            onPressed: openDrawer,
            icon: Icon(
              Icons.person_outline_rounded,
              size: 22,
              color: colorScheme.primary,
            ),
          ),
        );
      },
    ),
  );
}

Widget msgBadge(MainController mainController) {
  return Obx(
    () {
      final count = mainController.msgUnReadCount.value;
      final isNumBadge = mainController.msgBadgeMode == .number;
      return IconButton(
        tooltip: '消息',
        onPressed: () {
          mainController
            ..clearUnreadMsg()
            ..lastCheckUnreadAt = DateTime.now().millisecondsSinceEpoch;
          Get.toNamed('/whisper');
        },
        icon: Badge(
          isLabelVisible:
              mainController.msgBadgeMode != .hidden && count != null,
          alignment: isNumBadge
              ? const Alignment(0.0, -0.85)
              : const Alignment(1.0, -0.85),
          label: isNumBadge && count != null ? Text(count) : null,
          child: const Icon(Icons.notifications_none_rounded),
        ),
      );
    },
  );
}
