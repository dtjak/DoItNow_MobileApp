import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/edit_task_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/archive_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/about_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

import 'services/notification_service.dart';

// Allows swipe/drag gestures (e.g. the pinned tasks PageView) to respond to
// mouse drag as well as touch. By default Flutter's MaterialScrollBehavior
// only accepts touch/stylus for drag-to-scroll, so testing on Windows/desktop
// with a mouse would make PageView look completely unswipeable.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        ...super.dragDevices,
        PointerDeviceKind.mouse,
      };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Use Indonesian month/day names for all DateFormat calls app-wide.
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  // Initialize and request local notifications permissions
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  // Load persisted dark/light mode preference before first frame.
  await ThemeController.instance.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.instance,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'DoItNow',
          debugShowCheckedModeBanner: false,
          scrollBehavior: AppScrollBehavior(),
          theme: AppTheme.theme,
          home: const SplashScreen(),
          routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/task_detail': (context) => const TaskDetailScreen(),
        '/add_task': (context) => const AddTaskScreen(),
        '/edit_task': (context) => const EditTaskScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/archive': (context) => const ArchiveScreen(),
        '/profile': (context) => const ProfileScreen(),
            '/edit_profile': (context) => const EditProfileScreen(),
            '/about': (context) => const AboutScreen(),
          },
        );
      },
    );
  }
}
