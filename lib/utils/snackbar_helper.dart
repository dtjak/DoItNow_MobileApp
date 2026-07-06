import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shows a SnackBar that is guaranteed to auto-dismiss after [duration].
///
/// Flutter's built-in SnackBar ignores its `duration` and stays open until
/// manually dismissed whenever an accessibility service (TalkBack, Narrator,
/// VoiceOver, etc.) is active and the SnackBar has an action button. This
/// wrapper schedules an explicit removal so the SnackBar always disappears
/// on time regardless of accessibility settings on the test device.
void showAutoDismissSnackBar(
  BuildContext? context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
  String? actionLabel,
  Color actionTextColor = AppColors.primaryFixedDim,
  VoidCallback? onActionPressed,
  ScaffoldMessengerState? messenger,
}) {
  // Prefer an explicitly captured messenger. When a SnackBar is shown right
  // after an `await` (e.g. a swipe-to-delete that removes the card), the
  // card's own context can already be deactivated, so ScaffoldMessenger.of
  // would fail to find/show anything. Pass `context: null` in that case.
  messenger ??= ScaffoldMessenger.of(context!);
  messenger.hideCurrentSnackBar();

  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: actionTextColor,
              onPressed: onActionPressed ?? () {},
            )
          : null,
    ),
  );

  final resolved = messenger;
  Future.delayed(duration, () {
    resolved.removeCurrentSnackBar(reason: SnackBarClosedReason.timeout);
  });
}
