import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_folio/_utils/device_info.dart';
import 'package:flutter_folio/_utils/input_utils.dart';
import 'package:flutter_folio/_utils/native_window_utils/window_utils.dart';
import 'package:flutter_folio/core_packages.dart';
import 'package:flutter_folio/models/app_model.dart';
import 'package:flutter_folio/views/app_title_bar/rounded_profile_button.dart';
import 'package:flutter_folio/views/app_title_bar/touch_mode_toggle_btn.dart';

class AppTitleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppTheme theme = context.watch();
    // Optionally wrap the content in a Native title bar. This may be a no-op depending on platform.
    return IoUtils.instance.wrapNativeTitleBarIfRequired(ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 40),
      child: Stack(
        children: [
          ShadowedBg(theme.surface1),
          _AdaptiveTitleBarContent(),
        ],
      ),
    ));
  }
}

class _AdaptiveTitleBarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Determine whether to show back button. We don't want to show it for "guest" users
    bool isGuestUser = context.select((AppModel m) => m.isGuestUser);
    bool canGoBack = context.select((AppModel m) => m.canPopNav);
    bool showBackBtn = isGuestUser == false && canGoBack;
    double appWidth = context.widthPx;
    // Mac title bar has a different layout as it's window btns are left aligned
    bool isMac = DeviceOS.isMacOS;
    bool isMobile = DeviceOS.isMobile;

    return Stack(children: [
      // Centered TitleText
      if (appWidth > 400) Center(child: _TitleText()),
      // Btns
      Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isMac || isMobile) ...[
            if (isMac) HSpace(80), // Reserve some space for the native btns
            if (showBackBtn) _BackBtn(),
            Spacer(),
            TouchModeToggleBtn(invertPopupAlign: isMac),
            HSpace.sm,
            RoundedProfileBtn(invertRow: true, useBottomSheet: isMobile),
            HSpace.sm,
          ] else ...[
            HSpace.sm,
            // Linux and Windows are left aligned and simple
            RoundedProfileBtn(useBottomSheet: isMobile),
            HSpace.sm,
            TouchModeToggleBtn(invertPopupAlign: isMac),
            HSpace.sm,
            if (showBackBtn) _BackBtn(),
          ]
        ],
      ),
    ]);
  }
}

class _TitleText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(child: AppLogoText(constraints: BoxConstraints(maxHeight: 16))),
    );
  }
}

class _BackBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppTheme theme = Provider.of(context);
    return FadeInDown(
        child: SimpleBtn(
      onPressed: () => handleBackPressed(context),
      child: Container(
        height: double.infinity,
        child: Row(
          children: [
            Icon(Icons.chevron_left),
            Text("Back", style: TextStyles.body2.copyWith(color: theme.greyStrong)),
            HSpace.med
          ],
        ),
      ),
    ));
  }

  void handleBackPressed(BuildContext context) {
    InputUtils.unFocus();
    context.read<AppModel>().popNav();
  }
}
