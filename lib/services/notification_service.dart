import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Menyiapkan plugin notifikasi lokal dan data zona waktu. Aman dipanggil
  /// berkali-kali — hanya berjalan sekali.
  Future<void> init() async {
    if (kIsWeb) return;
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  /// Meminta izin notifikasi ke sistem operasi di Android dan iOS.
  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    await init();

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    final iosImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Membaca preferensi aktif/nonaktif notifikasi pengguna dari penyimpanan lokal.
  Future<bool> _isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  /// Menjadwalkan pengingat untuk tenggat tugas (1 jam sebelumnya, atau
  /// segera jika tenggat sudah kurang dari 1 jam lagi).
  Future<void> scheduleTaskNotification(TaskModel task) async {
    if (kIsWeb) return;
    await init();

    if (!await _isNotificationEnabled()) return;
    if (task.deadline == null) return;

    final int notificationId = task.id.hashCode;

    // Batalkan notifikasi sebelumnya untuk tugas ini
    await cancelNotification(task.id);

    final DateTime scheduleTime = task.deadline!.subtract(const Duration(hours: 1));
    final now = DateTime.now();

    if (scheduleTime.isBefore(now)) {
      if (task.deadline!.isAfter(now)) {
        await _schedule(
          id: notificationId,
          title: 'Tenggat Tugas Mendekat!',
          body: 'Tugas "${task.title}" akan segera berakhir.',
          scheduledDate: task.deadline!,
        );
      }
      return;
    }

    await _schedule(
      id: notificationId,
      title: 'Pengingat Tugas!',
      body: 'Tugas "${task.title}" berakhir dalam 1 jam.',
      scheduledDate: scheduleTime,
    );
  }

  /// Helper tingkat rendah yang benar-benar mendaftarkan notifikasi ke sistem
  /// operasi pada [scheduledDate] yang ditentukan.
  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'task_reminders',
        'Pengingat Tugas',
        channelDescription: 'Notifikasi untuk tenggat tugas',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('Scheduled notification $id for $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Membatalkan pengingat yang tertunda untuk satu tugas (misalnya saat dihapus/diselesaikan).
  Future<void> cancelNotification(String taskId) async {
    if (kIsWeb) return;
    await init();
    final int notificationId = taskId.hashCode;
    await _notificationsPlugin.cancel(notificationId);
    debugPrint('Cancelled notification $notificationId');
  }

  /// Membatalkan semua notifikasi yang tertunda (misalnya saat logout).
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await init();
    await _notificationsPlugin.cancelAll();
    debugPrint('Cancelled all notifications');
  }
}
