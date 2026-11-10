import 'package:go_router/go_router.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/friends/presentation/screens/friends_screen.dart';
import '../../features/camera/presentation/screens/camera_capture_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FeedScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/friends',
      builder: (context, state) => const FriendsScreen(),
    ),
    GoRoute(
      path: '/camera',
      builder: (context, state) => const CameraCaptureScreen(),
    ),
  ],
);
