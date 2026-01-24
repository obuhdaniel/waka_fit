import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:waka_fit/core/components/dismiss_keyboard.dart';
import 'package:waka_fit/core/theme/theme_manager.dart';
import 'package:waka_fit/features/authentitcation/pages/providers/auth_provider.dart';
import 'package:waka_fit/features/home/providers/coach_provider.dart';
import 'package:waka_fit/features/home/providers/coaches_screen_provider.dart';
import 'package:waka_fit/features/home/providers/gym_providers.dart';
import 'package:waka_fit/features/onboarding/onboarding_screen.dart';
import 'package:waka_fit/features/onboarding/splash_screen.dart';
import 'package:waka_fit/shared/providers/onboarding_provider.dart';
import 'package:waka_fit/shared/providers/theme_provider.dart';
import 'package:waka_fit/shared/providers/user_provider.dart';
/// Background message handler - must be a top-level function -= LATER IMPLEMENTATION
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();

//   final data = message.data;
//   print("[FCM Background] Message received: $data");

//   if (message.notification != null && data.isEmpty) {
//     print("[FCM Background] Notification-only payload → skip local show");
//     return;
//   }

//   // Extract fields safely
//   final msgType = data['msg_type'] ??
//       data['message_type'] ??
//       data['subtype'] ??
//       data['type'] ??
//       'notification';
//   final type = data['type'] ?? 'general';
//   final messageText = data['message'] ?? data['content'] ?? '';
//   final slug = data['slug'] ?? '';
//   final username = data['username'] ?? 'Someone';

//   // Build a user-friendly title and body
//   String title;
//   String body;

//   switch (msgType.toString().toLowerCase()) {
//     // Suppress duplicate notifications for incidents
//     // These are already handled by the system notification from the payload
//     case 'new_incident':
//     case 'trending_incident':
//     case 'sos_incident':
//     case '5km_incident':
//     case 'proximity_incident':
//       if (message.notification != null) {
//         print(
//             "[FCM Background] Suppressing duplicate notification for $msgType");
//         return;
//       }

//       final actor = data['username'] ??
//           data['created_by'] ??
//           data['creator'] ??
//           data['reporter'];
//       final currentUsername = await SecureStorage.getUsername();
//       if (currentUsername != null &&
//           actor != null &&
//           currentUsername.toLowerCase().trim() ==
//               actor.toString().toLowerCase().trim()) {
//         print("[FCM Background] Skipping own incident notification");
//         return;
//       }

//       final rawTitle = data['title'];
//       final rawBody = data['body'];
//       final location = data['location'] ?? data['state'];

//       title = (rawTitle ??
//               (msgType.toString().toLowerCase() == 'new_incident'
//                   ? 'New Incident in your State'
//                   : 'Incident Alert'))
//           .toString();
//       body = (rawBody ??
//               (location != null && location.toString().trim().isNotEmpty
//                   ? location.toString()
//                   : (messageText.isNotEmpty
//                       ? messageText
//                       : 'Tap to view details')))
//           .toString();
//       break;

//     case 'comment':
//     case 'reply':
//     case 'message':
//     case 'chat':
//       title = '💬 New Message';
//       body = "$username: \"$messageText\"";
//       break;
//     case 'reaction':
//       title = 'New Reaction';
//       body = "$username reacted to your message";
//       break;

//     case 'report':
//       title = '📢 New Report Update';
//       body = "$username submitted a new $type report: $slug";
//       break;

//     case 'alert':
//       title = '🚨 Important Alert';
//       body = messageText.isNotEmpty
//           ? messageText
//           : "An important alert has been issued.";
//       break;

//     default:
//       if (messageText.isEmpty) {
//         print("[FCM Background] Unknown empty message → suppressed");
//         return;
//       }
//       title = 'Hospify Notification';
//       body = messageText;
//   }

//   // Display the notification
//   await NotificationService.showNotification(
//     id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
//     title: title,
//     body: body,
//     payload: slug.isNotEmpty ? slug : null,
//   );
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set up background message handler LATER TOO
  // FirebaseMessaging.onBackgroundMessage();

  // await NotificationService.initialize();
  // await NotificationService.registerUserLocation();

  // // Initialize deep link service for handling app links
  // await DeepLinkService().initialize();

  // Handle notification taps when app is terminated
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print(
          "[FCM] App opened from terminated state via notification: ${message.data}");
      // Handle the notification tap - this will be processed after the app starts
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => GymProvider()),
        ChangeNotifierProvider(create: (_) => CoachProvider()),
         ChangeNotifierProvider(create: (_) => CoachesScreenProvider()),
        // ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
       
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      builder: (context, build) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return DismissKeyboardBehavior(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Hospify',
                theme: getLightTheme(),
                darkTheme: getDarkTheme(),
                themeMode: themeProvider.themeMode,
                // navigatorKey: navigatorKey, // ⬅️ use shared key
                // routes: {
                //   '/incident-details': (context) {
                //     final args =
                //         ModalRoute.of(context)!.settings.arguments as Map;
                //     return IncidentDetailsPage(
                //       slug: args['slug'],
                //       autoOpenChat: args['autoOpenChat'] ?? false,
                //       incident: args['incident'] as Incident,
                //     );
                //   },
                // },
                home: const RootScreen(),
              ),
            );
          },
        );
      },
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);
    if (onboardingProvider.isOnboarded) {
      return const SplashScreen();
    } else {
      return const OnboardingScreen();
    }
  }
}
