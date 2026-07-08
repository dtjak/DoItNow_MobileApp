import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Menampilkan SnackBar yang dijamin akan hilang otomatis setelah [duration].
///
/// SnackBar bawaan Flutter mengabaikan `duration`-nya dan tetap terbuka sampai
/// ditutup manual saat layanan aksesibilitas (TalkBack, Narrator, VoiceOver,
/// dll.) aktif dan SnackBar memiliki tombol aksi. Wrapper ini menjadwalkan
/// penghapusan eksplisit agar SnackBar selalu hilang tepat waktu terlepas
/// dari pengaturan aksesibilitas pada perangkat uji.
void showAutoDismissSnackBar(
  BuildContext? context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
  String? actionLabel,
  Color actionTextColor = AppColors.primaryFixedDim,
  VoidCallback? onActionPressed,
  ScaffoldMessengerState? messenger,
}) {
  // Lebih baik gunakan messenger yang sudah ditangkap secara eksplisit. Saat
  // SnackBar ditampilkan tepat setelah `await` (misalnya swipe-to-delete yang
  // menghapus kartu), context milik kartu itu sendiri bisa sudah nonaktif,
  // sehingga ScaffoldMessenger.of gagal menemukan/menampilkan apa pun.
  // Kirim `context: null` dalam kasus tersebut.
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
